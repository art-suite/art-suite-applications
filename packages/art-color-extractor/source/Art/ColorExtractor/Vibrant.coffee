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

{compact, array, object, defineModule, BaseObject, log, max} = require 'art-foundation'
{rgb256Color, rgbColor, hslColor} = require 'art-atomic'

quantize = require 'quantize'

defineModule module, ->

  saturationWeight  = 7
  lumaWeight        = 12
  countWeight       = 1

  lumaDarkMin       = 0
  lumaDarkTarget    = 0.3
  lumaDarkMax       = 0.4

  lumaNormalMin     = 0.4
  lumaNormalTarget  = 0.5
  lumaNormalMax     = 0.6

  lumaLightMin      = 0.6
  lumaLightTarget   = 0.85
  lumaLightMax      = 1

  satMutedMin       = 0
  satMutedTarget    = 0.15
  satMutedMax       = 0.20

  satVibrantMin     = 0.4
  satVibrantTarget  = 1
  satVibrantMax     = 1

  colorTolerences =
    darkMuted:      targetLuma: lumaDarkTarget,    minLuma: lumaDarkMin,     maxLuma: lumaDarkMax,   targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    muted:          targetLuma: lumaNormalTarget,  minLuma: lumaNormalMin,   maxLuma: lumaNormalMax, targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    lightMuted:     targetLuma: lumaLightTarget,   minLuma: lumaLightMin,    maxLuma: lumaLightMax,  targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    darkVibrant:    targetLuma: lumaDarkTarget,    minLuma: lumaDarkMin,     maxLuma: lumaDarkMax,   targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    vibrant:        targetLuma: lumaNormalTarget,  minLuma: lumaNormalMin,   maxLuma: lumaNormalMax, targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    lightVibrant:   targetLuma: lumaLightTarget,   minLuma: lumaLightMin,    maxLuma: lumaLightMax,  targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax

  getMatchQuality = (saturation, targetSat, luma, targetLuma, count, maxCount) ->
    saturationWeight * invertDiff(saturation, targetSat ) +
    lumaWeight       * invertDiff(luma,       targetLuma) +
    countWeight      * count / maxCount

  invertDiff = (value, targetValue) -> 1 - Math.abs value - targetValue

  class Swatch extends BaseObject

    constructor: (@rgb, @count) ->
      @_hsl = @_color = null

    @property "rgb count"

    @getter
      inspectedObjects: -> {@color, @luma, @sat, @normalSat, @count}
      hsl:   -> @_hsl ||= @color.arrayHsl
      color: -> @_color ||= rgb256Color @rgb
      luma:  -> @_luma ?= @color.perceptualLightness
      sat:   -> @_sat ||= @color.perceptualSaturation
      normalSat: -> @color.sat

      isVibrant: -> satVibrantMin <= @sat  <= satVibrantMax
      isMuted:   -> satMutedMin   <= @sat  <= satMutedMax
      isDark:    -> lumaDarkMin   <= @luma <= lumaDarkMax
      isNormal:  -> lumaNormalMin <= @luma <= lumaNormalMax
      isLight:   -> lumaLightMin  <= @luma <= lumaLightMax

    qualifiesFor: (tolerences) ->
      {
        # targetLuma
        # targetSat
        minLuma
        maxLuma
        minSat
        maxSat
      } = tolerences
      (minLuma <= @luma <= maxLuma) &&
      (minSat <= @sat <= maxSat)

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

      @_maxCount = 0
      @_inputSwatches = compact cmap.vboxes.map (vbox) =>
        if 0 < count = vbox.vbox.count()
          @_maxCount = max @_maxCount, count
          new Swatch vbox.color, count

      # log {@_inputSwatches}

    @getter
      debugSwatches: ->
        isVibrant: (swatch for swatch in @_inputSwatches when swatch.isVibrant)
        isMuted:   (swatch for swatch in @_inputSwatches when swatch.isMuted  )
        isDark:    (swatch for swatch in @_inputSwatches when swatch.isDark   )
        isNormal:  (swatch for swatch in @_inputSwatches when swatch.isNormal )
        isLight:   (swatch for swatch in @_inputSwatches when swatch.isLight  )

    _generateVariationColors: ->
      for name, tolerences of colorTolerences
        log "qualifying swatches for #{name}": array @_inputSwatches,
          when: (swatch) -> swatch.qualifiesFor tolerences
          with: (swatch) -> swatch.color

        if variation = @_findColorVariation name
          @_selectSwatch name, variation

    _selectSwatch: (name, swatch) ->
      @_selectedSwatches[name] = swatch
      @_selectedSwatchesList.push swatch

    _isSelected: (swatch) -> swatch in @_selectedSwatchesList

    _findColorVariation: (name) ->
      {targetLuma, minLuma, maxLuma, targetSat, minSat, maxSat} = colorTolerences[name]
      bestSwatch = null
      maxQuality = -1

      for swatch in @_inputSwatches when !@_isSelected swatch
        {sat, luma} = swatch

        if minSat <= sat <= maxSat and minLuma <= luma <= maxLuma

          if maxQuality < quality = getMatchQuality sat, targetSat, luma, targetLuma, swatch.count, @_maxCount
            bestSwatch = swatch
            maxQuality = quality

          # log {name, quality, swatch}

      bestSwatch
