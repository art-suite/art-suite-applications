{assert} = require 'art-foundation/src/art/dev_tools/test/art_chai'
Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
{point, rect, matrix, Matrix, identityMatrix, Point} = Atomic
{log, floatEq} = Foundation

suite "Art.Atomic.Matrix.basic", ->
  test "0-arg creation", ->
    assert.equal matrix().toString(), '[1, 1, 0, 0, 0, 0]'
    assert.equal (new Matrix).toString(), '[1, 1, 0, 0, 0, 0]'

  test "6-arg creation", ->
    assert.equal matrix(1,2,3,4,5,6).toString(), '[1, 2, 3, 4, 5, 6]'

  test "scale is pure functional", ->
    m1 = matrix(1, 2, 3, 4, 5, 6)
    m2 = m1.scaleXY 10, 100
    assert.deepEqual m1, matrix(1,2,3,4,5,6)

  test "inspectX", ->
    m1 = matrix(1, 2, 3, 4, 5, 6)
    assert.eq m1.inspectX(), "x + 3y + 5"
    assert.eq m1.inspectX("foo"), "foo.x + 3 * foo.y + 5"

    assert.eq matrix(2.1, 0, .5, 0, .1, 0).inspectX(), "2.1x + .5y + .1"

    assert.eq matrix(0, 0, 0, 0, 0, 0).inspectX(), "0"
    assert.eq matrix(0, 2, 3, 4, 5, 6).inspectX(), "3y + 5"
    assert.eq matrix(1, 2, 0, 4, 5, 6).inspectX(), "x + 5"
    assert.eq matrix(1, 2, 3, 4, 0, 6).inspectX(), "x + 3y"

    assert.eq matrix(-1, 0, 1, 0, 0, 0).inspectX(), "-x + y"
    assert.eq matrix(0, 0, 1, 0, -1, 0).inspectX(), "y - 1"
    assert.eq matrix(1, 0, -1, 0, 0, 0).inspectX(), "x - y"

  test "inspectY", ->
    m1 = matrix(1, 2, 3, 4, 5, 6)
    assert.eq m1.inspectY(), "2y + 4x + 6"
    assert.eq m1.inspectY("foo"), "2 * foo.y + 4 * foo.x + 6"

    assert.eq matrix(0, 2.1, 0, .5, 0, .1).inspectY(), "2.1y + .5x + .1"

    assert.eq matrix(0, 0, 0, 0, 0, 0).inspectY(), "0"
    assert.eq matrix(1, 0, 3, 4, 5, 6).inspectY(), "4x + 6"
    assert.eq matrix(1, 2, 1, 0, 5, 6).inspectY(), "2y + 6"
    assert.eq matrix(1, 2, 3, 4, 1, 0).inspectY(), "2y + 4x"

    assert.eq matrix(0, -1, 0, 1, 0, 0).inspectY(), "-y + x"
    assert.eq matrix(0, 0, 0, 1, 0, -1).inspectY(), "x - 1"
    assert.eq matrix(0, 1, 0, -1, 0, 0).inspectY(), "y - x"

  test "scaleXY", ->
    assert.deepEqual matrix(1, 2, 3, 4, 5, 6).scaleXY(10, 100), matrix(10, 200, 30, 400, 50, 600)

  test "rotate is pure functional", ->
    m = matrix()
    m.rotate 10
    assert.deepEqual m, matrix(1,1,0,0,0,0)

  test "rotate 0",       -> assert.eq Matrix.rotate(0), identityMatrix
  test "rotate pi/2",    -> assert.eq Matrix.rotate(Math.PI / 2), matrix(0, 0, -1, 1, 0, 0)
  test "rotate pi",      -> assert.eq Matrix.rotate(Math.PI), matrix(-1, -1, 0, 0, 0, 0)
  test "rotate 3*pi/2",  -> assert.eq Matrix.rotate(3 * Math.PI / 2), matrix(0, 0, 1, -1, 0, 0)
  test "rotate 2*pi",    -> assert.eq Matrix.rotate(2 * Math.PI), identityMatrix
  test "translate",      -> assert.eq Matrix.translateXY(2, 3), matrix(1, 1, 0, 0, 2, 3)
  test "translate by 1,0", -> assert.eq Matrix.translateXY(1, 0), matrix(1, 1, 0, 0, 1, 0)
  test "translate by 0,0", -> assert.eq Matrix.translateXY(0, 0), identityMatrix
  test "translate by 0",   -> assert.eq (new Matrix).translate(0), identityMatrix

  test "Matrix.translate vs Matrix.translateXY", ->
    assert.eq Matrix.translateXY(123, 456), Matrix.translateXY(123, 456)
    assert.eq Matrix.translateXY(123, 456), Matrix.translate(point(123, 456))
    assert.eq Matrix.translate(point(123, 456)), Matrix.translate(point(123, 456))

  test "Matrix.scale vs Matrix.scaleXY", ->
    assert.eq Matrix.scaleXY(123, 456), Matrix.scaleXY(123, 456)
    assert.eq Matrix.scaleXY(123, 456), Matrix.scale(point(123, 456))
    assert.eq Matrix.scale(point(123, 456)), Matrix.scale(point(123, 456))
  test "Matrix.rotate vs Matrix.rotate", -> assert.eq Matrix.rotate(1), Matrix.rotate(1)

  test "inverted identity matrix is the identity matrix", ->
    assert.eq identityMatrix, identityMatrix.invert()

  test "invert translate", -> assert.eq Matrix.translate(point(2,3)).invert(), matrix 1, 1, 0, 0, -2, -3
  test "invert scale", -> assert.eq Matrix.scale(point(2,5)).invert(), matrix 0.5, 0.2, 0, 0, 0, 0

  test "invert rotate", ->
    m1 = Matrix.rotate(Math.PI/2).invert()
    m2 = Matrix.rotate(-Math.PI/2)
    assert.eq m1, m2

  test "clone constructor", ->
    m1 = matrix(2,3,5,7,11,13)
    m2 = new Matrix(m1)
    m1.sx = 100

    assert.equal "#{m2}", "[2, 3, 5, 7, 11, 13]"

  test "mul", ->
    m1 = Matrix.scaleXY(2, 3)
    m2 = Matrix.translateXY(5, 7)
    m3 = m1.mul(m2)
    assert.equal "#{m3}", "[2, 3, 0, 0, 5, 7]"

    m3 = m2.mul(m1)
    assert.equal "#{m3}", "[2, 3, 0, 0, 10, 21]"

  test "invert & mul itself == idenity", ->
    m = Matrix.scaleXY 2,3
    assert.eq identityMatrix, m.inv.mul(m)

    m = Matrix.rotate(3*Math.PI/4)
    assert.eq identityMatrix, m.inv.mul(m)

    m = Matrix.translateXY(7,11)
    assert.eq identityMatrix, m.inv.mul(m)

  test "div by itself == identity", ->
    m = Matrix.scaleXY 2,3
    assert.eq identityMatrix, m.div m

    m = Matrix.rotate(3*Math.PI/4)
    assert.eq identityMatrix, m.div m

    m = Matrix.translateXY(7,11)
    assert.eq identityMatrix, m.div m

  test "transform", ->
    m = Matrix.translateXY(5,7).scaleXY 2,3
    p = m.transform(2,3)
    assert.eq point("#{p}"), point 14, 30

  test "set from string", ->
    m = matrix "1, 2, 3,         4,5, 6"
    assert.equal "#{m}", "[1, 2, 3, 4, 5, 6]"

  test "transformBoundingRect translation", ->
    m = Matrix.translateXY 100, 200
    r = m.transformBoundingRect rect(10,20,45,50)
    assert.eq r, rect 110, 220, 45, 50

  test "transformBoundingRect scale", ->
    m = Matrix.scale(2).translateXY 100, 200
    r = m.transformBoundingRect rect(10,20,45,50)
    assert.eq r, rect 120, 240, 90, 100

  test "transformBoundingRect rotation", ->
    m = Matrix.translateXY(100,100).rotate Math.PI/4
    r = m.transformBoundingRect rect(10,10,50,50)
    assert.eq rect("#{r.round()}"), rect -35, 156, 70, 70

  test "transformBoundingRect PI rotation", ->
    m = Matrix.translateXY(100,100).rotate Math.PI
    r = m.transformBoundingRect rect 10, 10, 50, 50
    assert.eq r.round(), rect -160, -160, 50, 50

  test "exactScale identity matrix", ->
    m = new Matrix
    assert.eq m.exactScaler, 1

  test "exactScale rotated matrix", ->
    m = Matrix.rotate Math.PI / 4
    assert.floatEq m.exactScaler, 1

  test "exactScale scaled, rotated matrix", ->
    m = Matrix.scale(1.5).rotate Math.PI / 4
    assert.floatEq m.exactScaler, 1.5

  test "transformVector", ->
    a = point 2, 3
    b = point 5, 7
    m = Matrix.translateXY(11, 13).scaleXY(17, 19).rotate(23)
    ta = m.transform a
    tb = m.transform b
    dControl = ta.sub tb
    d = m.transformVector a.sub b
    assert.eq dControl, d

  test "interpolate 0, .5 and 1", ->
    m1 = new Matrix()
    m2 = new Matrix 3, 5, 6, 8, 10, 12
    assert.eq m1.interpolate(m2, 0), m1
    assert.eq m1.interpolate(m2, 1), m2
    assert.eq m1.interpolate(m2, .5), new Matrix 2, 3, 3, 4, 5, 6

