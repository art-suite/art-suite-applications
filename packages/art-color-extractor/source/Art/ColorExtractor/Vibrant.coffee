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
    Vibrant:        targetLuma: TARGET_NORMAL_LUMA,  minLuma: MIN_NORMAL_LUMA,   maxLuma: MAX_NORMAL_LUMA, targetSaturation: TARGET_VIBRANT_SATURATION, minSaturation: MIN_VIBRANT_SATURATION,  maxSaturation: MAX_VIBRANT_SATURATION
    LightVibrant:   targetLuma: TARGET_LIGHT_LUMA,   minLuma: MIN_LIGHT_LUMA,    maxLuma: MAX_LIGHT_LUMA,  targetSaturation: TARGET_VIBRANT_SATURATION, minSaturation: MIN_VIBRANT_SATURATION,  maxSaturation: MAX_VIBRANT_SATURATION
    DarkVibrant:    targetLuma: TARGET_DARK_LUMA,    minLuma: MIN_DARK_LUMA,     maxLuma: MAX_DARK_LUMA,   targetSaturation: TARGET_VIBRANT_SATURATION, minSaturation: MIN_VIBRANT_SATURATION,  maxSaturation: MAX_VIBRANT_SATURATION
    Muted:          targetLuma: TARGET_NORMAL_LUMA,  minLuma: MIN_NORMAL_LUMA,   maxLuma: MAX_NORMAL_LUMA, targetSaturation: TARGET_MUTED_SATURATION,   minSaturation: MIN_MUTED_SATURATION,    maxSaturation: MAX_MUTED_SATURATION
    LightMuted:     targetLuma: TARGET_LIGHT_LUMA,   minLuma: MIN_LIGHT_LUMA,    maxLuma: MAX_LIGHT_LUMA,  targetSaturation: TARGET_MUTED_SATURATION,   minSaturation: MIN_MUTED_SATURATION,    maxSaturation: MAX_MUTED_SATURATION
    DarkMuted:      targetLuma: TARGET_DARK_LUMA,    minLuma: MIN_DARK_LUMA,     maxLuma: MAX_DARK_LUMA,   targetSaturation: TARGET_MUTED_SATURATION,   minSaturation: MIN_MUTED_SATURATION,    maxSaturation: MAX_MUTED_SATURATION

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
      hsl: -> @_hsl ||= @color.arrayHsl
      yiq: -> @_yiq ||= (@rgb[0] * 299 + @rgb[1] * 587 + @rgb[2] * 114) / 1000
      color: -> @_color ||= rgb256Color @rgb

    getTitleTextColor: -> if @yiq < 200 then "#fff" else "#000"
    getBodyTextColor:  -> if @yiq < 150 then "#fff" else "#000"

  class VibrantColors extends BaseObject

    constructor: (pixels, colorCount = 32, quality = 1) ->
      @_selectedSwatches = {}
      @_selectedSwatchesList = []

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
      @_swatches = cmap.vboxes.map (vbox) ->
        count = vbox.vbox.count()
        log rgb256Color vbox.color
        @_maxPopulation = max @_maxPopulation, count
        new Swatch vbox.color, count

      @generateVarationColors()
      @normalizeSelectedSwatches()

    generateVarationColors: ->
      for name, tolerences of colorTolerences
        if variation = @findColorVariation tolerences
          @selectSwatch name, variation

    selectSwatch: (name, swatch) ->
      @_selectedSwatches[name] = swatch
      @_selectedSwatchesList.push swatch

    isSelected: (swatch) -> swatch in @_selectedSwatchesList

    normalizeSelectedSwatches: ->
      {Vibrant, DarkVibrant} = @_selectedSwatches
      if !!Vibrant != !!DarkVibrant
        {hsl} = DarkVibrant || Vibrant
        log normalizeSelectedSwatches: Vibrant: Vibrant?.color, DarkVibrant: DarkVibrant?.color
        if Vibrant
          hsl[2] = TARGET_DARK_LUMA
          @_selectedSwatches.DarkVibrant = new Swatch hslToRgb(hsl), 0
        else
          hsl[2] = TARGET_NORMAL_LUMA
          @_selectedSwatches.Vibrant     = new Swatch hslToRgb(hsl), 0

    findColorVariation: ({targetLuma, minLuma, maxLuma, targetSaturation, minSaturation, maxSaturation}) ->
      bestSwatch = null
      maxQuality = -1

      for swatch in @_swatches when !@isSelected swatch
        [__, sat, luma] = swatch.hsl

        if minSaturation <= sat <= maxSaturation and minLuma <= luma <= maxLuma

          if maxQuality < quality = getMatchQuality sat, targetSaturation, luma, targetLuma, swatch.population, @_maxPopulation
            bestSwatch = swatch
            maxQuality = quality

      bestSwatch

    @getter
      colors: -> object @_selectedSwatches, (swatch) -> swatch.color
      rgbs:   -> object @_selectedSwatches, (swatch) -> swatch.rgb
