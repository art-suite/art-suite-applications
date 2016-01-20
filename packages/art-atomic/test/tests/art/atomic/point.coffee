{assert} = require 'art-foundation/src/art/dev_tools/test/art_chai'
{inspect} = Foundation = require 'art-foundation'
{point, Point} = Atomic = require 'art-atomic'

suite "Art.Atomic.Point", ->
  test "allocate point", ->
    p = new Point(3, 7)
    assert.equal 3, p.x
    assert.equal 7, p.y

  test "vectorLength", ->
    p = point()
    assert.eq p.vectorLength, 2

  test "vector", ->
    p = point 3, 4
    assert.eq p.vector, [3, 4]

  test "from vector", ->
    p = point [3, 4]
    assert.eq p, point 3, 4

  test "toArray", ->
    p = point a = [3, 4]
    assert.eq p.toArray(), a

  test "from object", ->
    a = x:10, y:20
    assert.eq point(a), point 10, 20

  test "named point constructor", ->
    assert.eq Point.point0      , point "point0"
    assert.eq Point.point1      , point "point1"
    assert.eq Point.topLeft     , point "topLeft"
    assert.eq Point.topCenter   , point "topCenter"
    assert.eq Point.topRight    , point "topRight"
    assert.eq Point.centerLeft  , point "centerLeft"
    assert.eq Point.centerCenter, point "centerCenter"
    assert.eq Point.centerRight , point "centerRight"
    assert.eq Point.bottomLeft  , point "bottomLeft"
    assert.eq Point.bottomCenter, point "bottomCenter"
    assert.eq Point.bottomRight , point "bottomRight"

  test "inspect", ->
    p = point 3, 4
    inspected = inspect p
    assert.eq inspected, "point(3, 4)"

  test "appendVector", ->
    p = point 3, 4
    v = [123, 456]
    p.appendToVector v
    assert.eq v, [123, 456, 3, 4]

  test "allocate point : 1-arg", ->
    p = new Point(3)
    assert.equal 3, p.x
    assert.equal 3, p.y

  test "allocate point : 0-args", ->
    p = new Point()
    assert.equal 0, p.x
    assert.equal 0, p.y

  test "point string parsing", ->
    assert.eq point("4,5"), point(4, 5)
    assert.eq point("(4,5)"), point(4, 5)
    assert.eq point("(-234.34,5.234)"), point(-234.34,5.234)

  test "lt lte", ->
    p1 = new Point(3, 7)
    p2 = new Point(5, 11)
    p3 = new Point(4, 1)

    assert.ok (p1.lt p2)
    assert.ok !(p2.lt p1)
    assert.ok !(p1.lt p3)
    assert.ok !(p3.lt p1)
    assert.ok !(p1.lt p1)

    assert.ok (p1.lte p2)
    assert.ok !(p2.lte p1)
    assert.ok !(p1.lte p3)
    assert.ok !(p3.lte p1)
    assert.ok (p1.lte p1)

  test "gt gte", ->
    p1 = new Point(3, 7)
    p2 = new Point(5, 11)
    p3 = new Point(4, 1)

    assert.ok (p2.gt p1)
    assert.ok !(p1.gt p2)
    assert.ok (p2.gt p3)
    assert.ok !(p3.gt p2)
    assert.ok !(p2.gt p2)

    assert.ok (p2.gte p1)
    assert.ok !(p1.gte p2)
    assert.ok (p2.gte p3)
    assert.ok !(p3.gte p2)
    assert.ok (p2.gte p2)

  test "add", ->
    p1 = point 3, 7
    p2 = point 5, 11

    assert.eq point(8, 18), p1.add p2
    assert.eq point(8, 18), p1.add p2.x, p2.y
    assert.eq point(8, 12), p1.add p2.x

  test "sub", ->
    p1 = point 3, 7
    p2 = point 5, 11

    assert.eq point(2, 4), p2.sub p1
    assert.eq point(2, 4), p2.sub p1.x, p1.y
    assert.eq point(2, 8), p2.sub p1.x

  test "mul", ->
    p1 = point 3, 7
    p2 = point 5, 11

    assert.eq point(15, 77), p1.mul p2
    assert.eq point(15, 77), p1.mul p2.x, p2.y
    assert.eq point(15, 35), p1.mul p2.x

  test "div", ->
    p1 = point(3, 7)
    p2 = point(6, 21)

    assert.eq point(2, 3), p2.div p1
    assert.eq point(2, 3), p2.div p1.x, p1.y
    assert.eq point(2, 7), p2.div p1.x

  test "area", ->
    assert.equal 10, point(2,5).area

  test "min null", ->
    assert.equal 2, point(2,5).min()

  test "max null", ->
    assert.equal 5, point(2,5).max()

  test "min", ->
    assert.deepEqual point(2,-1), point(2,5).min(point(3,-1))

  test "max", ->
    assert.deepEqual point(3,5), point(2,5).max(point(3,-1))

  test "bound", ->
    assert.deepEqual point(2,3), point(1,1).bound(point(2, 3), point(7, 11))
    assert.deepEqual point(2,11), point(1,15).bound(point(2, 3), point(7, 11))
    assert.deepEqual point(7,3), point(10,1).bound(point(2, 3), point(7, 11))
    assert.deepEqual point(7,11), point(10,15).bound(point(2, 3), point(7, 11))
    assert.deepEqual point(2,3), point(2,3).bound(point(2, 3), point(7, 11))
    assert.deepEqual point(2.5,3.5), point(2.5,3.5).bound(point(2, 3), point(7, 11))

  test "point(a=point()) should return a unaltered", ->
    p1 = point(1,2)
    p2 = point(1,2)
    p3 = point(p1)

    assert.ok p1==p3
    assert.ok p1!=p2
    assert.ok p2!=p3
    assert.deepEqual p1, p2

  test "round(1)", ->
    assert.eq point(1.75, 3.25).round(), point(2, 3)
    assert.eq point(-1.75, -3.25).round(), point(-2, -3)
    assert.eq point(1.5, -1.5).round(), point(2, -1)
    assert.eq point(1.4999, -1.4999).round(), point(1, -1)
    assert.eq point(1.5001, -1.5001).round(), point(2, -2)

  test "round(not 1)", ->
    assert.eq point(15.3, 13.4).round(10), point(20, 10)

    assert.eq point(15.33, 13.43).round(.1), point(15.3, 13.4)

    assert.deepEqual point(45, 30).round(13), point(39, 26)

  test "floor", ->
    assert.eq point(15.9, 14.1).floor(), point(15, 14)
    assert.eq point(-15.9, -14.1).floor(), point(-16, -15)

  test "ceil", ->
    assert.eq point(15.9, 14.1).ceil(), point(16, 15)
    assert.eq point(-15.9, -14.1).ceil(), point(-15, -14)

  test "magnitudeSquared", ->
    assert.equal point(5, 5).magnitudeSquared, 50
    assert.equal point(3, 4).magnitudeSquared, 25
    assert.equal point(0, 5).magnitudeSquared, 25
    assert.equal point(5, 0).magnitudeSquared, 25
    assert.equal point(-1, 5).magnitudeSquared, 26
    assert.equal point(5, -1).magnitudeSquared, 26

  test "magnitude", ->
    assert.equal point(5, 5).magnitude,  Math.sqrt 50
    assert.equal point(3, 4).magnitude,  5
    assert.equal point(0, 5).magnitude,  5
    assert.equal point(5, 0).magnitude,  5
    assert.equal point(-1, 5).magnitude, Math.sqrt 26
    assert.equal point(5, -1).magnitude, Math.sqrt 26

  test "distance", ->
    assert.equal point(3, 4).distance(point(0, 0)), 5
    assert.equal point(6, 8).distance(point(3, 4)), 5
    assert.equal point(1, 1).distance(point(-2, -3)), 5

  test "distanceSquared", ->
    assert.equal point(3, 4).distanceSquared(point(0, 0)), 25
    assert.equal point(6, 8).distanceSquared(point(3, 4)), 25
    assert.equal point(1, 1).distanceSquared(point(-2, -3)), 25

  test "magnitude", ->
    assert.equal point(5, 5).magnitude,  Math.sqrt 50
    assert.equal point(3, 4).magnitude,  5
    assert.equal point(0, 5).magnitude,  5
    assert.equal point(5, 0).magnitude,  5
    assert.equal point(-1, 5).magnitude, Math.sqrt 26
    assert.equal point(5, -1).magnitude, Math.sqrt 26

  test "dot", ->
    assert.eq point(5,4).dot(point 2, 4), 26
    assert.eq point(1,9).dot(point 3, -2), -15

  test "cross", ->
    assert.eq point(5,4).cross(point 2, 4), 12
    assert.eq point(1,9).cross(point 3, -2), -29

  test "point0", -> assert.eq Point.point0, point()
  test "point1", -> assert.eq Point.point1, point 1

  test "interpolate 0, .5, and 1", ->
    p1 = point 1, 2
    p2 = point 3, 6
    assert.eq p1.interpolate(p2, 0), p1
    assert.eq p1.interpolate(p2, 1), p2
    assert.eq p1.interpolate(p2, .5), point 2, 4
