###
  Vibrant.js
  by Jari Zwarts
  Color algorithm class that finds variations on colors in an image.
  Credits
  --------
  Lokesh Dhakar (http://www.lokeshdhakar.com) - Created ColorThief
  Google - Palette support library in Android
###

{object, defineModule, BaseObject, log, max} = require 'art-foundation'
{rgb256Color, rgbColor, hslColor} = require 'art-atomic'

quantize = require 'quantize'

defineModule module, ->

  WEIGHT_SATURATION =           3
  WEIGHT_LUMA =                 6
  WEIGHT_POPULATION =           1

  MIN_DARK_LUMA =               0.2
  TARGET_DARK_LUMA =            0.35
  MAX_DARK_LUMA =               0.5

  MIN_LIGHT_LUMA =              0.65
  TARGET_LIGHT_LUMA =           0.84
  MAX_LIGHT_LUMA =              1

  MIN_NORMAL_LUMA =             0.4
  TARGET_NORMAL_LUMA =          0.6
  MAX_NORMAL_LUMA =             0.8

  MIN_MUTED_SATURATION =        0
  TARGET_MUTED_SATURATION =     0.2
  MAX_MUTED_SATURATION =        0.3

  MIN_VIBRANT_SATURATION =      0.7
  TARGET_VIBRANT_SATURATION =   1
  MAX_VIBRANT_SATURATION =      1

  colorTolerences =
    vibrant:        targetLuma: TARGET_NORMAL_LUMA,  minLuma: MIN_NORMAL_LUMA,   maxLuma: MAX_NORMAL_LUMA, targetSaturation: TARGET_VIBRANT_SATURATION, minSaturation: MIN_VIBRANT_SATURATION,  maxSaturation: MAX_VIBRANT_SATURATION
    lightVibrant:   targetLuma: TARGET_LIGHT_LUMA,   minLuma: MIN_LIGHT_LUMA,    maxLuma: MAX_LIGHT_LUMA,  targetSaturation: TARGET_VIBRANT_SATURATION, minSaturation: MIN_VIBRANT_SATURATION,  maxSaturation: MAX_VIBRANT_SATURATION
    darkVibrant:    targetLuma: TARGET_DARK_LUMA,    minLuma: MIN_DARK_LUMA,     maxLuma: MAX_DARK_LUMA,   targetSaturation: TARGET_VIBRANT_SATURATION, minSaturation: MIN_VIBRANT_SATURATION,  maxSaturation: MAX_VIBRANT_SATURATION
    muted:          targetLuma: TARGET_NORMAL_LUMA,  minLuma: MIN_NORMAL_LUMA,   maxLuma: MAX_NORMAL_LUMA, targetSaturation: TARGET_MUTED_SATURATION,   minSaturation: MIN_MUTED_SATURATION,    maxSaturation: MAX_MUTED_SATURATION
    lightMuted:     targetLuma: TARGET_LIGHT_LUMA,   minLuma: MIN_LIGHT_LUMA,    maxLuma: MAX_LIGHT_LUMA,  targetSaturation: TARGET_MUTED_SATURATION,   minSaturation: MIN_MUTED_SATURATION,    maxSaturation: MAX_MUTED_SATURATION
    darkMuted:      targetLuma: TARGET_DARK_LUMA,    minLuma: MIN_DARK_LUMA,     maxLuma: MAX_DARK_LUMA,   targetSaturation: TARGET_MUTED_SATURATION,   minSaturation: MIN_MUTED_SATURATION,    maxSaturation: MAX_MUTED_SATURATION

  rgbToHsl = (rgb) -> (rgb256Color rgb).arrayHsl

  hslToRgb = ([h, s, l]) ->
    {r256, g256, b256} = hslColor h, s, l
    [r256, g256, b256]

  getMatchQuality = (saturation, targetSaturation, luma, targetLuma, population, maxPopulation) ->
    (
      invertDiff(saturation, targetSaturation)  * WEIGHT_SATURATION
      invertDiff(luma, targetLuma)              * WEIGHT_LUMA
      (population / maxPopulation)              * WEIGHT_POPULATION
    ) / (WEIGHT_SATURATION + WEIGHT_LUMA + WEIGHT_POPULATION)

  invertDiff = (value, targetValue) -> 1 - Math.abs value - targetValue

  class Swatch extends BaseObject

    constructor: (@rgb, @population) ->
      @_hsl = @_yiq = null

    @property "rgb population"

    @getter
      hsl:   -> @_hsl ||= @color.arrayHsl
      yiq:   -> @_yiq ||= (@rgb[0] * 299 + @rgb[1] * 587 + @rgb[2] * 114) / 1000
      color: -> @_color ||= rgb256Color @rgb

  class VibrantColors extends BaseObject

    constructor: (pixels, colorCount = 32, quality = 1) ->
      @_selectedSwatches = {}
      @_selectedSwatchesList = []

      @_populateSwatches pixels, colorCount, quality
      @_generateVarationColors()

    @getter
      colors: -> object @_selectedSwatches, (swatch) -> swatch.color
      rgbs:   -> object @_selectedSwatches, (swatch) -> swatch.rgb

    #####################
    # PRIVATE
    #####################
    _populateSwatches: (pixels, colorCount, quality) ->

      pixelCount = pixels.length / 4

      allPixels = []
      for r, i in pixels by 4 * quality
        g = pixels[i + 1]
        b = pixels[i + 2]
        a = pixels[i + 3]

        # If pixel is mostly opaque and not white
        if a >= 125 && !(r > 250 and g > 250 and b > 250)
          allPixels.push [r, g, b]

      cmap = quantize allPixels, colorCount

      @_maxPopulation = 0
      @_inputSwatches = cmap.vboxes.map (vbox) ->
        count = vbox.vbox.count()
        # log rgb256Color vbox.color
        @_maxPopulation = max @_maxPopulation, count
        new Swatch vbox.color, count

    _generateVarationColors: ->
      for name, tolerences of colorTolerences
        if variation = @_findColorVariation tolerences
          @_selectSwatch name, variation

    _selectSwatch: (name, swatch) ->
      @_selectedSwatches[name] = swatch
      @_selectedSwatchesList.push swatch

    _isSelected: (swatch) -> swatch in @_selectedSwatchesList

    _findColorVariation: ({targetLuma, minLuma, maxLuma, targetSaturation, minSaturation, maxSaturation}) ->
      bestSwatch = null
      maxQuality = -1

      for swatch in @_inputSwatches when !@_isSelected swatch
        [__, sat, luma] = swatch.hsl

        if minSaturation <= sat <= maxSaturation and minLuma <= luma <= maxLuma

          if maxQuality < quality = getMatchQuality sat, targetSaturation, luma, targetLuma, swatch.population, @_maxPopulation
            bestSwatch = swatch
            maxQuality = quality

      bestSwatch
