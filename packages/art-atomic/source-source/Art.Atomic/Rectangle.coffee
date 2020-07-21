Atomic      = require './namespace' # required so we can break the circular dependency between Matrix and Rectangle
AtomicBase  = require './Base'
Point       = require './Point'

{
  max, min, bound,
  round, floatEq, floor, ceil, round, log,
  isNumber, isArray, isString, isFunction
  stringToNumberArray
  floatEq0
  float32Precision
  floatLt
  floatGt
  floatGte
  floatLte
} = require 'art-standard-lib'
{point, isPoint} = Point

# Rectangle supported constructor input signatures:
# (string / toString[able]) -> split on ',' and converted to numbers, then interperted as arguments
# (array) -> reinterpreted as arguments
# arguments:
#   0 arguments:         ()                -> (0, 0, 0, 0)
#   1 point argument:    (size)            -> (0, 0, size.x, size.y)
#   2 point arguments:   (location, size)  -> (location.x, location.y, size.x, size.y)
#   1 number argument:   (s)               -> (0, 0, s, s)
#   2 number argument:   (w, h)            -> (0, 0, w, h)
#   4 number arguments:  (x, y, w, h)
module.exports = class Rectangle extends AtomicBase
  @defineAtomicClass fieldNames: "x y w h", constructorFunctionName: "rect"
  @isRect: isRect = (v) -> v?.constructor == Rectangle

  @rect: rect = (a, b, c, d) ->
    return a if isRect a
    new Rectangle a, b, c, d

  _initFromObject: (obj) ->
    @x = @y = @w = @h = 0 # ensure consistent object construction
    {size, center} = obj
    if size
      if isNumber size
        x = y = size
      else
        {x, y} = size
      @w = x
      @h = y
    else
      @w = @h = 1

    if center
      if isNumber center
        x = y = center
      else
        {x, y} = center
      @x = x - @w / 2
      @y = y - @h / 2

    {x, y, w, h} = obj
    @x = x if x?
    @y = y if y?
    @w = w if w?
    @h = h if h?

  _init: (a, b, c, d) ->
    @x = @y = @w = @h = 0 # ensure consistent object construction
    if d?
      @x = a - 0
      @y = b - 0
      @w = c - 0
      @h = d - 0
    else if b?
      if isPoint b
        @x = a.x
        @y = a.y
        @w = b.w
        @h = b.h
      else
        @w = a - 0
        @h = b - 0
    else if isPoint a
      @w = a.w
      @h = a.h
    else if a?
      @w = @h = a - 0

  @getter
    aspectRatio: -> @w / @h
    location: -> new Point @x, @y
    locationMatrix: -> Atomic.Matrix.translateXY @x, @y
    size: -> new Point @w, @h
    # x: -> @x
    # y: -> @y
    # w: -> @w
    # h: -> @h
    width:  -> @w
    height: -> @h
    rounded: -> @with(
      round @x
      round @y
      round @w
      round @h
    )

    # abbreviated corner names
    tl: -> new Point @x,        @y
    tc: -> new Point @hCenter,  @y
    tr: -> new Point @right,    @y
    lc: -> new Point @x,        @vCenter
    cc: -> new Point @hCenter,  @vCenter
    rc: -> new Point @right,    @vCenter
    bl: -> new Point @x,        @bottom
    bc: -> new Point @hCenter,  @bottom
    br: -> new Point @right,    @bottom

    # full corner names
    topLeft:      -> new Point @x,        @y
    topCenter:    -> new Point @hCenter,  @y
    topRight:     -> new Point @right,    @y
    centerLeft:   -> new Point @x,        @vCenter
    centerCenter: -> new Point @hCenter,  @vCenter
    centerRight:  -> new Point @right,    @vCenter
    bottomLeft:   -> new Point @x,        @bottom
    bottomCenter: -> new Point @hCenter,  @bottom
    bottomRight:  -> new Point @right,    @bottom

    locationIsZero: -> floatEq(@x, 0) && floatEq(@y, 0)
    top: -> @y
    left: -> @x
    right: -> @x + @w
    bottom: -> @y + @h
    hCenter: -> @x + @w *.5
    vCenter: -> @y + @h *.5
    infinite: -> @w == Infinity || @h == Infinity
    normalized: ->
      w = @w
      h = @h
      if w >= 0 && h >= 0
        @
      else
        x = @x
        y = @y
        if w < 0
          x += w
          w = -w
        if h < 0
          y += h
          h = -h
        @with x, y, w, h

    area: -> @w * @h

    # all four points in this order: tl, tr, br, bl
    # order was picked to make drawing paths easy
    corners: ->
      left = @left
      top = @top
      right = @right
      bottom = @bottom
      [
        new Point left, top
        new Point right, top
        new Point right, bottom
        new Point left, bottom
      ]

  # use .with* to only create a new rectangle if values actually changed
  withXY: (x, y)      -> if floatEq(x, @x) && floatEq(y, @y) then @ else new Rectangle x, y, @w, @h
  withWH: (w, h)      -> if floatEq(w, @w) && floatEq(h, @h) then @ else new Rectangle @x, @y, w, h
  withLocation: (v)   -> @withXY v.x, v.y
  withSize:     (v)   -> @withWH v.x, v.y

  movedBy: (d) -> @withXY @x + d.x, @y + d.y

  nearestInsidePoint: (p) -> new Point bound(@left, p.x, @right), bound(@top, p.y, @bottom)
  largestInsideRect: (ofSize) -> # result is centered
    scaler = min @w / ofSize.w, @h / ofSize.h
    w = ofSize.w * scale
    h = ofSize.h * scale
    new Rectangle (@w - w)/2, (@h - h)/2, w, h

  getLeftRightTopBottomPointAsDot = (val) ->
    if isPoint val
      {x, y} = val
      left:   x
      right:  x
      top:    y
      bottom: y

    else if isRect val
      val

    else throw new Error("Invalid arguments. Expecting Point or Rectangle. Got: #{val}.")

  overlaps: (val) ->
    return false unless val?
    {left, right, top, bottom} = getLeftRightTopBottomPointAsDot val
    if floatEq(left, right) || floatEq(top, bottom)
      floatGte(left,  @left)  &&
      floatGte(top,   @top)   &&
      floatLt(left,   @right) &&
      floatLt(top,    @bottom)

    else
      floatGt(right,  @left)  &&
      floatGt(bottom, @top)   &&
      floatLt(left,   @right) &&
      floatLt(top,    @bottom)

  contains: (val) ->
    return false unless val?
    {left, right, top, bottom} = getLeftRightTopBottomPointAsDot val

    if floatEq(left, right) || floatEq(top, bottom)
      floatGte(left,  @left)  &&
      floatGte(top,   @top)   &&
      floatLt(left,   @right) &&
      floatLt(top,    @bottom)
    else
      floatGte(left,  @left)    &&
      floatGte(top,   @top)     &&
      floatLte(right,  @right)  &&
      floatLte(bottom, @bottom)

  # round the rectangle edges to multiples of m
  round: (m = 1)->
    x = round @x, m
    y = round @y, m
    w = round(@x + @w, m) - x
    h = round(@y + @h, m) - y
    @with x, y, w, h

  # if edges are within k of a multiple of m, round to that multiple
  # Otherwise, round towards the nearest multiple of m that is just outside the original rectangle
  # IN: roundingFactor = if a value is with roundingFactor of a whole number, it will snap that number
  roundOut: (m = 1, k = float32Precision, expand = 0)->
    x = floor(@x + k, m) - expand
    y = floor(@y + k, m) - expand
    w = ceil(@x + @w - k, m) - x + 2 * expand
    h = ceil(@y + @h - k, m) - y + 2 * expand
    @with x, y, w, h

  # if edges are within k of a multiple of m, round to that multiple
  # Otherwise, round towards the nearest multiple of m that is within the original rectangle
  roundIn: (m = 1, k = float32Precision)->
    x = ceil @x - k, m
    y = ceil @y - k, m
    w = floor(@x + @w + k, m) - x
    h = floor(@y + @h + k, m) - y
    @with x, y, w, h

  union: (b) ->
    return @ unless b?
    return b if @getArea() <= 0
    x = min @x, b.left
    y = min @y, b.top
    w = max(@getRight(),  b.getRight() ) - x
    h = max(@getBottom(), b.getBottom()) - y
    @with x, y, w, h

  unionInto: (into) ->
    return new Rectangle @x, @y, @w, @h unless into?
    area = @getArea()
    intoArea = into.getArea()

    return into if area <= 0 || intoArea == Infinity

    if intoArea <= 0 || area == Infinity
      into._setAll @x, @y, @w, @h
    else
      {x, y, w, h} = into
      into._setAll(
        _x = min x, @x
        _y = min y, @y
        max(x + w, @x + @w) - _x
        max(y + h, @y + @h) - _y
      )
    into


  _intoOrWith: (into, x, y, w, h) ->
    if into
      into._setAll x, y, w, h

    else
      @with x, y, w, h

  _returnOrSaveInto: (into, returnThisUnlessInto) ->
    if into
      {x, y, w, h} = returnThisUnlessInto
      @_intoOrWith into, x, y, w, h

    else
      returnThisUnlessInto


  intersectInto: (into)        -> log.warn("DEPRICATED: use: intersection"); @intersection into, into
  intersect:     (rectB, into) -> log.warn("DEPRICATED: use: intersection"); @intersection rectB, into

  ### intersection
    IN:
      rectB: anything that has these properties (or getters):
        left, right, top, bottom <Number>
      into: [optional]
        a Rectangle instance

    NOTE: All of these are OK! and work:
      this  == into
      rectB == into
      this  == rectB == into (though this is just a NOOP)

    EFFECT:
      if provided, into will be mutated to contain
      the result.

    OUT:
      if into?
        this will be the return value
        AND it will be MUTATED to contain the intersection x, y, w, h fields
      else
        if the intersection result didn't change anything,
          this
        else
          a new rectangle with the intersection result
  ###
  intersection:  (rectB, into) ->
    fromX = @x
    fromY = @y
    fromW = @w
    fromH = @h

    areaA = fromW * fromH
    areaB = rectB?.getArea() ? Infinity

    if areaB <= 0 || areaA == Infinity
      @_returnOrSaveInto into, rectB

    else if areaA <= 0 || areaB == Infinity
      @_intoOrWith into, fromX, fromY, fromW, fromH

    else
      _x = max rectB.left, fromX
      _y = max rectB.top,  fromY
      _w = min(rectB.right,  fromX + fromW) - _x
      _h = min(rectB.bottom, fromY + fromH) - _y

      if _h <= 0 || _w <= 0
        @_intoOrWith into, 0, 0, 0, 0
      else
        @_intoOrWith into, _x, _y, _w, _h

  grow: (a, b) ->
    if isPoint a
      {x, y} = a
    else
      x = a
      y = if b? then b else a
    return @ if floatEq0(x) && floatEq0(y)
    @with @x - x, @y - y, @w + 2 * x, @h + 2 * y

  pad:    (a) -> @grow -a
  expand: (a) -> @grow a

  # Common instances
  @nothing:     (new Rectangle 0, 0, 0, 0).freeze()
  @everything:  (new Rectangle 0, 0, Infinity, Infinity).freeze()

  withRect: (a,b,c,d) -> @with a,b,c,d

  # return an array of rectangles of what remains when we cut out "r" from this rectangle
  cutout: (r) ->
    return [@] unless @overlaps r
    {x, y, w, h, right, bottom} = @
    out = []
    if r.x > x
      # left column
      out.push new Rectangle x, y, r.x - x, h

    if (rRight = r.right) < right
      # right column
      out.push new Rectangle rRight, y, right - rRight, h

    if r.y > y
      # area above r
      out.push new Rectangle(
        outX = max r.x, x
        y,
        min(rRight, right) - outX
        r.y - y
      )

    if (rBottom = r.bottom) < bottom
      # area below r
      out.push new Rectangle(
        outX = max r.x, x
        rBottom,
        min(rRight, right) - outX
        bottom - rBottom
      )

    out
