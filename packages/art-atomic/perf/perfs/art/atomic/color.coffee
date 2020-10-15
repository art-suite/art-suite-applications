{log, inspect} = require 'art-standard-lib'
Atomic = require 'art-atomic'

{matrix, Matrix, point, Point, rect, Rectangle, color, Color} = Atomic
testColor = color 1, 0, 0
testColorFromHTMLString = color "#f00"

suite "Art.Atomic.Color", ->
  benchmark "color('red') warmup", ->
    color 'red'

  benchmark "color('red')", ->
    color 'red'

  benchmark "color('#f00')", ->
    color '#f00'

  benchmark "color('#f000')", ->
    color '#f000'

  benchmark "color('#ff0000')", ->
    color '#ff0000'

  benchmark "color('#ff000000')", ->
    color '#ff000000'

  benchmark "color('rgb(255, 0, 0)')", ->
    color 'rgb(255, 0, 0)'

  benchmark "color('rgba(255, 0, 0, .5)')", ->
    color 'rgba(255, 0, 0, .5)'

  benchmark "color('rgb(100%, 0, 0)')", ->
    color 'rgb(100%, 0, 0)'

  benchmark "color('rgba(100%, 0, 0, .5)')", ->
    color 'rgba(100%, 0, 0, .5)'

  benchmark "color(1,0,0)", ->
    color 1, 0, 0

  benchmark "testColor.toString()", ->
    testColor.toString()

  benchmark "testColorFromHTMLString.toString()", ->
    testColorFromHTMLString.toString()

  benchmark "color('#f00').toString()", ->
    color('#f00').toString()

  benchmark "color('red').toString()", ->
    color('red').toString()

  benchmark "color(1, 0, 0).toString()", ->
    color(1, 0, 0).toString()

  benchmark "color('#f000').toString()", ->
    color('#f000').toString()

, minRunsPerSample: Math.pow(2, 16)
