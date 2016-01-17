###

With the exception of the setter methods, this is a pure-functional class.
###

##############################################
# Float32Array Experiment Notes
##############################################
###
Experiment: Instead of storing the matrix as 6 members, use a Float32Array:

  Bonus: if we order the 6 elements correctly, we can just pass the Float32Array directly to Webgl uniformMatrix3fv
  Result:
    FF is about 2x as fast with this implementation, but Chrome is about 10x slower (see below)
    Sticking with Members implementation for now.

On my Macbook pro Retina (2.6 GHz Intel Core i7)

Chrome 29.0.1547.57 (members)
  Matrix.translate 14,716,649/s
  matrix().translate 8,052,404/s
  transform point 3,922,725/s
  invert 12,733,472/s
  mul 16,146,097/s

Chrome 29.0.1547.57 (float32Array)
  Matrix.translate 926,402/s
  matrix().translate 463,791/s
  transform point 3,684,177/s
  invert 978,248/s
  mul 992,078/s

FF 23.0.1 (members)
  Matrix.translate 1,281,078/s
  matrix().translate 534,542/s
  transform point 768,224/s
  invert 1,374,788/s
  mul 1,413,206/s

FF 23.0.1 (float32Array)
  Matrix.translate 2,126,281/s
  matrix().translate 1,013,548/s
  transform point 832,604/s
  invert 2,524,903/s
  mul 2,669,331/s

NOTE! the order of the fields in the float32array for Webgl uniformMatrix3fv should be:
  @values[0] = @sx
  @values[1] = @shy
  @values[2] = @tx
  @values[3] = @shx
  @values[4] = @sy
  @values[5] = @ty
###

Foundation = require 'art.foundation'
AtomicBase = require "./base"
Point      = require "./point"
Rectangle  = require "./rectangle"

{point} = Point
{rect} = Rectangle
{inspect, simplifyNum, float32Eq, compact} = Foundation

