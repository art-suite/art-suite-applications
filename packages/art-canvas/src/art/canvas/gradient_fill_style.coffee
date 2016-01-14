# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
# http://www.html5canvastutorials.com/tutorials/html5-canvas-linear-gradients/
define [
  'art.atomic'
  'art.foundation'
  ], (Atomic, Foundation) ->
  {point, color, point1} = Atomic
  {inspect, shallowClone, flatten, isPlainObject, log, isNumber, isString, isPlainArray} = Foundation

  class GradientFillStyle extends Foundation.BaseObject

    ###
    from and to are points where the lineary gradient will begin and end.
    "colors" is a list of the colors for the gradient. There must be at least two colors.
    In the explicit form, each color should be formatted as {n:<number>, c:<html color string>}
      Ex: {n:.45, c:"#ff0"}
    Implicitly, you can:
      provide just a HTML color string with no "n".
      N is determined as follows:
        The first and last color will be forced to have n=0 and n=1 respectively
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
          c: String color clr.c
        else
          c: String color clr

    @colorsFromObjects: (colors) ->
      ret = []
      for clr in colors
        if isPlainObject clr
          if isNumber clr.r
            ret.push color clr
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
      colors[0].n = 0
      colors[colors.length-1].n = 1

      lastNindex = 0
      for clr, i in colors
        if clr.n
          @interpolateColorPositionRange colors, lastNindex, i
          lastNindex = i

      colors

    @sortColorsByN: (colors) ->
      colors.sort (a, b) -> a.n - b.n

    @normalizeColors: (colors) ->
      colors = @colorsFromObjects colors
      colors = @colorsToObjectsAndStringColors colors
      colors = @sortColorsByN colors
      colors = @interpolateColorPositions colors
      colors

    constructor: (from, to, colors, scale)->
      @scale = scale || point1
      @from = from
      @to = to
      @setColors @inputColors = colors

    inspect2: -> "gradient(from:#{@from}, to:#{@to}, colors:#{inspect @inputColors})"

    @clone: ->
      new GradientFillStyle @from, @to, shallowClone @colors

    @getter
      colors: -> @_colors
      premultipliedColorPositions: ->
        for a in @_colors
          n:a.n
          c:color(a.c).premultiplied

    @setter
      colors: (colors) ->
        @_colors = if isPlainArray colors
          GradientFillStyle.normalizeColors colors
        else if isPlainObject colors
          colors = for k, v of colors
            n: k * 1
            c: if isString v then v else String color v
          colors = GradientFillStyle.sortColorsByN colors
          GradientFillStyle.interpolateColorPositions colors
        else
          [
            n: 0, c: color "black"
            n: 1, c: color "white"
          ]

    toCanvasStyle: (context)->
      context = context.context if context.context
      {x, y} = @scale
      gradient = context.createLinearGradient(
        @from.x * x
        @from.y * y
        @to.x * x
        @to.y * y
      )
      for clr in @_colors
        gradient.addColorStop clr.n, clr.c
      gradient
