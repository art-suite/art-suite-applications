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

{compact, array, object, defineModule, BaseObject, log, max, min} = require 'art-foundation'
{rgb256Color, rgbColor, hslColor} = require 'art-atomic'

quantize = require 'quantize'



defineModule module, ->

  # minimum number % of pixels with that color to allow it to be picked
  frequenceThreshold = .0005

  saturationWeight  = 7
  lumaWeight        = 12
  countWeight       = 7

  lumaDarkMin       = 0.1
  lumaDarkTarget    = 0.3
  lumaDarkMax       = 0.4

  lumaNormalMin     = 0.4
  lumaNormalTarget  = 0.5
  lumaNormalMax     = 0.6

  lumaLightMin      = 0.6
  lumaLightTarget   = 0.85
  lumaLightMax      = 1.01

  satMutedMin       = 0
  satMutedTarget    = 0.15
  satMutedMax       = 0.4

  satVibrantMin     = 0.4
  satVibrantTarget  = 1
  satVibrantMax     = 1.01

  colorTolerences =
    darkMuted:      targetLuma: lumaDarkTarget,    minLuma: lumaDarkMin,     maxLuma: lumaDarkMax,   targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    muted:          targetLuma: lumaNormalTarget,  minLuma: lumaNormalMin,   maxLuma: lumaNormalMax, targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    lightMuted:     targetLuma: lumaLightTarget,   minLuma: lumaLightMin,    maxLuma: lumaLightMax,  targetSat: satMutedTarget,   minSat: satMutedMin,    maxSat: satMutedMax
    darkVibrant:    targetLuma: lumaDarkTarget,    minLuma: lumaDarkMin,     maxLuma: lumaDarkMax,   targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    vibrant:        targetLuma: lumaNormalTarget,  minLuma: lumaNormalMin,   maxLuma: lumaNormalMax, targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax
    lightVibrant:   targetLuma: lumaLightTarget,   minLuma: lumaLightMin,    maxLuma: lumaLightMax,  targetSat: satVibrantTarget, minSat: satVibrantMin,  maxSat: satVibrantMax

  getMatchQuality = ({targetSat, targetLuma}, saturation, luma, {color, count}, maxCount) ->
    c = countWeight      * count / maxCount
    s = saturationWeight * invertDiff saturation, targetSat
    l = lumaWeight       * invertDiff luma,       targetLuma

    out = s + l + c
    # log getMatchQuality: {s, l, c, count, maxCount, color, out}
    out

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

    getHueDiff: (swatch) ->
      (@color.getHueDifference swatch.color) *
      max(@sat, swatch.sat)**2 *
      max(@luma, swatch.luma)**2

    getLumaDiff: (swatch) -> Math.abs @luma - swatch.luma

    qualifiesFor: (tolerences, totalCount) ->
      {
        # targetLuma
        # targetSat
        minLuma
        maxLuma
        minSat
        maxSat
      } = tolerences
      # log qualifiesFor:
      #   {@count, totalCount, @color, ratio: @count / totalCount}
      (@count / totalCount > frequenceThreshold) &&
      (minLuma <= @luma < maxLuma) &&
      (minSat <= @sat < maxSat)

  class Vibrant extends BaseObject

    colorQualifiesFor = (tolerences, color) ->
      color = rgbColor color
      lumSatQualifiesFor tolerences,
        color.perceptualLightness
        color.perceptualSaturation

    lumSatQualifiesFor = (tolerences, luma, sat) ->
      {
        minLuma
        maxLuma
        minSat
        maxSat
      } = tolerences

      (minLuma <= luma < maxLuma) &&
      (minSat <= sat < maxSat)

    @getVibrantQualifyingColors: (colors, vibrantCategoryName) ->
      tolerences = colorTolerences[vibrantCategoryName] ? colorTolerences.vibrant
      c for c in colors when colorQualifiesFor tolerences, c


    constructor: (pixels, options = {}) ->
      {colorCount = 64, quality = 1, @verbose} = options
      # log Vibrant_constructor: {pixels, options, colorCount} if @verbose
      @_selectedSwatches = {}
      @_selectedSwatchesList = []

      @_populateSwatches pixels, colorCount, quality
      @_selectColors()

    @getter
      colors: -> object @_selectedSwatches, (swatch) -> swatch.color
      rgbs:   -> object @_selectedSwatches, (swatch) -> swatch.rgb

    #####################
    # PRIVATE
    #####################

    _selectPixels = (pixels, sampleEveryN, minAlpha, maxRgb) ->
      allPixels = []
      for r, i in pixels by 4 * sampleEveryN
        g = pixels[i + 1]
        b = pixels[i + 2]
        a = pixels[i + 3]

        # If pixel is mostly opaque and not white
        if a >= minAlpha && r <= maxRgb and g <= maxRgb and b <= maxRgb
          allPixels.push [r, g, b]

      allPixels

    _populateSwatches: (pixels, colorCount, quality) ->

      pixelCount = pixels.length / 4

      allPixels = _selectPixels pixels, quality, 128, 250

      # handle degenerate images
      allPixels = _selectPixels pixels, quality, 32, 1000 if allPixels.length == 0
      allPixels.push [0,0,0] if allPixels.length == 0

      # log quantize: {allPixels: allPixels.length, colorCount} if @verbose
      cmap = quantize allPixels, colorCount


      @_maxCount = 0
      @_totalCount = 0
      @_inputSwatches = compact cmap.vboxes.map (vbox) =>
        if 0 < count = vbox.vbox.count()
          @_totalCount += count
          @_maxCount = max @_maxCount, count
          new Swatch vbox.color, count

      # log {@_inputSwatches}
      @verbose && log inputColors: (s.color for s in @_inputSwatches)

    @getter
      debugSwatches: ->
        isVibrant: (swatch for swatch in @_inputSwatches when swatch.isVibrant)
        isMuted:   (swatch for swatch in @_inputSwatches when swatch.isMuted  )
        isDark:    (swatch for swatch in @_inputSwatches when swatch.isDark   )
        isNormal:  (swatch for swatch in @_inputSwatches when swatch.isNormal )
        isLight:   (swatch for swatch in @_inputSwatches when swatch.isLight  )

    _selectColors: ->
      @verbose && log "_selectColors":
        swatches: (color for {color} in @_inputSwatches)

      for name, tolerences of colorTolerences
        qualifyingSwatches = for swatch in @_inputSwatches when swatch.qualifiesFor tolerences, @_totalCount
          swatch


        # @verbose &&
        @verbose && log "qualifying swatches for #{name}": qualifyingSwatches # (color for {color} in qualifyingSwatches)

        if @_selectSwatch name, variation = @_findColorVariation name, qualifyingSwatches
          selectedVariations = [variation]
          count = 2
          while variation = @_findMaxDifferentVariation name, qualifyingSwatches, selectedVariations
            selectedVariations.push variation
            @_selectSwatch "#{name}#{count++}", variation

      if @verbose
        log Vibrant:
          inputSwatches: (color for {color} in @_inputSwatches)
          outputColors: @colors



    minHueDifference = .015
    minLumaDifference = 1/8
    minCartesianDiff = .036
    hueLumaSensativityRatio = 10
    getCartesianDiff = (hueDiff, lumaDiff) ->
      Math.sqrt(
        (hueDiff * 10) ** 2 +
        (lumaDiff * .5 )** 2
      )

    _findMaxDifferentVariation: (name, qualifyingSwatches, selectedVariations) ->

      bestHueDifference = 0
      bestLumaDifference = 0
      # bestLumaSwatch = null
      # bestHueSwatch = null

      bestCartesianDiff = 0
      bestSwatch = null
      nextBestSwatch = null

      @verbose && log _findMaxDifferentVariation:
        name: name
        selectedVariations: (swatch.color for swatch in selectedVariations)

      for swatch in qualifyingSwatches when !@_isSelected swatch

        hueDiff = 10
        lumaDiff = 10
        cartesianDiff = 10

        for v in selectedVariations
          hueDiff  = min hueDiff , swatch.getHueDiff  v
          lumaDiff = min lumaDiff, swatch.getLumaDiff v
          cartesianDiff = min cartesianDiff, getCartesianDiff hueDiff, lumaDiff

        if bestCartesianDiff < cartesianDiff
          bestCartesianDiff = cartesianDiff
          bestHueDifference = hueDiff
          bestLumaDifference = lumaDiff
          if cartesianDiff > minCartesianDiff
            bestSwatch = swatch
          else
            nextBestSwatch = swatch

      if @verbose
        if bestSwatch
          log _findColorVariation: bestSwatch: {
            name
            color: bestSwatch.color
            bestHueDifference
            bestLumaDifference
            bestCartesianDiff
            minCartesianDiff
          }

        else
          log _findColorVariation: done: {
            name
            nextBest: nextBestSwatch?.color
            bestHueDifference
            bestLumaDifference
            bestCartesianDiff
            minCartesianDiff
          }

      bestSwatch

      # if maxHueDifference > minHueDifference
      #   bestHueSwatch

      # else if maxLumaDifference > minLumaDifference
      #   bestLumaSwatch

      # else
      #   null

    _selectSwatch: (name, swatch) ->
      if swatch
        @_selectedSwatches[name] = swatch
        @_selectedSwatchesList.push swatch
      swatch

    _isSelected: (swatch) -> swatch in @_selectedSwatchesList

    _findColorVariation: (name, qualifyingSwatches) ->
      tolerences = colorTolerences[name]
      bestSwatch = null
      maxQuality = 0

      for swatch in qualifyingSwatches when !@_isSelected swatch
        {sat, luma} = swatch
        if maxQuality < quality = getMatchQuality tolerences, sat, luma, swatch, @_maxCount
          bestSwatch = swatch
          maxQuality = quality

      bestSwatch