module.exports = class Matrix extends AtomicBase
  @matrix: matrix = (a, b, c, d, e, f) ->
    if a instanceof Matrix
      a
    else if a is null or a is undefined
      identityMatrix
    else
      new Matrix a, b, c, d, e, f

  @_cleanInspect: cleanInspect = (pointName, s) ->
    out = if pointName
      r = new RegExp "([0-9])#{pointName}", "g"
      s.replace(r, "$1 * #{pointName}").replace(/-1 \* /g, "-").replace(/\ \+ -/g, " - ").replace(/0\./g, ".")
    else
      s.replace(/-1([A-Za-z]+)/g, "-$1").replace(/\ \+ -/g, " - ").replace(/0\./g, ".")
    out

  # constructor: ->
  #   super
  #   console.error "new Matrix", arguments

  @translate: (x, y) ->
    if x && (typeof x.x is "number")
      y = x.y
      x = x.x
    else
      x = 0 unless typeof x is "number"
      y = x unless typeof y is "number"

    if x == 0 && y == 0
      identityMatrix
    else
      # log "translate new Matrix"
      new Matrix 1, 1, 0, 0, x, y

  @scale: (a, b) ->
    s = point a, b
    sx = s.x
    sy = s.y

    if sx == 1 && sy == 1
      identityMatrix
    else
      # log "scale new Matrix"
      new Matrix sx, sy, 0, 0, 0, 0

  @rotate: (radians) ->
    cr   = Math.cos radians
    sr   = Math.sin radians

    if cr == 1 && sr == 0
      identityMatrix
    else
      # log "rotate new Matrix"
      new Matrix cr, cr, -sr, sr, 0, 0

  initDefaults: ->
    @sx = @sy = 1
    @shy = @shx = 0
    @tx = @ty = 0
    @_exactScale = @_exactScaler = null
    @

  _init: (a, b, c, d, e, f) ->
    @initDefaults()
    return unless a?
    if      a instanceof Point  then @_initFromPoint a
    else if a instanceof Matrix then @_initFromMatrix a
    else
      @sx  = a - 0
      @sy  = b - 0 if b?
      @shx = c - 0 if c?
      @shy = d - 0 if d?
      @tx  = e - 0 if e?
      @ty  = f - 0 if f?

  _setAll: (sx, sy, shx, shy, tx, ty) ->
    @sx  = sx
    @sy  = sy
    @shx = shx
    @shy = shy
    @tx  = tx
    @ty  = ty
    @

  @getter
    t:   -> point @tx, @ty   # returns the current location
    s:   -> point @sx, @sy   # returns the current scale
    sh:  -> point @shx, @shy
    xsv: -> point @sx, @shx
    ysv: -> point @sy, @shy
    exactScale: -> @_exactScale ||= point @xsv.magnitude, @ysv.magnitude
    exactScaler: -> @_exactScaler ||= @exactScale.average()
    inv: -> @invert()
    location: -> point @tx, @ty
    withRoundedTranslation: ->
      if @translationIsIntegral then @
      else
        # log "withRoundedTranslation new Matrix"
        new Matrix @sx, @sy, @shx, @shy, Math.round(@tx), Math.round(@ty)

    angle: ->
      p1 = @transform Point.point0
      p2 = @transform new Point 0, 1
      (p2.sub p1).angle - Math.PI * .5

    float32Array: -> @fillFloat32Array new Float32Array 9

    isIdentity: ->
      float32Eq(@sx, 1) &&
      float32Eq(@sy, 1) &&
      float32Eq(@shx, 0) &&
      float32Eq(@shy, 0) &&
      float32Eq(@tx, 0) &&
      float32Eq(@ty, 0)

    isTranslateOnly: ->
      float32Eq(@sx, 1) &&
      float32Eq(@sy, 1) &&
      float32Eq(@shx, 0) &&
      float32Eq(@shy, 0)

    translationIsIntegral: ->
      float32Eq(@tx, Math.round(@tx)) &&
      float32Eq(@ty, Math.round(@ty))

    isIntegerTranslateOnly: ->
      @isTranslateOnly &&
      float32Eq(@tx, @tx|0) &&
      float32Eq(@ty, @ty|0)

    isTranslateAndScaleOnly: ->
      float32Eq(@shx, 0) &&
      float32Eq(@shy, 0)

  fillFloat32Array: (a) ->
      a[0] = @sx
      a[1] = @shx
      a[2] = @tx
      a[3] = @shy
      a[4] = @sy
      a[5] = @ty
      a


  #*********************************************
  # <internal use>
  #*********************************************
  _initFromMatrix: (m) ->
    @sx  = m.sx
    @sy  = m.sy
    @shx = m.shx
    @shy = m.shy
    @tx  = m.tx
    @ty  = m.ty
    @

  _initFromPoint: (p) ->
    @tx = p.x
    @ty = p.y
    @

  #*********************************************
  # </internal use>
  #*********************************************

  simplify: ->
    # log "simplify new Matrix"

    new Matrix(
      simplifyNum @sx
      simplifyNum @sy
      simplifyNum @shx
      simplifyNum @shy
      simplifyNum @tx
      simplifyNum @ty
    )

  # returns new matrix where .angle == a
  withAngle: (a) -> @rotate a - @angle

  # returns new matrix where .s == point a, b
  withScale: (x, y) ->
    if x && (typeof x.x is "number")
      y = x.y
      x = x.x
    else
      x = 0 unless typeof x is "number"
      y = x unless typeof y is "number"

    @scale x / @sx, y / @sy

  # returns new matrix where .location == point a, b
  withLocation: (x, y) ->
    if x && (typeof x.x is "number")
      y = x.y
      x = x.x
    else
      x = 0 unless typeof x is "number"
      y = x unless typeof y is "number"

    if x == @tx && y == @ty
      @
    else
      # log "withLocation new Matrix"
      new Matrix @sx, @sy, @shx, @shy, x, y

  withLocationXY: (x, y) ->
    if x == @tx && y == @ty
      @
    else
      # log "withLocationXY new Matrix"
      new Matrix @sx, @sy, @shx, @shy, x, y

  translate: (x, y) ->
    if x && (typeof x.x is "number")
      y = x.y
      x = x.x
    else
      x = 0 unless typeof x is "number"
      y = x unless typeof y is "number"

    # log "translateB new Matrix"
    new Matrix @sx, @sy, @shx, @shy, @tx + x, @ty + y

  rotate: (radians) ->
    cr   = Math.cos radians
    sr   = Math.sin radians
    # log "rotateB new Matrix"
    new Matrix(
      @sx  * cr - @shy * sr
      @shx * sr + @sy  * cr
      @shx * cr - @sy  * sr
      @sx  * sr + @shy * cr
      @tx  * cr - @ty  * sr
      @tx  * sr + @ty  * cr
    )

  # s can be a point or number
  scale: (x, y) ->
    if x && (typeof x.x is "number")
      y = x.y
      x = x.x
    else
      x = 0 unless typeof x is "number"
      y = x unless typeof y is "number"

    # log "scaleB new Matrix"
    new Matrix(
      @sx  * x
      @sy  * y
      @shx * x
      @shy * y
      @tx  * x
      @ty  * y
    )

  determinantReciprocal: ->
    1.0 / (@sx * @sy - @shy * @shx)

  invert: (into)->
    unless into
      # log "invert new Matrix"
      into = new Matrix

    d = @determinantReciprocal()
    into._setAll(
      d *  @sy
      d *  @sx
      d * -@shx
      d * -@shy
      d * (-@tx * @sy  + @ty * @shx)
      d * ( @tx * @shy - @ty * @sx )
    )

  eq: (m) ->
    return true if @ == m
    m &&
    float32Eq(@sx  , m.sx ) &&
    float32Eq(@sy  , m.sy ) &&
    float32Eq(@shx , m.shx) &&
    float32Eq(@shy , m.shy) &&
    float32Eq(@tx  , m.tx ) &&
    float32Eq(@ty  , m.ty )

  lt: (m) ->
    @sx  < m.sx  and
    @sy  < m.sy  and
    @shx < m.shx and
    @shy < m.shy and
    @tx  < m.tx  and
    @ty  < m.ty

  gt: (m) ->
    @sx  > m.sx  and
    @sy  > m.sy  and
    @shx > m.shx and
    @shy > m.shy and
    @tx  > m.tx  and
    @ty  > m.ty


  lte: (m) ->
    @sx  <= m.sx  and
    @sy  <= m.sy  and
    @shx <= m.shx and
    @shy <= m.shy and
    @tx  <= m.tx  and
    @ty  <= m.ty

  gte: (m) ->
    @sx  >= m.sx  and
    @sy  >= m.sy  and
    @shx >= m.shx and
    @shy >= m.shy and
    @tx  >= m.tx  and
    @ty  >= m.ty

  add: (m, into) ->
    unless into
      # log "add new Matrix"
      into = new Matrix
    into._setAll(
      @sx  + m.sx
      @sy  + m.sy
      @shx + m.shx
      @shy + m.shy
      @tx  + m.tx
      @ty  + m.ty
    )

  sub: (m, into) ->
    unless into
      # log "sub new Matrix"
      into = new Matrix
    into._setAll(
      @sx  - m.sx
      @sy  - m.sy
      @shx - m.shx
      @shy - m.shy
      @tx  - m.tx
      @ty  - m.ty
    )

  mul: (m, into) ->
    unless into
      # log "mul new Matrix"
      into = new Matrix
    if typeof m == "number"
      into._setAll(
        @sx  * m
        @sy  * m
        @shx * m
        @shy * m
        @tx  * m
        @ty  * m
      )
    else
      into._setAll(
        @sx  * m.sx  + @shy * m.shx
        @shx * m.shy + @sy  * m.sy
        @shx * m.sx  + @sy  * m.shx
        @sx  * m.shy + @shy * m.sy
        @tx  * m.sx  + @ty  * m.shx + m.tx
        @tx  * m.shy + @ty  * m.sy  + m.ty
      )

  div: (m, into) ->
    unless into
      # log "div new Matrix"
      into = new Matrix
    m.invert intermediatResultMatrix
    @mul intermediatResultMatrix, into

  interpolate: (toMatrix, p) ->
    unless into
      # log "interpolate new Matrix"
      into = new Matrix
    oneMinusP = 1 - p
    into._setAll(
      toMatrix.sx  * p + @sx  * oneMinusP
      toMatrix.sy  * p + @sy  * oneMinusP
      toMatrix.shx * p + @shx * oneMinusP
      toMatrix.shy * p + @shy * oneMinusP
      toMatrix.tx  * p + @tx  * oneMinusP
      toMatrix.ty  * p + @ty  * oneMinusP
    )

  toArray: toArray = -> [@sx, @sy, @shx, @shy, @tx, @ty]
  toPlainStructure: sx:@sx, sy:@sy, shx:@shx, shy:@shy, tx:@tx, ty:@ty
  toPlainEvalString: -> "{sx:#{@sx}, sy:#{@sy}, shx:#{@shx}, shy:#{@shy}, tx:#{@tx}, ty:#{@ty}}"

  toString: -> @toArray().join ", "
  getInspectedString: -> "matrix(#{@toString()})"

  inspectX: (pointName, nullForZeroString) ->
    pn = pointName
    pointName = if pointName then pointName + "." else ""
    return (if !nullForZeroString then "0") unless @sx || @shx || @tx
    cleanInspect pn, compact([
      if @sx  == 1 then "#{pointName}x" else if @sx  then "#{@sx}#{pointName}x"
      if @shx == 1 then "#{pointName}y" else if @shx then "#{@shx}#{pointName}y"
      if @tx then "#{@tx}"
    ]).join " + "

  inspectY: (pointName, nullForZeroString) ->
    pn = pointName
    pointName = if pointName then pointName + "." else ""
    return (if !nullForZeroString then "0") unless @sy || @shy || @ty
    cleanInspect pn, compact([
      if @sy  == 1 then "#{pointName}y" else if @sy  then "#{@sy}#{pointName}y"
      if @shy == 1 then "#{pointName}x" else if @shy then "#{@shy}#{pointName}x"
      if @ty then "#{@ty}"
    ]).join " + "

  inspectBoth: (pointName) -> "(#{@inspectX pointName}, #{@inspectY pointName})"

  # input options:
  #   Point
  #   Rectangle => forwards to @transformBoundingRect
  #   x = Number, y = Number
  #   null => x = 0, y = 0
  transform: (x, y) ->
    if x && (typeof x.x is "number")
      y = x.y
      x = x.x
    else
      x = 0 unless typeof x is "number"
      y = x unless typeof y is "number"

    new Point(
      x * @sx + y * @shx + @tx
      y * @sy + x * @shy + @ty
    )

  transformX:        (x, y) -> x * @sx + y * @shx + @tx
  transformY:        (x, y) -> y * @sy + x * @shy + @ty

  # assumpting the vector is the difference between two points in space: p1.sub p2
  # returns @transform(p1).sub @transform(p2)
  # input is a single vector, specified in one of these ways:
  #   Point vector
  #   Number dx, Number dy
  #   null => dx = 0, dy = 0
  transformVector: (a, b)->
    switch a? && a.constructor
      when false  then dx = dy = 0
      when Point  then dx = a.x; dy = a.y
      else             dx = a; dy = b
    new Point(
      dx * @sx + dy * @shx
      dy * @sy + dx * @shy
    )

  # equivelent to: @transform(v1).sub @transform(v2)
  # but faster and only creates 1 object instead of 3
  transformDifference: (v1, v2) ->
    dx = v1.x - v2.x
    dy = v1.y - v2.y
    new Point(
      dx * @sx + dy * @shx
      dy * @sy + dx * @shy
    )

  # return the minimum rectangle that cover the four transformed corners of r
  # Equivelent, but faster than this:
  #   for c in r.corners
  #     c = @transform c
  #     max = if max then max.max(c) else c
  #     min = if min then min.min(c) else c
  #   new Rectangle min, max.sub min
  transformBoundingRect: (r) ->
    r = rect r
    return r if r.infinite

    if @shx == 0 && @shy == 0 #float32Eq(@shx, 0) && float32Eq(@shy, 0)
      # faster (probably) in the special case where there is no skew or rotation
      x = r.x * @sx + @tx
      y = r.y * @sy + @ty
      w = r.w * @sx
      h = r.h * @sy
      if w < 0 then x += w; w = -w
      if h < 0 then y += h; h = -h

    else
      # full implementation
      top = r.x
      left = r.y
      right = r.x + r.w
      bottom = r.y + r.h

      x1 = left * @sx + top * @shx + @tx
      y1 = top * @sy + left * @shy + @ty

      x2 = right * @sx + top * @shx + @tx
      y2 = top * @sy + right * @shy + @ty

      x3 = right * @sx + bottom * @shx + @tx
      y3 = bottom * @sy + right * @shy + @ty

      x4 = left * @sx + bottom * @shx + @tx
      y4 = bottom * @sy + left * @shy + @ty

      x = Math.min x1, x2, x3, x4
      w = Math.max(x1, x2, x3, x4) - x

      y = Math.min y1, y2, y3, y4
      h = Math.max(y1, y2, y3, y4) - y

    new Rectangle x, y, w, h

  # Common instances
  @identityMatrix: identityMatrix = new Matrix
  @matrix0: new Matrix 0, 0, 0, 0, 0, 0
  intermediatResultMatrix = new Matrix
