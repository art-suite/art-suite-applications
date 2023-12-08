{log, inspect} = require 'art-standard-lib'
Atomic = require 'art-atomic'

{matrix, Matrix, point, Point, rect, Rectangle, rgbColor, Color} = Atomic
testColor = rgbColor 1, 0, 0
testColorFromHTMLString = rgbColor "#f00"

suite "Art.Atomic.Point", ->
  benchmark "point()", ->
    point()

  benchmark "new Point", ->
    new Point
, minRunsPerSample: Math.pow(2, 22)
, maxRunsPerSample: Math.pow(2, 30)
