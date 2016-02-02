Foundation = require 'art-foundation'
Atomic = require 'art-atomic'

{log, inspect} = Foundation
{matrix, Matrix, point, Point, rect, Rectangle, color, Color} = Atomic
testColor = color 1, 0, 0
testColorFromHTMLString = color "#f00"

suite "Art.Atomic.Rectangle", ->
  benchmark "rect()", ->
    rect()

  benchmark "new Rectangle", ->
    new Rectangle
, maxRunsPerSample: Math.pow(2, 30)

