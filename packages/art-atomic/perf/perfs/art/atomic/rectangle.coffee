{log, inspect} = require 'art-standard-lib'
Atomic = require 'art-atomic'

{matrix, Matrix, point, Point, rect, Rectangle, rgbColor, Color} = Atomic
testColor = rgbColor 1, 0, 0
testColorFromHTMLString = rgbColor "#f00"

suite "Art.Atomic.Rectangle", ->
  benchmark "rect()", ->
    rect()

  benchmark "new Rectangle", ->
    new Rectangle
, maxRunsPerSample: Math.pow(2, 30)

