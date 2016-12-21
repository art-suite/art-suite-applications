###
  Vibrant.js
  by Jari Zwarts
  Color algorithm class that finds variations on colors in an image.
  Credits
  --------
  Lokesh Dhakar (http://www.lokeshdhakar.com) - Created ColorThief
  Google - Palette support library in Android
###

{defineModule, BaseObject, log} = require 'art-foundation'
{rgbColor, hslColor} = require 'art-atomic'

quantize = require 'quantize'

defineModule module, ->

  rgbToHsl = ([r, g, b]) -> (rgbColor r/255, g/255, b/255).arrayHsl

  hslToRgb = ([h, s, l]) ->
    {r256, g256, b256} = hslColor h, s, l
    [r256, g256, b256]

  class Swatch extends BaseObject

    constructor: (@rgb, @population) ->
      @_hsl = @_yiq = null

    @property "rgb population"

    @getter
      hsl: -> @_hsl ||= rgbToHsl @rgb
      hex: -> "#" + ((1 << 24) + (@rgb[0] << 16) + (@rgb[1] << 8) + @rgb[2]).toString(16).slice(1, 7);
      yiq: -> @_yiq ||= (@rgb[0] * 299 + @rgb[1] * 587 + @rgb[2] * 114) / 1000

    getTitleTextColor: -> if @yiq < 200 then "#fff" else "#000"
    getBodyTextColor:  -> if @yiq < 150 then "#fff" else "#000"

  class Vibrant


    TARGET_DARK_LUMA:           0.36
    MAX_DARK_LUMA:              0.55
    MIN_LIGHT_LUMA:             0.65
    TARGET_LIGHT_LUMA:          0.84

    MIN_NORMAL_LUMA:            0.5
    TARGET_NORMAL_LUMA:         0.6
    MAX_NORMAL_LUMA:            0.8

    TARGET_MUTED_SATURATION:    0.2
    MAX_MUTED_SATURATION:       0.3

    TARGET_VIBRANT_SATURATION:  1
    MIN_VIBRANT_SATURATION:     0.55

    WEIGHT_SATURATION:          3
    WEIGHT_LUMA:                6
    WEIGHT_POPULATION:          1

    constructor: (pixels, colorCount = 64, quality = 5) ->
      @VibrantSwatch =
      @MutedSwatch =
      @DarkVibrantSwatch =
      @DarkMutedSwatch =
      @LightVibrantSwatch =
      @LightMutedSwatch = null

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

      @_swatches = cmap.vboxes.map (vbox) ->
        new Swatch vbox.color, vbox.vbox.count()

      @maxPopulation = @findMaxPopulation

      @generateVarationColors()
      @generateEmptySwatches()


    generateVarationColors: ->
      @VibrantSwatch = @findColorVariation(@TARGET_NORMAL_LUMA, @MIN_NORMAL_LUMA, @MAX_NORMAL_LUMA,
        @TARGET_VIBRANT_SATURATION, @MIN_VIBRANT_SATURATION, 1);

      @LightVibrantSwatch = @findColorVariation(@TARGET_LIGHT_LUMA, @MIN_LIGHT_LUMA, 1,
        @TARGET_VIBRANT_SATURATION, @MIN_VIBRANT_SATURATION, 1);

      @DarkVibrantSwatch = @findColorVariation(@TARGET_DARK_LUMA, 0, @MAX_DARK_LUMA,
        @TARGET_VIBRANT_SATURATION, @MIN_VIBRANT_SATURATION, 1);

      @MutedSwatch = @findColorVariation(@TARGET_NORMAL_LUMA, @MIN_NORMAL_LUMA, @MAX_NORMAL_LUMA,
        @TARGET_MUTED_SATURATION, 0, @MAX_MUTED_SATURATION);

      @LightMutedSwatch = @findColorVariation(@TARGET_LIGHT_LUMA, @MIN_LIGHT_LUMA, 1,
        @TARGET_MUTED_SATURATION, 0, @MAX_MUTED_SATURATION);

      @DarkMutedSwatch = @findColorVariation(@TARGET_DARK_LUMA, 0, @MAX_DARK_LUMA,
        @TARGET_MUTED_SATURATION, 0, @MAX_MUTED_SATURATION);

    generateEmptySwatches: ->
      if @VibrantSwatch is undefined
        # If we do not have a vibrant color...
        if @DarkVibrantSwatch isnt undefined
          # ...but we do have a dark vibrant, generate the value by modifying the luma
          hsl = @DarkVibrantSwatch.getHsl()
          hsl[2] = @TARGET_NORMAL_LUMA
          @VibrantSwatch = new Swatch hslToRgb(hsl), 0

      if @DarkVibrantSwatch is undefined
        # If we do not have a vibrant color...
        if @VibrantSwatch isnt undefined
          # ...but we do have a dark vibrant, generate the value by modifying the luma
          hsl = @VibrantSwatch.getHsl()
          hsl[2] = @TARGET_DARK_LUMA
          @DarkVibrantSwatch = new Swatch hslToRgb(hsl), 0

    findMaxPopulation: ->
      population = 0
      population = Math.max(population, swatch.getPopulation()) for swatch in @_swatches
      population

    findColorVariation: (targetLuma, minLuma, maxLuma, targetSaturation, minSaturation, maxSaturation) ->
      max = undefined
      maxValue = 0

      for swatch in @_swatches
        [__, sat, luma] = swatch.getHsl()

        if sat >= minSaturation and sat <= maxSaturation and
            luma >= minLuma and luma <= maxLuma and
            not @isAlreadySelected swatch
          value = @createComparisonValue sat, targetSaturation, luma, targetLuma,
            swatch.getPopulation(), 0
          if max is undefined or value > maxValue
            max = swatch
            maxValue = value

      max

    createComparisonValue: (saturation, targetSaturation,
        luma, targetLuma, population, maxPopulation) ->

      weightedMean(
        invertDiff(saturation, targetSaturation), @WEIGHT_SATURATION,
        invertDiff(luma, targetLuma), @WEIGHT_LUMA,
        population / maxPopulation, @WEIGHT_POPULATION
      )

    invertDiff = (value, targetValue) ->
      1 - Math.abs value - targetValue

    weightedMean = (values...) ->
      sum = 0
      sumWeight = 0
      i = 0
      while i < values.length
        value = values[i]
        weight = values[i + 1]
        sum += value * weight
        sumWeight += weight
        i += 2
      sum / sumWeight

    swatches: ->
      Vibrant:      @VibrantSwatch
      Muted:        @MutedSwatch
      DarkVibrant:  @DarkVibrantSwatch
      DarkMuted:    @DarkMutedSwatch
      LightVibrant: @LightVibrantSwatch
      LightMuted:   @LightMutedSwatch

    isAlreadySelected: (swatch) ->
      @VibrantSwatch is swatch or @DarkVibrantSwatch is swatch or
        @LightVibrantSwatch is swatch or @MutedSwatch is swatch or
        @DarkMutedSwatch is swatch or @LightMutedSwatch is swatch
