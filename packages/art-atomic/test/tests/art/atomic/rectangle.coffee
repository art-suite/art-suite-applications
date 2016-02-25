{assert} = require 'art-foundation/src/art/dev_tools/test/art_chai'
{point, rect, Rectangle} = Atomic = require 'art-atomic'

suite "Art.Atomic.Rectangle", ->
  test "allocate rect from numbers", ->
    r = rect(5, 5, 10, 10)
    assert.eq point(5,5), r.location
    assert.eq point(10,10), r.size

  test "eq", ->
    assert.ok rect(1,2,3,4).eq rect(1,2,3,4)
    assert.ok !rect(1,2,3,4).eq rect(1,2,3,0)
    assert.ok !rect(1,2,3,4).eq rect(1,2,0,4)
    assert.ok !rect(1,2,3,4).eq rect(1,0,3,4)
    assert.ok !rect(1,2,3,4).eq rect(0,2,3,4)

  test "allocate rect from points", ->
    r = rect point(10, 20), point 30, 40
    assert.eq r, rect 10, 20, 30, 40

  test "allocate rect from one point", ->
    r = rect(point(10, 20))
    assert.eq r, rect 0, 0, 10, 20

  test "allocate rect from one number",  -> assert.eq rect(10),     rect 0, 0, 10, 10
  test "allocate rect from two numbers", -> assert.eq rect(10, 20), rect 0, 0, 10, 20
  test "allocate rect from array", ->
    assert.eq rect([10            ]), rect 0,  0,  10, 10
    assert.eq rect([10, 20        ]), rect 0,  0,  10, 20
    assert.eq rect([10, 20, 30, 40]), rect 10, 20, 30, 40

  test "allocate rect - no args", ->
    r = rect()
    assert.eq point(0,0), r.location
    assert.eq point(0,0), r.size

  test "x, y, w, h, width, height", ->
    r = rect(3, 5, 7, 11)
    assert.equal 3, r.x
    assert.equal 5, r.y
    assert.equal 7, r.w
    assert.equal 11, r.h
    assert.equal 7, r.width
    assert.equal 11, r.height

  test "size, location", ->
    r = rect(3, 5, 7, 11)
    assert.eq r.size, point 7, 11
    assert.eq r.location, point 3, 5

  test "eq", ->
    r1 = rect(3, 5, 7, 11)
    r2 = rect(3, 5, 7, 11)
    r3 = rect(4, 5, 7, 11)

    assert.ok r1.eq(r2)
    assert.ok !r1.eq(r3)

  test "tl, tr, bl, br", ->
    r1 = rect(3, 5, 7, 11)

    assert.eq point(3, 5), r1.tl
    assert.eq point(10, 5), r1.tr
    assert.eq point(3, 16), r1.bl
    assert.eq point(10, 16), r1.br

  test "corners", ->
    r1 = rect(3, 5, 7, 11)
    assert.eq r1.corners, [point(3, 5), point(10, 5), point(10, 16), point(3, 16)]

  test "top, left, right, bottom", ->
    r1 = rect(3, 5, 7, 11)

    assert.equal 5, r1.top
    assert.equal 3, r1.left
    assert.equal 10, r1.right
    assert.equal 16, r1.bottom

  test "grow", ->
    r1 = rect(3, 5, 7, 11)

    assert.eq r1.grow(1), rect(2, 4, 9, 13)
    assert.eq r1.grow(-1), rect(4, 6, 5, 9)


  test "overlap rectangles", ->
      # solidly overlapping
    assert.equal rect(0,0,10,10).overlaps(rect(0,0,10,10)), true
    assert.equal rect(0,0,10,10).overlaps(rect(0,5,10,10)), true
    assert.equal rect(0,0,10,10).overlaps(rect(5,0,10,10)), true

    # just below, just to the right, just above, just to the left
    assert.equal rect(0,0,10,10).overlaps(rect(10,0,10,10)), false
    assert.equal rect(0,0,10,10).overlaps(rect(0,10,10,10)), false
    assert.equal rect(10,0,10,10).overlaps(rect(0,0,10,10)), false
    assert.equal rect(0,10,10,10).overlaps(rect(0,0,10,10)), false

    # below, right, above, left
    assert.equal rect(0,0,10,10).overlaps(rect(11,0,10,10)), false
    assert.equal rect(0,0,10,10).overlaps(rect(0,11,10,10)), false
    assert.equal rect(11,0,10,10).overlaps(rect(0,0,10,10)), false
    assert.equal rect(0,11,10,10).overlaps(rect(0,0,10,10)), false

    # just overlapping below, right, above, left
    assert.equal rect(0,0,10,10).overlaps(rect(9,0,10,10)), true
    assert.equal rect(0,0,10,10).overlaps(rect(0,9,10,10)), true
    assert.equal rect(9,0,10,10).overlaps(rect(0,0,10,10)), true
    assert.equal rect(0,9,10,10).overlaps(rect(0,0,10,10)), true

  test ".overlaps? point", ->
    r1 = rect(5, 10, 15, 20)
    assert.equal r1.overlaps(point(10,10)), true
    assert.equal r1.overlaps(point(20,10)), false
    assert.equal r1.overlaps(point(10,30)), false
    assert.equal r1.overlaps(point(5, 9 )), false
    assert.equal r1.overlaps(point(4,10 )), false

  test ".union", ->
    assert.eq rect(0,0,10,10)   .union(rect(0,5,10,10)), rect(0,0,10,15)
    assert.eq rect(0,0,10,10)   .union(rect(5,0,10,10)), rect(0,0,15,10)
    assert.eq rect(20,20,10,10) .union(rect(0,0,10,10)), rect(0,0,30,30)

  test ".union and Rectangle.nothing", ->
    assert.eq Rectangle.nothing.size, point()
    assert.eq Rectangle.nothing.area, 0
    assert.eq Rectangle.nothing.union(rect()).area, 0
    assert.eq Rectangle.nothing.union(rect(10,20,30,40)), rect(10,20,30,40)

  test ".union and Rectangle.everything", ->
    assert.eq Rectangle.everything.size, point(Infinity, Infinity)
    assert.eq Rectangle.everything.area, Infinity
    assert.eq Rectangle.everything.union(rect()).area, Infinity
    assert.eq Rectangle.everything.union(rect(10,20,30,40)).area, Infinity

  test ".intersection with Rectangle.nothing", ->
    assert.eq rect(1,2,3,4).intersection(Rectangle.nothing).area, 0
    assert.eq Rectangle.nothing.intersection(rect(1,2,3,4)).area, 0

  test ".intersection with Rectangle.everything", ->
    assert.eq rect(-1,-2,3,4).intersection(Rectangle.everything), rect(-1, -2, 3, 4)
    assert.eq Rectangle.everything.intersection(rect(-1,-2,3,4)), rect(-1, -2, 3, 4)

  test ".intersection", ->
    assert.eq rect(0,0,10,10).intersection(rect(0,0,10,10))  , rect(0,0,10,10)
    assert.eq rect(0,0,10,10).intersection(rect(0,5,10,10))  , rect(0,5,10,5)
    assert.eq rect(0,0,10,10).intersection(rect(5,0,10,10))  , rect(5,0,5,10)
    assert.eq rect(0,0,10,10).intersection(rect(10,0,10,10)) , rect(0,0,0,0)
    assert.eq rect(0,0,10,10).intersection(rect(-5,-5,10,10)), rect(0,0,5,5)

  test "contains rect", ->
    assert.equal rect(0,0,10,10).contains(rect(2,2,5,5)), true
    assert.equal rect(0,0,10,10).contains(rect(8,2,5,5)), false

  test ".contains point", ->
    r1 = rect(5, 10, 15, 20)
    assert.equal r1.contains(point(10,10)), true
    assert.equal r1.contains(point(20,10)), false
    assert.equal r1.contains(point(10,30)), false
    assert.equal r1.contains(point(5,9)), false
    assert.equal r1.contains(point(4,10)), false

  test ".contains and .overlaps? with null", ->
    r1 = rect(5, 10, 15, 20)
    assert.equal r1.overlaps(null), false
    assert.equal r1.contains(null), false

  test ".area", ->
    assert.equal rect(5, 10, 15, 20).area, 300

  test "rect(a=rect()) should return a unaltered", ->
    p1 = rect(1,2,3,4)
    p2 = rect(1,2,3,4)
    p3 = rect(p1)

    assert.ok p1==p3
    assert.ok p1!=p2
    assert.ok p2!=p3
    assert.eq p1, p2

  test "a.roundOut()", ->
    assert.eq rect(1.1, 1.1, 2.4, 2.5).roundOut(),   rect 1, 1, 3, 3
    assert.eq rect(1.4, 1.1, 2.8, 2.5).roundOut(),   rect 1, 1, 4, 3
    assert.eq rect(1.8, 1.1, 2.1, 2.5).roundOut(),   rect 1, 1, 3, 3
    assert.eq rect(1.4, 0.9, 2.2, 2.5).roundOut(),   rect 1, 0, 3, 4

  test "a.roundOut(m)", ->
    assert.eq rect(1.6, 1.1, 2.1, 2.5).roundOut(.5),   rect 1.5, 1, 2.5, 3
    assert.eq rect(1.4, 1.1, 2.2, 2.5).roundOut(.5),   rect 1, 1, 3, 3

  test "a.roundOut(1, k)", ->
    assert.eq rect(1.4, .9, 2.2, 2.5).roundOut(1, .11), rect 1, 1, 3, 3

  test "a.roundOut(m, k)", ->
    assert.eq rect(1.4, 1.1, 2.2, 2.6).roundOut(.5, .11), rect 1.5, 1, 2, 3

  test "a.round: returns integer rectangle who's corners are closest to a's corners", ->
    assert.eq (r = rect(1.1, 1.1, 2.4, 2.5)).round(), rect(1, 1, 3, 3)
    assert.eq rect(r.location.round(), r.size.round()), rect(1, 1, 2, 3) # just rounding location and size is different than rectangle rounding
    assert.eq rect(1.4, 1.1, 2.8, 2.5).round(), rect(1, 1, 3, 3)
    assert.eq rect(1.8, 1.1, 2.1, 2.5).round(), rect(2, 1, 2, 3)

  test "interpolate 0, .5 and 1", ->
    r1 = new Rectangle 1, 2, 3, 4
    r2 = new Rectangle 3, 6, 9, 12
    assert.eq r1.interpolate(r2, 0), r1
    assert.eq r1.interpolate(r2, 1), r2
    assert.eq r1.interpolate(r2, .5), new Rectangle 2, 4, 6, 8

  test "add 1", ->
    assert.eq rect(2,3,4,5), rect(1, 2, 3, 4).add 1

  test "add point", ->
    assert.eq rect(11,22,13,24), rect(1, 2, 3, 4).add point 10, 20

  test "add rect", ->
    assert.eq rect(11,22,33,44), rect(1, 2, 3, 4).add rect(10, 20, 30, 40)
