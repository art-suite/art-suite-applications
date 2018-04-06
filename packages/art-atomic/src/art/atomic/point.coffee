# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# NOTE: Point should implement the same API as Rectangle.
# Such methods should work as-if implemented like this:
#    method: (args...) -> new Rectangle(0, 0, @w, @h).method args...

Foundation = require 'art-foundation'
AtomicBase = require './base'
Namespace = require './namespace'
{
  inspect, bound, floatEq, log, isNumber, isArray, isString, isFunction, stringToNumberArray, nearInfinity
  inspectedObjectLiteral
} = Foundation
{abs, sqrt, atan, PI, floor, ceil, round, min, max} = Math

###
point() general point constructor

IN: (p:Point)
OUT: p

IN: ()
IN: ([])
OUT: point 0, 0

IN: (string)
OUT: Point.namedPoints[string] || Point.parse string

IN: (s:number)
IN: ([s:number])
OUT: new Point s, s

IN: (x:number, y:number)
IN: ([x:number, y:number])
OUT: new Point x, y

IN: ({x:number, y:number})
OUT: new Point x || 0, y || 0

IN: ({aspectRatio: number, area: number})
  aspectRatio: number representing: width / height
  area: number representing the square-area desired
OUT:
  a point, p, with:
    p.area == o.area
    p.aspectRatio == o.aspectRatio

