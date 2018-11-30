Foundation = require 'art-foundation'
AtomicBase = require './Base'
{
  inspect, bound, modulo, pad, min, max, abs, float32Eq, isString, log

  hex16ColorRegExp
  hex256ColorRegExp
  hex16GreyColorRegExp
  hex256GreyColorRegExp
  rgbColorRegExp
  rgbaColorRegExp
  float32Eq0
  object
  isNumber
} = Foundation

colorFloatEq = float32Eq #(n1, n2) -> Math.abs(n1 - n2) < 1/256

parseRGBColorComponent = (str) ->
  if (percentIndex = str.indexOf('%'))!= -1
    (str.slice(0, percentIndex)|0) * .01
  else
    (str|0) * 1/255

module.exports = class Color extends AtomicBase
  @defineAtomicClass fieldNames: "r g b a", constructorFunctionName: "rgbColor"
  @isColor: isColor = (c) -> !!(c?.constructor == Color)

  @colorNames:   colorNames = [
    'AliceBlue', 'AntiqueWhite', 'Aqua', 'Aquamarine', 'Azure',
    'Beige', 'Bisque', 'Black', 'BlanchedAlmond', 'Blue', 'BlueViolet', 'Brown',
    'BurlyWood', 'CadetBlue', 'Chartreuse', 'Chocolate', 'Coral',
    'CornflowerBlue', 'Cornsilk', 'Crimson', 'Cyan', 'DarkBlue', 'DarkCyan',
    'DarkGoldenRod', 'DarkGray', 'DarkGreen', 'DarkKhaki', 'DarkMagenta',
    'DarkOliveGreen', 'DarkOrange', 'DarkOrchid', 'DarkRed', 'DarkSalmon',
    'DarkSeaGreen', 'DarkSlateBlue', 'DarkSlateGray', 'DarkTurquoise',
    'DarkViolet', 'DeepPink', 'DeepSkyBlue', 'DimGray', 'DodgerBlue', 'FireBrick',
    'FloralWhite', 'ForestGreen', 'Fuchsia', 'Gainsboro', 'GhostWhite', 'Gold',
    'GoldenRod', 'Gray', 'Green', 'GreenYellow', 'HoneyDew', 'HotPink',
    'IndianRed', 'Indigo', 'Ivory', 'Khaki', 'Lavender', 'LavenderBlush',
    'LawnGreen', 'LemonChiffon', 'LightBlue', 'LightCoral', 'LightCyan',
    'LightGoldenRodYellow', 'LightGray', 'LightGreen', 'LightPink',
    'LightSalmon', 'LightSeaGreen', 'LightSkyBlue', 'LightSlateGray',
    'LightSteelBlue', 'LightYellow', 'Lime', 'LimeGreen', 'Linen', 'Magenta',
    'Maroon', 'MediumAquaMarine', 'MediumBlue', 'MediumOrchid', 'MediumPurple',
    'MediumSeaGreen', 'MediumSlateBlue', 'MediumSpringGreen', 'MediumTurquoise',
    'MediumVioletRed', 'MidnightBlue', 'MintCream', 'MistyRose', 'Moccasin',
    'NavajoWhite', 'Navy', 'OldLace', 'Olive', 'OliveDrab', 'Orange', 'OrangeRed',
    'Orchid', 'PaleGoldenRod', 'PaleGreen', 'PaleTurquoise', 'PaleVioletRed',
    'PapayaWhip', 'PeachPuff', 'Peru', 'Pink', 'Plum', 'PowderBlue', 'Purple',
    'Red', 'RosyBrown', 'RoyalBlue', 'SaddleBrown', 'Salmon', 'SandyBrown',
    'SeaGreen', 'SeaShell', 'Sienna', 'Silver', 'SkyBlue', 'SlateBlue',
    'SlateGray', 'Snow', 'SpringGreen', 'SteelBlue', 'Tan', 'Teal', 'Thistle',
    'Tomato', 'Turquoise', 'Violet', 'Wheat', 'White', 'WhiteSmoke', 'Yellow',
    'YellowGreen'
  ]

  @colorNamesMap: colorNamesMap =
    transparent:         "rgba(0,0,0,0)"
    aliceblue:           "#f0f8ff"
    antiquewhite:        "#faebd7"
    aqua:                "#00ffff"
    aquamarine:          "#7fffd4"
    azure:               "#f0ffff"
    beige:               "#f5f5dc"
    bisque:              "#ffe4c4"
    black:               "#000000"
    blanchedalmond:      "#ffebcd"
    blue:                "#0000ff"
    blueviolet:          "#8a2be2"
    brown:               "#a52a2a"
    burlywood:           "#deb887"
    cadetblue:           "#5f9ea0"
    chartreuse:          "#7fff00"
    chocolate:           "#d2691e"
    coral:               "#ff7f50"
    cornflowerblue:      "#6495ed"
    cornsilk:            "#fff8dc"
    crimson:             "#dc143c"
    cyan:                "#00ffff"
    darkblue:            "#00008b"
    darkcyan:            "#008b8b"
    darkgoldenrod:       "#b8860b"
    darkgrey:            "#a9a9a9"
    darkgray:            "#a9a9a9"
    darkgreen:           "#006400"
    darkkhaki:           "#bdb76b"
    darkmagenta:         "#8b008b"
    darkolivegreen:      "#556b2f"
    darkorange:          "#ff8c00"
    darkorchid:          "#9932cc"
    darkred:             "#8b0000"
    darksalmon:          "#e9967a"
    darkseagreen:        "#8fbc8f"
    darkslateblue:       "#483d8b"
    darkslategrey:       "#2f4f4f"
    darkslategray:       "#2f4f4f"
    darkturquoise:       "#00ced1"
    darkviolet:          "#9400d3"
    deeppink:            "#ff1493"
    deepskyblue:         "#00bfff"
    dimgrey:             "#696969"
    dimgray:             "#696969"
    dodgerblue:          "#1e90ff"
    firebrick:           "#b22222"
    floralwhite:         "#fffaf0"
    forestgreen:         "#228b22"
    fuchsia:             "#ff00ff"
    gainsboro:           "#dcdcdc"
    ghostwhite:          "#f8f8ff"
    gold:                "#ffd700"
    goldenrod:           "#daa520"
    grey:                "#808080"
    gray:                "#808080"
    green:               "#008000"
    greenyellow:         "#adff2f"
    honeydew:            "#f0fff0"
    hotpink:             "#ff69b4"
    indianred:           "#cd5c5c"
    indigo:              "#4b0082"
    ivory:               "#fffff0"
    khaki:               "#f0e68c"
    lavender:            "#e6e6fa"
    lavenderblush:       "#fff0f5"
    lawngreen:           "#7cfc00"
    lemonchiffon:        "#fffacd"
    lightblue:           "#add8e6"
    lightcoral:          "#f08080"
    lightcyan:           "#e0ffff"
    lightgoldenrodyellow:"#fafad2"
    lightgrey:           "#d3d3d3"
    lightgray:           "#d3d3d3"
    lightgreen:          "#90ee90"
    lightpink:           "#ffb6c1"
    lightsalmon:         "#ffa07a"
    lightseagreen:       "#20b2aa"
    lightskyblue:        "#87cefa"
    lightslategrey:      "#778899"
    lightslategray:      "#778899"
    lightsteelblue:      "#b0c4de"
    lightyellow:         "#ffffe0"
    lime:                "#00ff00"
    limegreen:           "#32cd32"
    linen:               "#faf0e6"
    magenta:             "#ff00ff"
    maroon:              "#800000"
    mediumaquamarine:    "#66cdaa"
    mediumblue:          "#0000cd"
    mediumorchid:        "#ba55d3"
    mediumpurple:        "#9370db"
    mediumseagreen:      "#3cb371"
    mediumslateblue:     "#7b68ee"
    mediumspringgreen:   "#00fa9a"
    mediumturquoise:     "#48d1cc"
    mediumvioletred:     "#c71585"
    midnightblue:        "#191970"
    mintcream:           "#f5fffa"
    mistyrose:           "#ffe4e1"
    moccasin:            "#ffe4b5"
    navajowhite:         "#ffdead"
    navy:                "#000080"
    oldlace:             "#fdf5e6"
    olive:               "#808000"
    olivedrab:           "#6b8e23"
    orange:              "#ffa500"
    orangered:           "#ff4500"
    orchid:              "#da70d6"
    palegoldenrod:       "#eee8aa"
    palegreen:           "#98fb98"
    paleturquoise:       "#afeeee"
    palevioletred:       "#db7093"
    papayawhip:          "#ffefd5"
    peachpuff:           "#ffdab9"
    peru:                "#cd853f"
    pink:                "#ffc0cb"
    plum:                "#dda0dd"
    powderblue:          "#b0e0e6"
    purple:              "#800080"
    red:                 "#ff0000"
    rosybrown:           "#bc8f8f"
    royalblue:           "#4169e1"
    saddlebrown:         "#8b4513"
    salmon:              "#fa8072"
    sandybrown:          "#f4a460"
    seagreen:            "#2e8b57"
    seashell:            "#fff5ee"
    sienna:              "#a0522d"
    silver:              "#c0c0c0"
    skyblue:             "#87ceeb"
    slateblue:           "#6a5acd"
    slategrey:           "#708090"
    slategray:           "#708090"
    snow:                "#fffafa"
    springgreen:         "#00ff7f"
    steelblue:           "#4682b4"
    tan:                 "#d2b48c"
    teal:                "#008080"
    thistle:             "#d8bfd8"
    tomato:              "#ff6347"
    turquoise:           "#40e0d0"
    violet:              "#ee82ee"
    wheat:               "#f5deb3"
    white:               "#ffffff"
    whitesmoke:          "#f5f5f5"
    yellow:              "#ffff00"
    yellowgreen:         "#9acd32"

  @parseCache: parseCache = {}

  defaultAlpha = 1

  @rgbColor: rgbColor = (a, b, c, d) ->
    return a if !b? && isColor a
    return clr if isString(a) && clr = colorNamesMap[a] || parseCache[a]
    new Color a, b, c, d

  @rgb256Color: (a, b, c, d) ->
    return a if !b? && isColor a
    return clr if isString(a) && clr = colorNamesMap[a] || parseCache[a]
    defaultAlpha = 255
    out = new Color a, b, c, d
    defaultAlpha = 1
    out.r /= 255
    out.g /= 255
    out.b /= 255
    out.a /= 255
    out

  @newColor: rgbColor
  @color: (a, b, c, d) ->
    log.error "Atomic.color DEPRICATED. Use rgbColor."
    rgbColor a, b, c, d

  @hslColor: hslColor = (h, s, l, a = 1) ->
    return h if isColor h

    h = modulo h, 1
    phase = h * 6 | 0
    f = h * 6 - phase
    p = l * (1 - s)
    q = l * (1 - f * s)
    t = l * (1 - (1 - f) * s)
    h = if colorFloatEq(h, 1) then 1 else h % 1
    switch phase % 6
      when 0 then new Color l, t, p, a, h, s, l
      when 1 then new Color q, l, p, a, h, s, l
      when 2 then new Color p, l, t, a, h, s, l
      when 3 then new Color p, q, l, a, h, s, l
      when 4 then new Color t, p, l, a, h, s, l
      when 5 then new Color l, p, q, a, h, s, l

  @hsl2Rgb: (h, s, l) ->

    h = modulo h, 1
    phase = h * 6 | 0
    f = h * 6 - phase
    p = l * (1 - s)
    q = l * (1 - f * s)
    t = l * (1 - (1 - f) * s)
    h = if colorFloatEq(h, 1) then 1 else h % 1
    switch phase % 6
      when 0 then [l, t, p]
      when 1 then [q, l, p]
      when 2 then [p, l, t]
      when 3 then [p, q, l]
      when 4 then [t, p, l]
      when 5 then [l, p, q]

  @parse: (string, existing = null) ->
    throw new Error "existing feature is no longer supported" if existing
    new Artomic.Color string

  _initFromString: (string) ->
    @initProperties()
    parseCache[string] = @

    # hex16: #rgb or #rgba - where r, g, b, and a are hex digits
    if match = hex16ColorRegExp.exec string
      [x, r, g, b, a] = match
      @_htmlColorString = string unless a
      a ||= "f"
      @r = parseInt(r, 16)/15
      @g = parseInt(g, 16)/15
      @b = parseInt(b, 16)/15
      @a = parseInt(a, 16)/15

    else if match = hex16GreyColorRegExp.exec string
      @r = @g = @b = parseInt(match[1], 16) / 15
      @a = 1

    else if match = hex256GreyColorRegExp.exec string
      @r = @g = @b = parseInt(match[1], 16) / 255
      @a = 1

    # hex256: #rrggbb or #rrggbbaa - where r, g, b, and a are hex digits
    else if match = hex256ColorRegExp.exec string
      [x, r, g, b, a] = match
      @_htmlColorString = string unless a
      a ||= "ff"
      @r = parseInt(r, 16)/255
      @g = parseInt(g, 16)/255
      @b = parseInt(b, 16)/255
      @a = parseInt(a, 16)/255

    # rgb(red, green, blue) - values are 0-255
    else if elements = rgbColorRegExp.exec string
      @_htmlColorString = string
      @a = 1
      @r = parseRGBColorComponent elements[1]
      @g = parseRGBColorComponent elements[2]
      @b = parseRGBColorComponent elements[3]

    # rgba(red, green, blue, alpha) - rgb values are 0-255, alpha values are 0.0 - 1.0
    else if elements = rgbaColorRegExp.exec string
      @_htmlColorString = string
      @r = parseRGBColorComponent elements[1]
      @g = parseRGBColorComponent elements[2]
      @b = parseRGBColorComponent elements[3]
      @a = elements[4] - 0

    else if /^[a-z]+$/i.test(lcString = string.toLowerCase())
      unless clr = colorNamesMap[lcString]
        return log parseError:@parseError = "WARNING: Color.parse failure. Unknown rgbColor name: #{inspect string}"
      @_htmlColorString = clr._htmlColorString
      @r = clr.r
      @g = clr.g
      @b = clr.b
      @a = clr.a
    else if /^([a-f0-9]{3,4}|[a-f0-9]{6}|[a-f0-9]{8})$/i.test string
      @_initFromString "#" + string
    else
      log parseError:@parseError = "WARNING: Color.parse failure for #{inspect string}"

  initProperties: ->
    @r = @g = @b = 0
    @a = defaultAlpha
    @_hue = @_saturation = @_lightness = null
    @parseError = null
    @_htmlColorString = null

  # h, s, l are only included to preserve hue and sat when lightness is 0 or hue when saturation is 0
  _init: (a, b, c, d, h, s, l) ->
    @initProperties()
    @_hue = h - 0 if h?
    @_saturation = s - 0 if s?
    @_lightness = l - 0 if l?
    if !a?
      @r = @g = @b = 0
    else if !b?
      @r = @g = @b = a - 0
    else if c?
      @r = a - 0
      @g = b - 0
      @b = c - 0
      @a = d - 0 if d?

  eq: (_a, _b, _c, _d) ->
    switch
      when _a == @  then true
      when !_a?     then false
      when isNumber _a
        (_a == @r) &&
        (_b == @g) &&
        (_c == @b) &&
        ((_d ? 1) == @a)

      when _a.constructor == Color
        {r, g, b, a} = _a
        h = _a._hue
        s = _a._saturation
        l = _a._lightness
        h2 = @_hue
        s2 = @_saturation
        l2 = @_lightness
        (r == @r) &&
        (g == @g) &&
        (b == @b) &&
        (a == @a) &&
        (!h? || !h2? || h == h2) &&
        (!s? || !s2? || s == s2) &&
        (!l? || !l2? || l == l2)

      else false

  interpolate: (toColor, p) ->
    {r, g, b, a} = @

    # do we really need this???
    toColor = rgbColor toColor

    # make interpolation to/from 100% transparent nicer (rgbColor shouldn't change, only alpha)
    {r, g, b} = toColor if float32Eq0 a
    toColor = @withAlpha 0 if float32Eq0 toColor.a

    oneMinusP = 1 - p
    new Color(
      toColor.r * p + r * oneMinusP
      toColor.g * p + g * oneMinusP
      toColor.b * p + b * oneMinusP
      toColor.a * p + a * oneMinusP
    )

  blend: (color, amount) ->
    color = rgbColor color
    {r,g,b,a} = @
    switch
      when amount?
        new Color(
          (color.r - r) * amount + r
          (color.g - g) * amount + g
          (color.b - b) * amount + b
          (color.a - a) * amount + a
        )
      when colorFloatEq color.a, 1
        color
      when colorFloatEq color.a, 0
        @
      else
        amount = color.a
        new Color(
          (color.r - r) * amount + r
          (color.g - g) * amount + g
          (color.b - b) * amount + b
          (1 - a) * amount + a
        )

  withAlpha: (a) -> new Color @r, @g, @b, a
  withLightness: (v) -> hslColor @h, @s, v, @a
  withHue: (v) -> hslColor v, @s, @l, @a
  withHueShift: (amount) -> hslColor @h + amount, @s, @l, @a
  withSat: withSat = (v) -> hslColor @h, v, @l, @a
  withSaturation: withSat

  withScaledLightness:  (s) -> hslColor @h, @s, s * @l, @a
  withScaledSaturation: (s) -> hslColor @h, s * @s, @l, @a

  withScaledLAndS:  (l, s) -> hslColor @h, s * @s, l * @l, @a

  withChannel: (c, v) ->
    switch c
      when "r", "red" then new Color v, @g, @b, @a
      when "g", "green" then new Color @r, v, @b, @a
      when "b", "blue" then new Color @r, @g, v, @a
      when "h", "hue" then hslColor v, @s, @l, @a
      when "s", "sat", "saturation" then hslColor @h, v, @l, @a
      when "l", "lightness" then @withLightness v
      when "a", "alpha" then @withAlpha v
      else throw new Error "invalid channel: #{inspect c}"

  withChannels: (c) ->
    if c.h or c.s or c.l
      h = if c.h? then c.h else @h
      s = if c.s? then c.s else @s
      l = if c.l? then c.l else @l
      a = if c.a? then c.a else @a
      hslColor h, s, l, a
    else
      r = if c.r? then c.r else @r
      g = if c.g? then c.g else @g
      b = if c.b? then c.b else @b
      a = if c.a? then c.a else @a
      new Color r, g, b, a

  zeroString = "0"
  hexString = (number, length = 2) ->
    pad number.toString(16), length, zeroString, true

  @getter
    inspectedObjects: -> @
    # array: -> [@r, @g, @b, @a]
    arrayRGB: -> [@r, @g, @b]
    arrayRgb: -> [@r, @g, @b]
    arrayHsl: -> @_computeHsl() && [@_hue, @_saturation, @_lightness]

    rgbSum: -> @r + @g + @b
    rgbSquaredSum: -> @r*@r + @g*@g + @b*@b

    clamped: ->
      new Color(
        bound 0, @r, 1
        bound 0, @g, 1
        bound 0, @b, 1
        bound 0, @a, 1
      )

    r256: -> bound 0, Math.round(@r * 255), 255
    g256: -> bound 0, Math.round(@g * 255), 255
    b256: -> bound 0, Math.round(@b * 255), 255
    a256: -> bound 0, Math.round(@a * 255), 255

    r16: -> bound 0, Math.round(@r * 15), 15
    g16: -> bound 0, Math.round(@g * 15), 15
    b16: -> bound 0, Math.round(@b * 15), 15
    a16: -> bound 0, Math.round(@a * 15), 15

    h256: -> bound 0, Math.round(@h * 255), 255
    s256: -> bound 0, Math.round(@s * 255), 255
    b256: -> bound 0, Math.round(@b * 255), 255

    rClamped: -> bound 0, @r, 1
    gClamped: -> bound 0, @g, 1
    bClamped: -> bound 0, @b, 1
    aClamped: -> bound 0, @a, 1

    premultiplied: -> new Color @r * @a, @g * @a, @b * @a, @a
    demultiplied: -> new Color @r / @a, @g / @a, @b / @a, @a

    cssString: -> a = @aClamped; "rgba(" + [@r256, @g256, @b256, a.toFixed(3).replace(/\.?0+$/, '')].join(', ') + ")"
    rgbaString: -> "rgbColor(" + [@r256, @g256, @b256, @a256].join('/255, ') + "/255)"

    hexString: ->
      "#" + @rawHexString

    rgbaHexString: ->
      "#" + @getRawRgbaHexString()

    hex16String: ->
      "#" +
      hexString(@r16, 1) +
      hexString(@g16, 1) +
      hexString(@b16, 1)

    rgbaHex16String: -> @hex16String + hexString @a16, 1

    hslHexString: ->
      "#" +
      hexString(@h256) +
      hexString(@s256) +
      hexString(@b256)

    autoRgbaHexString: ->
      if colorFloatEq(1, @a) then   @getHexString()
      else                          @rgbaHexString

    rawHexString: ->
      hexString(@r256) +
      hexString(@g256) +
      hexString(@b256)

    rawRgbaHexString: -> @rawHexString + hexString @a256

  inspect: ->
    a = if colorFloatEq(1, @a) then @hexString else @rgbaHexString
    "rgbColor('#{a}')"

  toString: ->
    @_htmlColorString ||=
    if colorFloatEq(1, @a) then @getHexString()
    else                         @getCssString()


  # OUT: number between -.5 and .5
  getHueDelta: (c) ->
    d = @hue - c.hue
    if d < -.5 then d + 1
    else if d > .5 then d - 1
    else d

  getHueDifference: (c) -> Math.abs @getHueDelta c

  @getter
    plainObjects: -> if @a < 1 then @rgbaHexString else @hexString
    inspectedObjectInitializer: -> "'#{@autoRgbaHexString}'"

  # vivafy HSL on request
  @getter
    h:          -> @_hue        ?= @_computeHsl() && @_hue
    s:          -> @_saturation ?= @_computeHsl() && @_saturation
    l:          -> @_lightness  ?= @_computeHsl() && @_lightness
    inverseL:   -> 1 - @l
    inverseS:   -> 1 - @s
    inverseH:   -> 1 - @h
    hue:        -> @_hue        ?= @_computeHsl() && @_hue
    sat:        -> @_saturation ?= @_computeHsl() && @_saturation
    lit:        -> @_lightness  ?= @_computeHsl() && @_lightness
    saturation: -> @_saturation ?= @_computeHsl() && @_saturation
    lightness:  -> @_lightness  ?= @_computeHsl() && @_lightness
    perceptualLightness: ->
      {r, g, b} = @

      rWeighted = r * rWeight = .7
      gWeighted = g * gWeight = .8
      bWeighted = b * bWeight = .3

      if gWeighted >= rWeighted && gWeighted >= bWeighted
        gWeighted + (r + b) * .5 * (1 - gWeight)
      else if bWeighted >= rWeighted && bWeighted >= gWeighted
        bWeighted + (r + g) * .5 * (1 - bWeight)
      else
        rWeighted + (g + b) * .5 * (1 - rWeight)

    # this decreases the saturation for very dark values
    perceptualSaturation: -> Math.pow(@perceptualLightness, 1/3) * @saturation

    satLightness: -> (2 - @_saturation) * @_lightness * .5

  _computeHsl: ->
    return true if @_hue?
    {r, g, b} = @

    maxRgb = @_lightness = max r, g, b
    minRgb               = min r, g, b

    @_hue = if maxRgb == minRgb
      @_saturation = 0

    else
      @_saturation = 1 - (minRgb / maxRgb)    # maxRgb is > 0 since maxRgb != minRgb

      delta = maxRgb - minRgb

      switch maxRgb
        when r then (g - b) / delta + (if g >= b then 0 else 6)
        when g then (b - r) / delta + 2
        when b then (r - g) / delta + 4

    @_hue /= 6

    true

  for k, v of colorNamesMap
    colorNamesMap[k] = rgbColor v

  @namedValues: colorNamesMap
