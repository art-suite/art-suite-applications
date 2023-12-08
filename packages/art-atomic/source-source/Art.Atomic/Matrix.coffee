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

AtomicBase = require "./Base"
Point      = require "./Point"
Rectangle  = require "./Rectangle"

{point, isPoint} = Point
{rect} = Rectangle
{ceil, floor, sqrt, min, max} = Math
{
  float32Eq0,
  formattedInspect
  inspect, simplifyNum, float32Eq, compact, log, isNumber, defineModule
} = require 'art-standard-lib'

defineModule module, class Matrix extends AtomicBase
  @defineAtomicClass fieldNames: "sx sy shx shy tx ty"
  @isMatrix: isMatrix = (v) -> v?.constructor == Matrix

  @matrix: matrix = (a, b, c, d, e, f) ->
    if isMatrix a
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

  @translate: (a, b) ->
    throw new Error "Matrix.translate no longer accepts two numbers. Use translateXY" if isNumber b
    if isNumber a
      x = y = a
    else
      {x, y} = a

    Matrix.translateXY x, y

  @translateXY: (x, y) ->
    if x == 0 && y == 0
      identityMatrix
    else
      new Matrix 1, 1, 0, 0, x, y

  @scale: (a, b) ->
    throw new Error "Matrix.scale no longer accepts two numbers. Use translateXY" if isNumber b
    if isNumber a
      x = y = a
    else
      {x, y} = a

    Matrix.scaleXY x, y

  @scaleXY: (sx, sy) ->
    if sx == 1 && sy == 1
      identityMatrix
    else
      new Matrix sx, sy, 0, 0, 0, 0

  @rotate: (radians) ->
    cr   = Math.cos radians
    sr   = Math.sin radians

    if cr == 1 && sr == 0
      identityMatrix
    else
      # log "rotate new Matrix"
      new Matrix cr, cr, -sr, sr, 0, 0

  ###
    Matrix.multitouch
      Solves:
        Given two points, moved in space
        Generate a transformation matrix m
        where:
          a2 == m.transform a1
          and
          b2 == m.transform b1
          and m.exactScale.aspectRatio == 1
  ###
  @multitouch: (a1, a2, b1, b2) ->

    c1x = (b1.x + a1.x) / 2
    c1y = (b1.y + a1.y) / 2

    c2x = (b2.x + a2.x) / 2
    c2y = (b2.y + a2.y) / 2

    v1 = b1.sub a1
    v2 = b2.sub a2

    v1m = v1.magnitude
    v2m = v2.magnitude

    m = Matrix.translateXY -c1x, -c1y

    # make sure we aren't in a degenerate situation
    if !float32Eq0(v1m) && !float32Eq0(v2m)
      angle = v2.angle - v1.angle
      scale = v2m      / v1m
      m = m.rotate angle if !float32Eq0 angle
      m = m.scale  scale if !float32Eq  scale, 1

    m.translateXY c2x, c2y

  @multitouchParts: (a1, a2, b1, b2) ->

    v1 = b1.sub a1
    v2 = b2.sub a2

    rotate:     v2.angle - v1.angle
    scale:      v2.magnitude / v1.magnitude
    translate:  point(
      (b2.x + a2.x) / 2 - (b1.x + a1.x) / 2
      (b2.y + a2.y) / 2 - (b1.y + a1.y) / 2
    )

  initDefaults: ->
    @sx = @sy = 1
    @shy = @shx = 0
    @tx = @ty = 0
    @_exactScale = @_exactScaler = null
    @

  _init: (a, b, c, d, e, f) ->
    @initDefaults()
    return unless a?
    if      isPoint a   then @_initFromPoint a
    else if isMatrix a  then @_initFromMatrix a
    else
      @sx  = a - 0
      @sy  = b - 0 if b?
      @shx = c - 0 if c?
      @shy = d - 0 if d?
      @tx  = e - 0 if e?
      @ty  = f - 0 if f?

  getScale: -> return @getS()

  @getter
    t:   -> point @tx, @ty   # returns the current location
    s:   -> point @sx, @sy   # returns the current scale
    sh:  -> point @shx, @shy
    xsv: -> point @sx, @shx
    ysv: -> point @sy, @shy
    xsvMagnitude: -> sqrt @sx * @sx + @shx * @shx
    ysvMagnitude: -> sqrt @sy * @sy + @shy * @shy
    exactScale: -> @_exactScale ||= point @xsv.magnitude, @ysv.magnitude
    exactScaler: -> @_exactScaler ||= (@getXsvMagnitude() + @getYsvMagnitude()) / 2
    inv: -> @invert()
    inverted: -> @invert()
    locationX: -> @tx
    locationY: -> @ty
    scaleX: -> @sx
    scaleY: -> @sy
    location: -> point @tx, @ty
    rounded: -> @getWithRoundedTranslation()
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
      float32Eq0(@shx) &&
      float32Eq0(@shy) &&
      float32Eq0(@tx) &&
      float32Eq0(@ty)

    isTranslateOnly: ->
      float32Eq(@sx, 1) &&
      float32Eq(@sy, 1) &&
      float32Eq0(@shx) &&
      float32Eq0(@shy)

    translationIsIntegral: ->
      float32Eq(@tx, Math.round(@tx)) &&
      float32Eq(@ty, Math.round(@ty))

    isIntegerTranslateOnly: ->
      @isTranslateOnly &&
      float32Eq(@tx, @tx|0) &&
      float32Eq(@ty, @ty|0)

    isTranslateAndScaleOnly: ->
      float32Eq0(@shx) &&
      float32Eq0(@shy)

    hasSkew: -> !@getIsTranslateAndScaleOnly()

    isTranslateAndPositiveScaleOnly: ->
      @sx > 0 &&
      @sy > 0 &&
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
  withScale: (a, b) ->
    if isNumber a
      x = a
      y = if b? then b else x
    else
      {x, y} = a

    @scale x / @sx, y / @sy

  # returns new matrix where .location == point a, b
  withLocation: (a, b) ->
    if isNumber a
      x = a
      y = if b? then b else x
    else
      {x, y} = a

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

  ### translate
    IN:
      amount: point or number
      into: t/f
  ###
  translate: (amount, into) ->
    if isNumber amount
      x = y = amount
    else
      {x, y} = amount

    throw new Error "Illegal second input: number (#{into}). Use translateXY." if isNumber into

    @translateXY x, y, into

  translateXY: (x, y, into) ->
    @_into into, @sx, @sy, @shx, @shy, @tx + x, @ty + y

  rotate: (radians, into) ->
    cr   = Math.cos radians
    sr   = Math.sin radians
    @_into into,
      @sx  * cr - @shy * sr
      @shx * sr + @sy  * cr
      @shx * cr - @sy  * sr
      @sx  * sr + @shy * cr
      @tx  * cr - @ty  * sr
      @tx  * sr + @ty  * cr

  # s can be a point or number
  scale: (a, into) ->
    throw new Error "Matrix.scale no longer accepts two numbers. Use scaleXY" if isNumber into
    if isNumber a
      x = y = a
    else
      {x, y} = a

    @scaleXY x, y, into

  scaleXY: (x, y, into) ->
    @_into into,
      @sx  * x
      @sy  * y
      @shx * x
      @shy * y
      @tx  * x
      @ty  * y

  @getter
    determinantReciprocal: ->
      1.0 / (@sx * @sy - @shy * @shx)

  invert: (into)->
    d = @getDeterminantReciprocal()
    @_into into,
      d *  @sy
      d *  @sx
      d * -@shx
      d * -@shy
      d * (-@tx * @sy  + @ty * @shx)
      d * ( @tx * @shy - @ty * @sx )

  invertAndMul: (m, into)->
    d = @getDeterminantReciprocal()
    sx  = d *  @sy
    sy  = d *  @sx
    shx = d * -@shx
    shy = d * -@shy
    tx  = d * (-@tx * @sy  + @ty * @shx)
    ty  = d * ( @tx * @shy - @ty * @sx )
    @_into into,
      sx  * m.sx  + shy * m.shx
      shx * m.shy + sy  * m.sy
      shx * m.sx  + sy  * m.shx
      sx  * m.shy + shy * m.sy
      tx  * m.sx  + ty  * m.shx + m.tx
      tx  * m.shy + ty  * m.sy  + m.ty

  mul: (m, into) ->
    if isNumber m
      @_into into,
        @sx  * m
        @sy  * m
        @shx * m
        @shy * m
        @tx  * m
        @ty  * m
    else
      @_into into,
        @sx  * m.sx  + @shy * m.shx
        @shx * m.shy + @sy  * m.sy
        @shx * m.sx  + @sy  * m.shx
        @sx  * m.shy + @shy * m.sy
        @tx  * m.sx  + @ty  * m.shx + m.tx
        @tx  * m.shy + @ty  * m.sy  + m.ty

  div: (m, into) ->
    multipler = if isNumber m
      1/m
    else
      m.invert intermediatResultMatrix
    @mul multipler, into

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

  @transform1D: transform1D = (x, y, sx, shx, tx) -> x * sx + y * shx + tx

  ### transform
    IN: a: Point or any object where .x and .y are numbers
    IN: a: x (number; required), b: y (number, default: x)
  ###
  transform: (a, b) ->
    if isNumber a
      log.error "DEPRICATED: matrix.transform(x, y) - use matrix.transformXY"
      x = a
      y = if b? then b else x
    else
      {x, y} = a

    @transformXY x, y

  transformX:        (x, y) -> transform1D x, y, @sx, @shx, @tx
  transformY:        (x, y) -> transform1D y, x, @sy, @shy, @ty

  transformXY:       (x, y) ->
    new Point(
      @transformX x, y
      @transformY x, y
    )

  # equivalent to @inv.transform x, y
  inverseTransform: (a, b) ->
    if isNumber a
      x = a
      y = if b? then b else x
    else
      {x, y} = a

    d = @getDeterminantReciprocal()
    sx  = d *  @sy
    sy  = d *  @sx
    shx = d * -@shx
    shy = d * -@shy
    tx  = d * (-@tx * @sy  + @ty * @shx)
    ty  = d * ( @tx * @shy - @ty * @sx )

    new Point(
      transform1D x, y, sx, shx, tx
      transform1D y, x, sy, shy, ty
    )


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
  transformBoundingRect: (r, roundOut, into) ->
    r = rect r
    if r.infinite
      {x, y, w, h} = r

    else if @isTranslateAndScaleOnly
      # faster (probably) in the special case where there is no skew or rotation
      x = r.x * @sx + @tx
      y = r.y * @sy + @ty
      w = r.w * @sx
      h = r.h * @sy

      if w < 0 then x += w; w = -w
      if h < 0 then y += h; h = -h

    else
      # full implementation
      {top, left, right, bottom} = r

      x1 = transform1D left,    top,    @sx, @shx, @tx
      y1 = transform1D top,     left,   @sy, @shy, @ty

      x2 = transform1D right,   top,    @sx, @shx, @tx
      y2 = transform1D top,     right,  @sy, @shy, @ty

      x3 = transform1D right,   bottom, @sx, @shx, @tx
      y3 = transform1D bottom,  right,  @sy, @shy, @ty

      x4 = transform1D left,    bottom, @sx, @shx, @tx
      y4 = transform1D bottom,  left,   @sy, @shy, @ty

      x = min x1, x2, x3, x4
      w = max(x1, x2, x3, x4) - x

      y = min y1, y2, y3, y4
      h = max(y1, y2, y3, y4) - y

    if roundOut
      right = ceil x + w
      bottom = ceil y + h
      x = floor x
      y = floor y
      w = right - x
      h = bottom - y

    if into
      into._setAll x, y, w, h

    else
      new Rectangle x, y, w, h

  # Common instances
  @identityMatrix: identityMatrix = new Matrix
  @matrix0: new Matrix 0, 0, 0, 0, 0, 0
  intermediatResultMatrix = new Matrix

  #*********************************************
  # PRIVATE
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
