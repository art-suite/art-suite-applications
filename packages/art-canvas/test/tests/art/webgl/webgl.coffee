define [
  'art.foundation/src/art/dev_tools/test/art_chai'
  'art.foundation'
  'art.canvas'
  'art.atomic'
  '../../../../src/art/webgl'
  '../canvas/common_bitmap_tests'
  # 'extlib/webgl-debug'
], (Chai, Foundation, Canvas, Atomic, Webgl, commonBitmapTests) ->
  {assert} = Chai
  {Binary, inspect, log} = Foundation
  {EncodedImage} = Binary
  {point, rect, color} = Atomic

  array = (a) -> i for i in a
  reducedRange = (data, factor = 32) ->
    Math.round a / factor for a in data

  webglContext = null
  commonBitmapTests
    newBitmap: ->
      webglContext ||= new Webgl.Bitmap point 100
      webglContext.newBitmap arguments...
    "Webgl.Bitmap"

  suite "Art.Webgl.Bitmap", ->
    test "detect", ->
      assert Webgl.Detector.detect()

    test "gradientBitmap", ->
      canvasBitmap = new Webgl.Bitmap point 11, 1
      canvasBitmap.clear "#777"
      gfs = new Canvas.GradientFillStyle point(0,0), point(100,0), 0:"#000", .75:"#f00", 1:"#000"
      b = canvasBitmap.gradientBitmap gfs, canvasBitmap.size
      canvasBitmap.drawBitmap null, b
      log canvasBitmap

      data = canvasBitmap.getImageDataArray "red"
      assert.eq data, [15, 46, 77, 108, 139, 170, 201, 232, 232, 139, 46]

    test "clipping area on non-texture", ->
      bitmap = new Webgl.Bitmap point 4
      bitmap.drawRectangle null, bitmap.size, color:"#ff0"
      bitmap.setClippingArea rect 1, 1, 2, 1
      bitmap.drawRectangle null, bitmap.size, color:"#0ff"
      log bitmap

      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        8, 8, 8, 8
        8, 0, 0, 8
        8, 8, 8, 8
        8, 8, 8, 8
      ]

    test "normal compositing on opaque background", ->
      canvasBitmap = new Webgl.Bitmap point 3, 6
      canvasBitmap.clear color 0, 0, 0, 1
      canvasBitmap.drawRectangle null, rect(0,0,1,1), color:color .25, 0, 0, 1
      canvasBitmap.drawRectangle null, rect(1,0,1,1), color:color .50, 0, 0, 1
      canvasBitmap.drawRectangle null, rect(2,0,1,1), color:color .75, 0, 0, 1

      canvasBitmap.drawRectangle null, rect(0,1,1,1), color:color 1, 0, 0, .25
      canvasBitmap.drawRectangle null, rect(1,1,1,1), color:color 1, 0, 0, .5
      canvasBitmap.drawRectangle null, rect(2,1,1,1), color:color 1, 0, 0, .75

      canvasBitmap.drawRectangle null, rect(0,2,3,1), color:color 1, 0, 0, 1
      canvasBitmap.drawRectangle null, rect(0,2,1,1), color:color 0, 0, 1, .25
      canvasBitmap.drawRectangle null, rect(1,2,1,1), color:color 0, 0, 1, .5
      canvasBitmap.drawRectangle null, rect(2,2,1,1), color:color 0, 0, 1, .75

      canvasBitmap.drawRectangle null, rect(0,3,1,1), color:color 0, 0, 1, .25
      canvasBitmap.drawRectangle null, rect(1,3,1,1), color:color 0, 0, 1, .5
      canvasBitmap.drawRectangle null, rect(2,3,1,1), color:color 0, 0, 1, .75

      canvasBitmap.drawRectangle null, rect(0,4,1,1), color:color 0, 0, .25, 1
      canvasBitmap.drawRectangle null, rect(1,4,1,1), color:color 0, 0, .50, 1
      canvasBitmap.drawRectangle null, rect(2,4,1,1), color:color 0, 0, .75, 1

      log canvasBitmap

      data = canvasBitmap.getImageDataArray() # I don't believe getImageData actually works correctly if there is transparency
      assert.eq data, [
        64, 0, 0, 255,
        127, 0, 0, 255,
        191, 0, 0, 255,

        64, 0, 0, 255,
        127, 0, 0, 255,
        191, 0, 0, 255,

        191, 0, 64, 255,
        128, 0, 127, 255,
        64, 0, 191, 255,

        0, 0, 64, 255,
        0, 0, 127, 255,
        0, 0, 191, 255,

        0, 0, 64, 255,
        0, 0, 127, 255,
        0, 0, 191, 255,

        0, 0, 0, 255,
        0, 0, 0, 255,
        0, 0, 0, 255]
