# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
# http://www.html5canvastutorials.com/tutorials/html5-canvas-linear-gradients/
Atomic = require 'art-atomic'
Foundation = require 'art-foundation'
{point, rgbColor, point1} = Atomic
{inspect, shallowClone, flatten, isPlainObject, log, isNumber, isString, isPlainArray, clone, min
  floatEq, peek, arrayWith
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
  @colorsToObjectsAndStringColors: (colors) ->
    for clr in colors
      if isPlainObject clr
        n: clr.n
        c: String rgbColor clr.c
      else
        c: String rgbColor clr

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

  @interpolateColorPositionRange: (colors, start, end) ->
    steps = end - start
    firstN = colors[start].n
    lastN = colors[end].n
    nDelta = (lastN-firstN)/steps
    n = firstN + nDelta
    i = start + 1
    while i < end
      colors[i].n = n
      n += nDelta
      i++

  @interpolateColorPositions: (colors) =>
    firstColor = colors[0]
    lastColor = peek colors
    firstColor.n = 0  unless isNumber firstColor.n
    lastColor.n  = 1  unless isNumber lastColor.n

    lastNindex = 0
    for clr, i in colors
      if clr.n
        @interpolateColorPositionRange colors, lastNindex, i
        lastNindex = i

    {n, c} = firstColor
    colors = [n: 0, c: c].concat colors    unless floatEq n, 0
    {n, c} = lastColor
    colors = arrayWith colors, n: 1, c: c  unless floatEq n, 1

    colors

  @sortColorsByN: (colors) ->
    colors.sort (a, b) -> a.n - b.n

  @normalizeColors: (colors) ->
    colors = @colorsFromObjects colors
    colors = @colorsToObjectsAndStringColors colors
    colors = @sortColorsByN colors
    colors = @interpolateColorPositions colors
    colors

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
      try
        gradient.addColorStop clr.n, clr.c
      catch e
        gradient.addColorStop clr.n, "black"

    gradient
