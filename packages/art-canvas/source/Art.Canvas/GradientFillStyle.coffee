# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
# http://www.html5canvastutorials.com/tutorials/html5-canvas-linear-gradients/
Atomic = require 'art-atomic'
Foundation = require 'art-foundation'
{point, rgbColor, point1} = Atomic
{inspect, shallowClone, flatten, isPlainObject, log, isNumber, isString, isPlainArray, clone, min
  floatEq, peek, arrayWith
  bound
} = Foundation

module.exports = class GradientFillStyle extends Foundation.BaseObject

  ###
  from and to are points where the lineary gradient will begin and end.
  "colors" is a list of the colors for the gradient. There must be at least two colors.
  In the explicit form, each rgbColor should be formatted as {n:<number>, c:<html rgbColor string>}
    Ex: {n:.45, c:"#ff0"}
  Implicitly, you can:
    provide just a HTML rgbColor string with no "n".
    N is determined as follows:
      The first and last rgbColor will be forced to have n=0 and n=1 respectively
      Any string of omitted Ns will be interpolated between the specified ns.

  Examples:
    black to white:
      new GradientFillStyle point(0,0), point(100,0), {c:"#000"}, {c:"#fff"}
      OR
      new GradientFillStyle point(0,0), point(100,0), "#000", "#fff"

    black to red to white:
      new GradientFillStyle point(0,0), point(100,0), {c:"#000"}, {n:.5, c:"#f00"}, {c:"#fff"}
      OR
      new GradientFillStyle point(0,0), point(100,0), "#000", "#f00", "#fff"

    red to transparent
      new GradientFillStyle point(0,0), point(100,0), #f00", "rgba(1,0,0,0)"

    rainbow:
      new GradientFillStyle(
        point(0,0), point(100,0)
        "#f00"
        "#ff0"
        "#0f0"
        "#0ff"
        "#00f"
        "#f0f"
        "#f00"
      )
  ###
  @colorsToObjectsAndColorObjects: (colors) ->
    for clr in colors
      if isPlainObject clr
        n: clr.n
        c: rgbColor clr.c
      else
        c: rgbColor clr

  @colorsFromObjects: (colors) ->
    ret = []
    for clr in colors
      if isPlainObject clr
        if isNumber clr.r
          ret.push rgbColor clr
        else if isNumber clr.n
          ret.push clr
        else
          for k, c of clr
            n = k - 0
            ret.push
              n: n
              c: c
      else
        ret.push clr
    ret

  @interpolateColorPositionRange: (
      outColors
      colors
      start
      end
      firstN # inclusive
      lastN  # exclusive
      ) ->
    steps = end - start + 1
    nDelta = (lastN-firstN)/steps
    for i in [start...end]
      outColors.push
        c: colors[i].c
        n: (i - start + 1) * nDelta

  @needToInterpolateColors: (colors) =>
    ret = false
    for clr in colors when !clr.n?
      ret = true;break;
    ret

  @interpolateColorPositions: (colors) =>
    return colors unless @needToInterpolateColors colors
    [firstColor, ..., lastColor] = colors
    firstColor = c: firstColor.c, n: 0 unless firstColor.n?
    lastColor  = c: lastColor.c , n: 1 unless lastColor.n?

    outColors = [firstColor]

    startN = firstColor.n

    interpolateCount = 0
    for clr, i in colors when i > 0
      clr = lastColor if i == colors.length - 1
      {n} = clr
      if n?
        if interpolateCount > 0
          @interpolateColorPositionRange outColors,
            colors
            i - interpolateCount
            i
            startN
            n
          interpolateCount = 0
        startN = n
      else
        interpolateCount++

    outColors.push lastColor
    outColors

  @sortColorsByN: (colors) ->
    colors.sort (a, b) -> a.n - b.n

  @normalizeColors: (colors) ->
    if isPlainArray colors
      @sortColorsByN @interpolateColorPositions @colorsToObjectsAndColorObjects @colorsFromObjects colors
    else if isPlainObject colors
      colors = for k, v of colors
        n: k * 1
        c: if isString v then v else String rgbColor v
      @interpolateColorPositions @sortColorsByN colors
    else
      [
        n: 0, c: rgbColor "black"
        n: 1, c: rgbColor "white"
      ]

  constructor: (@from, @to, colors, @radius1, @radius2)->
    @setColors @inputColors = colors

  inspect2: -> "gradient(from:#{@from}, to:#{@to}, colors:#{inspect @inputColors})"

  @clone: ->
    new GradientFillStyle @from, @to, shallowClone(@colors), @radius1, @radius2

  @getter
    colors: -> @_colors
    premultipliedColorPositions: ->
      for a in @_colors
        n:a.n
        c:rgbColor(a.c).premultiplied

  @setter
    colors: (colors) ->
      @_colors = if isPlainArray colors
        GradientFillStyle.normalizeColors colors
      else if isPlainObject colors
        colors = for k, v of colors
          n: k * 1
          c: if isString v then v else String rgbColor v
        colors = GradientFillStyle.sortColorsByN colors
        GradientFillStyle.interpolateColorPositions colors
      else
        [
          n: 0, c: rgbColor "black"
          n: 1, c: rgbColor "white"
        ]

  getColorAt: (atN) ->
    lastN = null
    lastC = null
    for {c, n}, i in @colors
      if atN <= n
        return if lastC
          range = n - lastN
          rgbColor(lastC).interpolate c, (atN - lastN) / range
        else
          c
      lastC = c
      lastN = n
    null

  toCanvasStyle: (context)->
    context = context.context if context.context
    gradient = if @radius1?
      if @radius2?
        {radius1, radius2} = @
      else
        radius1 = 0
        radius2 = @radius1

      context.createRadialGradient(
        @from.x
        @from.y
        radius1
        @to.x
        @to.y
        radius2
      )
    else
      context.createLinearGradient(
        @from.x
        @from.y
        @to.x
        @to.y
      )
    for clr in @_colors
      n = bound 0, clr.n, 1
      try
        gradient.addColorStop n, clr.c.toString()
      catch e
        gradient.addColorStop n, "black"

    gradient