suite "Art.Atomic.Matrix.inverseTransform", ->
  testInverseTransform = (matrix) ->
    test "#{matrix}", ->
      for k, p of Point.namedPoints
        assert.eq matrix.inv.transform(p), matrix.inverseTransform(p), "point: #{p}"

  testInverseTransform identityMatrix
  testInverseTransform Matrix.translate 10
  testInverseTransform Matrix.translate -10
  testInverseTransform Matrix.translateXY 10, -10
  testInverseTransform Matrix.rotate Math.PI/4
  testInverseTransform Matrix.scale 10
  testInverseTransform Matrix.scale 1/10
  testInverseTransform Matrix.scale(1/10).rotate(Math.PI/4).translateXY 10, -10

suite "Art.Atomic.Matrix.into", ->

  doChain = (into) ->
    m = new Matrix
    n = m.translate 10, into
    n = n.scale 10, into
    n = n.rotate 3, into
    n = n.invert into
    n = n.add identityMatrix, into
    n = n.sub identityMatrix, into
    n = n.mul 1, into
    n = n.div 1, into
    first:m, last:n

  test "into = true, i.e. @, returns @", ->
    {first, last} = doChain true
    assert.equal first, last

  test "into = false, returns new matrix", ->
    {first, last} = doChain false
    assert.notEqual first, last

  test "into = new Matrix, returns passed in matrix", ->
    into = new Matrix
    {first, last} = doChain into
    assert.notEqual first, last
    assert.equal into, last
