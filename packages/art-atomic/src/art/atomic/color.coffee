Foundation = require 'art.foundation'
AtomicBase = require './base'
{
  inspect, bound, modulo, pad, min, max, abs, float32Eq, isString, log

  hex16ColorRegex
  hex256ColorRegex
  rgbColorRegex
  rgbaColorRegex
} = Foundation

colorFloatEq = float32Eq #(n1, n2) -> Math.abs(n1 - n2) < 1/256

parseRGBColorComponent = (str) ->
  if (percentIndex = str.indexOf('%'))!= -1
    (str.slice(0, percentIndex)|0) * .01
  else
    (str|0) * 1/255

module.exports = class Color extends AtomicBase
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

  @color: color = (a, b, c, d) ->
    return a if !b? && (a instanceof Color)
    return clr if isString(a) && clr = colorNamesMap[a] || parseCache[a]
    new Color a, b, c, d

  @hslColor: hslColor = (h, s, l, a = 1) ->
    return h if h instanceof Color

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

  @parse: (string, existing = null) ->
    throw new Error "existing feature is no longer supported" if existing
    new Artomic.Color string

  _initFromObject: (obj) ->
    {@r, @g, @b, @a} =  obj
    # @r = obj.r
    # log Color: _initFromObject: @rgbaHexString
    # throw new Error "init from object not supported: #{inspect obj}"

  _initFromString: (string) ->
    @initProperties()
    parseCache[string] = @

    # hex16: #rgb or #rgba - where r, g, b, and a are hex digits
    if match = string.match hex16ColorRegex
      [x, r, g, b, a] = match
      @_htmlColorString = string unless a
      a ||= "f"
      @r = parseInt(r, 16)/15
      @g = parseInt(g, 16)/15
      @b = parseInt(b, 16)/15
      @a = parseInt(a, 16)/15

    # hex256: #rrggbb or #rrggbbaa - where r, g, b, and a are hex digits
    else if match = string.match hex256ColorRegex
      [x, r, g, b, a] = match
      @_htmlColorString = string unless a
      a ||= "ff"
      @r = parseInt(r, 16)/255
      @g = parseInt(g, 16)/255
      @b = parseInt(b, 16)/255
      @a = parseInt(a, 16)/255

    # rgb(red, green, blue) - values are 0-255
    else if elements = string.match rgbColorRegex
      @_htmlColorString = string
      @a = 1
      @r = parseRGBColorComponent elements[1]
      @g = parseRGBColorComponent elements[2]
      @b = parseRGBColorComponent elements[3]

    # rgba(red, green, blue, alpha) - rgb values are 0-255, alpha values are 0.0 - 1.0
    else if elements = string.match rgbaColorRegex
      @_htmlColorString = string
      @r = parseRGBColorComponent elements[1]
      @g = parseRGBColorComponent elements[2]
      @b = parseRGBColorComponent elements[3]
      @a = elements[4] - 0

    else if /^[a-z]+$/i.test(lcString = string.toLowerCase())
      unless clr = colorNamesMap[lcString]
        return @log parseError:@parseError = "WARNING: Color.parse failure. Unknown color name: #{inspect string}"
      @_htmlColorString = clr._htmlColorString
      @r = clr.r
      @g = clr.g
      @b = clr.b
      @a = clr.a
    else
      @log parseError:@parseError = "WARNING: Color.parse failure for #{inspect string}"

  initProperties: ->
    @r = @g = @b = 0
    @a = 1
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
      @a = 1
    else if !b?
      a /= 255 if a > 1
      @r = @g = @b = a - 0
      @a = 1 - 0
    else if c?
      if a > 1 || b > 1 || c > 1
        a /= 255
        b /= 255
        c /= 255
      @r = a - 0
      @g = b - 0
      @b = c - 0
      @a = if d? then d - 0 else 1

  # all operators are performed component-wise
  # operator signatures:
  #  myColor.add myOtherColor # add by components
  #  myColor.add v            # one number to add to all
  #  myColor.add r, g, b, a   # 4 numbers
  add: (r, g, b, a) -> if r instanceof Color then color(@r + r.r, @g + r.g, @b + r.b, @a + r.a) else if g? then color(@r + r, @g + g, @b + b, @a + a) else color(@r + r, @g + r, @b + r, @a + r)
  sub: (r, g, b, a) -> if r instanceof Color then color(@r - r.r, @g - r.g, @b - r.b, @a - r.a) else if g? then color(@r - r, @g - g, @b - b, @a - a) else color(@r - r, @g - r, @b - r, @a - r)
  mul: (r, g, b, a) -> if r instanceof Color then color(@r * r.r, @g * r.g, @b * r.b, @a * r.a) else if g? then color(@r * r, @g * g, @b * b, @a * a) else color(@r * r, @g * r, @b * r, @a * r)
  div: (r, g, b, a) -> if r instanceof Color then color(@r / r.r, @g / r.g, @b / r.b, @a / r.a) else if g? then color(@r / r, @g / g, @b / b, @a / a) else color(@r / r, @g / r, @b / r, @a / r)

  interpolate: (toColor, p) ->
    toColor = color toColor
    oneMinusP = 1 - p
    new Color(
      toColor.r * p + @r * oneMinusP
      toColor.g * p + @g * oneMinusP
      toColor.b * p + @b * oneMinusP
      toColor.a * p + @a * oneMinusP
    )

  blend: (r, amount) -> r.sub(@).mul(amount).add @
  withAlpha: (a) -> new Color @r, @g, @b, a
  withLightness: (v) -> hslColor @h, @s, v, @a
  withHue: (v) -> hslColor v, @s, @l, @a
  withSat: (v) -> hslColor @h, v, @l, @a

  withChannel: (c, v) ->
    switch c
      when "r" then new Color v, @g, @b, @a
      when "g" then new Color @r, v, @b, @a
      when "b" then new Color @r, @g, v, @a
      when "h" then hslColor v, @s, @l, @a
      when "s" then hslColor @h, v, @l, @a
      when "l" then @withLightness v
      when "a" then @withAlpha v
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

  @getter
    array: -> [@r, @g, @b, @a]
    arrayRGB: -> [@r, @g, @b]
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

    cssString: -> "rgba(" + [@r256, @g256, @b256, @aClamped].join(', ') + ")"
    rgbaString: -> "color(" + [@r256, @g256, @b256, @a256].join('/255, ') + "/255)"

    hexString: ->
      "#" +
      pad(@r256.toString(16), 2) +
      pad(@g256.toString(16), 2) +
      pad(@b256.toString(16), 2)

    hex16String: ->
      "#" +
      pad(@r16.toString(16), 1) +
      pad(@g16.toString(16), 1) +
      pad(@b16.toString(16), 1)

    hslHexString: ->
      "#" +
      pad(@h256.toString(16), 2) +
      pad(@s256.toString(16), 2) +
      pad(@b256.toString(16), 2)

    rgbaHexString: ->
      "#" +
      pad(@r256.toString(16), 2) +
      pad(@g256.toString(16), 2) +
      pad(@b256.toString(16), 2) +
      pad(@a256.toString(16), 2)

  eq: (r) ->
    return true if @ == r
    r and
    colorFloatEq(@r, r.r) and
    colorFloatEq(@g, r.g) and
    colorFloatEq(@b, r.b) and
    colorFloatEq(@a, r.a)

  lt: (r) -> @r < r.r and @b < r.b and @c < r.c and @a < r.a
  gt: (r) -> @r > r.r and @b > r.b and @c > r.c and @a > r.a
  lte: (r) -> @r <= r.r and @b <= r.b and @c <= r.c and @a <= r.a
  gte: (r) -> @r >= r.r and @b >= r.b and @c >= r.c and @a >= r.a

  getInspectedString: ->
    a = if colorFloatEq(1, @a) then @hexString else @rgbaHexString
    "color('#{a}')"

  toString: ->
    @_htmlColorString ||=
    if colorFloatEq(1, @a) then @getHexString()
    else                         @getCssString()

  toArray: toArray = -> [@r, @g, @b, @a]
  toPlainStructure: -> r: @r, g: @g, b: @b, a: @a
  toPlainEvalString: -> "{r:#{@r}, g:#{@g}, b:#{@b}, a:#{@a}}"

  # vivafy HSL on request
  @getter
    h:          -> @_hue        ?= @rgbToHsl() && @_hue
    s:          -> @_saturation ?= @rgbToHsl() && @_saturation
    l:          -> @_lightness  ?= @rgbToHsl() && @_lightness
    inverseL:   -> 1 - @l
    inverseS:   -> 1 - @s
    inverseH:   -> 1 - @h
    hue:        -> @_hue        ?= @rgbToHsl() && @_hue
    sat:        -> @_saturation ?= @rgbToHsl() && @_saturation
    lit:        -> @_lightness  ?= @rgbToHsl() && @_lightness
    saturation: -> @_saturation ?= @rgbToHsl() && @_saturation
    lightness:  -> @_lightness  ?= @rgbToHsl() && @_lightness
    perceptualLightness: -> 0.2126*@r + 0.7152*@g + 0.0722*@b
    satLightness: -> (2 - @_saturation) * @_lightness * .5


  @perceptualWeights:
    r: 0.2126
    g: 0.7152
    b: 0.0722

  rgbToHsl: ->
    r = @r
    g = @g
    b = @b
    maxRGB = max r, g, b
    minRGB = min r, g, b
    delta = maxRGB - minRGB
    sixth = 1.0 / 6.0

    # Calculate Brightness
    @_lightness = maxRGB

    # Calculate Hue
    if maxRGB == minRGB
      @_hue = 0
      @_saturation = 0
      return true

    if maxRGB == r
      if g >= b then          @_hue = sixth * ((g - b) / delta)           # maxRGB == r, g >= b
      else                    @_hue = sixth * ((g - b) / delta) + 1       # maxRGB == r, g < b
    else if maxRGB == g then  @_hue = sixth * ((b - r) / delta) + 1 / 3   # maxRGB == g
    else                      @_hue = sixth * ((r - g) / delta) + 2 / 3   # maxRGB == b

    # Calculate Satuartion
    @_saturation = 1 - (minRGB / maxRGB)    # maxRGB is > 0 since maxRGB != minRGB

    true

  for k, v of colorNamesMap
    colorNamesMap[k] = color v
