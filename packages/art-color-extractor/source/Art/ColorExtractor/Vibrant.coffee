###
  Original Vibrant.js:
    by Jari Zwarts
    Color algorithm class that finds variations on colors in an image.
    Credits
    --------
    Lokesh Dhakar (http://www.lokeshdhakar.com) - Created ColorThief
    Google - Palette support library in Android

  Art.ColorExtractor.Vibrant:
    Significant refactor with many bug fixes.
    Leverages Art.Atomic and Art.Foundation

###

{object, defineModule, BaseObject, log, max} = require 'art-foundation'
{rgb256Color, rgbColor, hslColor} = require 'art-atomic'

quantize = require 'quantize'

defineModule module, ->

  saturationWeight  = 3
  lumaWeight        = 6
  populationWeight  = 1
  totalQualityWeight = saturationWeight + lumaWeight + populationWeight

  lumaDarkMin       = 0.2
  lumaDarkTarget    = 0.35
  lumaDarkMax       = 0.5

  lumaLightMin      = 0.65
  lumaLightTarget   = 0.84
  lumaLightMax      = 1

  lumaNormalMin     = 0.4
  lumaNormalTarget  = 0.6
  lumaNormalMax     = 0.8

  satMutedMin       = 0
  satMutedTarget    = 0.2
  satMutedMax       = 0.3

  satVibrantMin     = 0.7
  satVibrantTarget  = 1
  satVibrantMax     = 1

  colorTolerences =
    vibrant:        targetLuma: lumaNormalTarget,  minLuma: lumaNormalMin,   maxLuma: lumaNormalMax, targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    lightVibrant:   targetLuma: lumaLightTarget,   minLuma: lumaLightMin,    maxLuma: lumaLightMax,  targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    darkVibrant:    targetLuma: lumaDarkTarget,    minLuma: lumaDarkMin,     maxLuma: lumaDarkMax,   targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    muted:          targetLuma: lumaNormalTarget,  minLuma: lumaNormalMin,   maxLuma: lumaNormalMax, targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    lightMuted:     targetLuma: lumaLightTarget,   minLuma: lumaLightMin,    maxLuma: lumaLightMax,  targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    darkMuted:      targetLuma: lumaDarkTarget,    minLuma: lumaDarkMin,     maxLuma: lumaDarkMax,   targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax

  getMatchQuality = (saturation, targetSat, luma, targetLuma, population, maxPopulation) ->
    (
      (saturationWeight * invertDiff saturation, targetSat) +
      (lumaWeight       * invertDiff luma, targetLuma     ) +
      (populationWeight * population / maxPopulation      )
    ) / totalQualityWeight

  invertDiff = (value, targetValue) -> 1 - Math.abs value - targetValue

  class Swatch extends BaseObject

    constructor: (@rgb, @population) ->
      @_hsl = @_color = null

    @property "rgb population"

    @getter
      hsl:   -> @_hsl ||= @color.arrayHsl
      color: -> @_color ||= rgb256Color @rgb

  class VibrantColors extends BaseObject

    constructor: (pixels, colorCount = 32, quality = 1) ->
      @_selectedSwatches = {}
      @_selectedSwatchesList = []

      @_populateSwatches pixels, colorCount, quality
      @_generateVariationColors()

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
        @_maxPopulation = max @_maxPopulation, count
        new Swatch vbox.color, count

    _generateVariationColors: ->
      for name, tolerences of colorTolerences
        if variation = @_findColorVariation tolerences
          @_selectSwatch name, variation

    _selectSwatch: (name, swatch) ->
      @_selectedSwatches[name] = swatch
      @_selectedSwatchesList.push swatch

    _isSelected: (swatch) -> swatch in @_selectedSwatchesList

    _findColorVariation: ({targetLuma, minLuma, maxLuma, targetSat, minSat, maxSat}) ->
      bestSwatch = null
      maxQuality = -1

      for swatch in @_inputSwatches when !@_isSelected swatch
        [__, sat, luma] = swatch.hsl

        if minSat <= sat <= maxSat and minLuma <= luma <= maxLuma

          if maxQuality < quality = getMatchQuality sat, targetSat, luma, targetLuma, swatch.population, @_maxPopulation
            bestSwatch = swatch
            maxQuality = quality

      bestSwatch
