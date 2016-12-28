Atomic = require 'art-atomic'
Foundation = require 'art-foundation'
{Canvas} = Neptune.Art
commonBitmapTests = require './common_bitmap_tests'
{merge, each, w, Binary, log, eq, defineModule, formattedInspect} = Foundation
{point, point0, point1, rect, rgbColor, matrix, Matrix} = Atomic
{Bitmap} = Canvas

targetBitmap = wideBitmap = tallBitmap = null

checker = (bitmap, checkerSize = 4) ->
  {width, height} = bitmap.size
  for x in [0...width] by checkerSize
    for y in [0...height] by checkerSize
      bitmap.drawRectangle point(x, y), point(checkerSize), color:"#000" if (x/checkerSize + y/checkerSize) % 2 == 0

targetBitmapSize = 100
commonSetup = ->
  targetBitmap = new Bitmap targetBitmapSize
  targetBitmap.clear "#eee"

  wideBitmap = new Bitmap point 32, 16
  tallBitmap = new Bitmap point 16, 32
  tallBitmap.drawRectangle null, tallBitmap.size, colors: w "#f00 #400"
  wideBitmap.drawRectangle null, wideBitmap.size, colors: w "#0f0 #040"

  checker wideBitmap
  checker tallBitmap


testWithOptions = (where, options = {}) ->
  test "#{formattedInspect options}, bitmap: wide", ->
    targetBitmap.drawBitmapWithLayout where, tallBitmap, options
    log {options, tallBitmap, targetBitmap}

  test "#{formattedInspect options}, bitmap: tall", ->
    targetBitmap.drawBitmapWithLayout where, wideBitmap, options
    log {options, wideBitmap, targetBitmap}

withLayoutTestSuite = (f) ->
  ->
    setup commonSetup
    f()

defineModule module, suite:
  drawBitmapWithLayout:
    zoom: withLayoutTestSuite ->

      testWithOptions null, layout: "zoom"
      testWithOptions null, layout: "zoom", aspectRatio: 1/2
      testWithOptions null, layout: "zoom", aspectRatio: 2

    fit: withLayoutTestSuite ->
      testWithOptions null, layout: "fit"
      testWithOptions null, layout: "fit", aspectRatio: 1/2
      testWithOptions null, layout: "fit", aspectRatio: 2

    stretch: withLayoutTestSuite ->
      testWithOptions null, layout: "stretch"

    bounded: withLayoutTestSuite ->
      testWithOptions point(10), layout: "stretch", targetSize: point 80
      testWithOptions point(10), layout: "zoom",    targetSize: point 80
      testWithOptions point(10), layout: "fit",     targetSize: point 80

    sourceArea: withLayoutTestSuite ->
      testWithOptions null,       layout: "zoom", sourceArea: point 12
      testWithOptions point(10),  layout: "zoom", sourceArea: point(12), targetSize: point(80), aspectRatio: 2
