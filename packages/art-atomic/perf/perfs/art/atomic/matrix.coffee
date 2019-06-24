{log, inspect} = require 'art-standard-lib'
Atomic = require 'art-atomic'

{matrix, Matrix, point, Point, rect, Rectangle, color, Color} = Atomic
testColor = color 1, 0, 0
testColorFromHTMLString = color "#f00"


suite "Art.Atomic.Matrix", ->
  offset = point 1, 1
  m = Matrix.scale(3.5, 2.5).translate(3, 4).rotate(Math.PI/4)
  simpleM = Matrix.scale(3.5, 2.5).translate(3, 4)
  m2 = Matrix.scale(24, -.5).translate(-6, 9).rotate(Math.PI/5)
  r = new Rectangle 1, 2, 3, 4

  p = point(1,2)
  #warmup
  Matrix.translate offset for i in [0..9999]
  matrix().translate offset for i in [0..9999]
  m.transform p for i in [0..9999]
  m.transformBoundingRect r for i in [0..9999]
  simpleM.transformBoundingRect r for i in [0..9999]
  m.invert() for i in [0..9999]
  m.mul m2 for i in [0..9999]


  benchmark "Matrix.translate", ->
    Matrix.translate offset

  benchmark "matrix().translate", ->
    matrix().translate offset

  benchmark "transform point", ->
    m.transform p

  benchmark "transformBoundingRect retangle", ->
    m.transformBoundingRect r

  benchmark "simple transformBoundingRect retangle", ->
    simpleM.transformBoundingRect r

  benchmark "invert", ->
    m.invert()

  benchmark "mul", ->
    m.mul m2

, maxRunsPerSample: Math.pow(2, 30)
, minRunsPerSample: Math.pow(2, 20)
