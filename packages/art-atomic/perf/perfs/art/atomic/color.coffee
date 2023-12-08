{log, inspect} = require 'art-standard-lib'
Atomic = require 'art-atomic'

{matrix, Matrix, point, Point, rect, Rectangle, rgbColor, Color} = Atomic
testColor = rgbColor 1, 0, 0
testColorFromHTMLString = rgbColor "#f00"

suite "Art.Atomic.Color", ->
  benchmark "rgbColor('red') warmup", ->
    rgbColor 'red'

  benchmark "rgbColor('red')", ->
    rgbColor 'red'

  benchmark "rgbColor('#f00')", ->
    rgbColor '#f00'

  benchmark "rgbColor('#f000')", ->
    rgbColor '#f000'

  benchmark "rgbColor('#ff0000')", ->
    rgbColor '#ff0000'

  benchmark "rgbColor('#ff000000')", ->
    rgbColor '#ff000000'

  benchmark "rgbColor('rgb(255, 0, 0)')", ->
    rgbColor 'rgb(255, 0, 0)'

  benchmark "rgbColor('rgba(255, 0, 0, .5)')", ->
    rgbColor 'rgba(255, 0, 0, .5)'

  benchmark "rgbColor('rgb(100%, 0, 0)')", ->
    rgbColor 'rgb(100%, 0, 0)'

  benchmark "rgbColor('rgba(100%, 0, 0, .5)')", ->
    rgbColor 'rgba(100%, 0, 0, .5)'

  benchmark "rgbColor(1,0,0)", ->
    rgbColor 1, 0, 0

  benchmark "testColor.toString()", ->
    testColor.toString()

  benchmark "testColorFromHTMLString.toString()", ->
    testColorFromHTMLString.toString()

  benchmark "rgbColor('#f00').toString()", ->
    rgbColor('#f00').toString()

  benchmark "rgbColor('red').toString()", ->
    rgbColor('red').toString()

  benchmark "rgbColor(1, 0, 0).toString()", ->
    rgbColor(1, 0, 0).toString()

  benchmark "rgbColor('#f000').toString()", ->
    rgbColor('#f000').toString()

, minRunsPerSample: Math.pow(2, 16)