###
module.exports = class Point extends AtomicBase
  @defineAtomicClass fieldNames: "x y"
  @isPoint: isPoint = (v) -> v?.constructor == Point

  pointWithAspectRatioAndArea = ({aspectRatio, area}) ->
    sqrtArea = Math.sqrt area / aspectRatio
    point(
      sqrtArea * aspectRatio
      sqrtArea
    )

  @point: point = (a, b) ->
    # just return if a already a Point
    return a if isPoint a
    if isString(a) && p = namedPoints[a]
      return p

    # pointWithAspectRatioAndArea
    if a?.aspectRatio && a.area >= 0
      return pointWithAspectRatioAndArea a

    # reuse point0 and point1
    x = a || 0
    y = if b? then b else a

    return point0 if point0.eq x, y
    return point1 if point1.eq x, y

    # construct new Point
    new Point a, b

  @parse: (string, existing) ->
    throw new Error "existing feature is no longer supported" if existing
    new Point string

  _init: (x, y) ->
    x ||= 0
    y = x unless y?
    @x = x - 0
    @y = y - 0

  _initFromObject: (o) ->
    @x = o.x || 0
    @y = o.y || 0

  @getter
    exportedValue: ->
      {x, y} = @
      if x == y
        x
      else
        out = {}
        out.x = x if x != 0
        out.y = y if y != 0
        out
    top: -> 0
    left: -> 0

    right: -> @x
    bottom: -> @y
    centerX: -> @x * .5
    centerY: -> @y * .5
    hCenter: -> @getCenterX()
    vCenter: -> @getCenterY()

    # abbreviated corner names
    tl: -> point0
    tc: -> @mul 0.5,  0
    tr: -> @mul 1  ,  0
    lc: -> @mul 0  ,  0.5
    cc: -> @mul 0.5,  0.5
    rc: -> @mul 1  ,  0.5
    bl: -> @mul 0  ,  1
    bc: -> @mul 0.5,  1
    br: -> @

    # corners combined with .neg
    ccNeg: -> @mul -0.5

    # full corner names
    topLeft:      -> point0
    topCenter:    -> @mul 0.5,  0
    topRight:     -> @mul 1  ,  0
    centerLeft:   -> @mul 0  ,  0.5
    centerCenter: -> @mul 0.5,  0.5
    centerRight:  -> @mul 1  ,  0.5
    bottomLeft:   -> @mul 0  ,  1
    bottomCenter: -> @mul 0.5,  1
    bottomRight:  -> @

    w: -> @x
    width: -> @x
    h: -> @y
    height: -> @y
    neg:      -> new Point -@x, -@y
    inv:      -> new Point 1.0/@x, 1.0/@y
    vector:   -> [@x, @y]
    magnitudeSquared: -> @x * @x + @y * @y
    magnitude: -> sqrt @x * @x + @y * @y
    aspectRatio: -> @x / @y
    absoluteAspectRatio: -> abs @x / @y
    swapped:  -> point @y, @x
    rounded:  -> @round()
    floored:  -> @floor()
    ceiled:   -> @ceil()
    area:     -> @x * @y
    sum:      -> @x + @y
    size:     -> @
    location: -> point0
    abs: -> @with abs(@x), abs(@y)
    unitVector: -> m = 1 / @magnitude; new Point @x * m, @y * m

    perpendicularVector:     -> new Point @y, -@x
    unitPerpendicularVector: -> m = 1 / @magnitude; new Point @y * m, -@x * m

    angle: ->
      if @x == 0 # special case where X is zero (would cause div0 errors)
        PI * if @y > 0 then .5 else 1.5
      else
        if @x > 0 then atan @y / @x
        else           atan(@y / @x) + PI

    isInteger: -> floatEq(@x, @x|0) && floatEq(@y, @y|0)

  distance: (p2) -> sqrt @distanceSquared p2
  distanceSquared: (p2) ->
    x = @x - p2.x
    y = @y - p2.y
    x * x + y * y

  withArea: (newArea) ->
    {area} = @
    throw new Error "area must be > 0" unless area > 0 && newArea >= 0
    @mul Math.sqrt newArea / area

  vectorLength: 2

  # convert to array index given a known lineStride
  toIndex: (lineStride) -> ~~@y * lineStride + ~~@x

  # return true of p is inside: new Rectangle(@)
  contains: (p) -> p.x >= 0 && p.y >=0 && p.x < @x & p.y < @y

  nearestInsidePoint: (p) -> @with bound(0, p.x, @x), bound(0, p.y, @y)

  appendToVector: (vector) ->
    l = vector.length
    vector[l+1] = @y
    vector[l] = @x

  dot: (p) -> @x * p.x + @y * p.y
  cross: (p) -> @x * p.y - @y * p.x

  floor: -> @with floor(@x), floor(@y)
  ceil:  -> @with ceil(@x),  ceil(@y)

  # b is point or rect
  union: (b) -> if isPoint b then @max(b) else b.union @
  intersection: (b) -> if isPoint b then @min(b) else b.intersection @

  min: (b = null) ->
    if b
      @with min(@x, b.x), min(@y, b.y)
    else
      min(@x, @y)

  max: (b = null) ->
    if b
      @with max(@x, b.x), max(@y, b.y)
    else
      max(@x, @y)

  average: (b = null) ->
    if b
      @with (@x + b.x) / 2, (@y + b.y) / 2
    else
      (@x + @y) / 2

  bound: (a, b) ->  @with bound(a.x, @x, b.x), bound(a.y, @y, b.y)
  round: (m = 1) -> @with round(@x / m) * m, round(@y / m) * m

  roundOut: -> @ceil()

  ###
  OUT:
    out.aspectRatio == @aspectRatio
    out <= into
    out.x == into.x or out.y == into.y
  proposed rename: scaledJustLte
  ###
  fitInto: (into) ->
    return @ unless into?
    if isNumber into
      x = y = into
    else
      {x, y} = into
    xr = x / @x
    yr = y / @y
    @mul min xr, yr

  ###
  OUT:
    out.aspectRatio == @aspectRatio
    out >= into
    out.x == into.x or out.y == into.y

  KEYWORD: I used to call this 'zoom'
  proposed rename: scaledJustGte
  ###
  fill: (into) ->
    if isNumber into
      x = y = into
    else
      {x, y} = into
    xr = x / @x
    yr = y / @y
    @mul max xr, yr

  ###
  OUT:
    out.aspectRatio == @aspectRatio
    out.area == p.area
  ###
  withSameAreaAs: (p) ->
    @mul Math.sqrt p.area / @area

  withAspectRatio: (aspectRatio) ->
    return @ if floatEq aspectRatio, @aspectRatio
    point {aspectRatio, @area}

  withRect: (a,b,c,d) ->
    if d? && a == 0 && b == 0
      @with c, d
    else
      Namespace.rect a,b,c,d

  minRatio: (b) -> min @x / b.x, @y / b.y
  maxRatio: (b) -> max @x / b.x, @y / b.y

  ##################
  # Named Instances
  ##################
  point0       = Object.freeze new Point 0
  point1       = Object.freeze new Point 1
  topRight     = Object.freeze new Point 1  ,  0
  topCenter    = Object.freeze new Point 0.5,  0
  centerLeft   = Object.freeze new Point 0  ,  0.5
  centerCenter = Object.freeze new Point 0.5
  bottomLeft   = Object.freeze new Point 0  ,  1
  @namedPoints: namedPoints =
    point0:                 point0
    point1:                 point1
    topLeft:                point0
    topCenter:              topCenter
    topRight:               topRight
    centerLeft:             centerLeft
    centerCenter:           centerCenter
    centerRight:            Object.freeze new Point 1  ,  0.5
    bottomLeft:             bottomLeft
    bottomCenter:           Object.freeze new Point 0.5,  1
    bottomRight:            point1
    pointNearInfinity:      Object.freeze new Point nearInfinity
    # provided for layout alignment options
    # top & left are the default for the unspecified coordinates
    left:                   point0
    center:                 topCenter
    right:                  topRight
    top:                    point0
    bottom:                 bottomLeft

  for k, v of @namedPoints
    @[k] = v
