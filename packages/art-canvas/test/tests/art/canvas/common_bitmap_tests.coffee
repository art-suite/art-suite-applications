Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
{Canvas} = Neptune.Art

{point, rect, color, matrix, Matrix} = Atomic
{inspect, log, eq} = Foundation
{Binary} = Foundation
{EncodedImage} = Binary
{BitmapBase, Bitmap, GradientFillStyle} = Canvas

(bitmapFactory, bitmapClassName) ->

  compositeModes = [
    "add"
    "normal"
    "target_alphamask"
    "alphamask"
    "destover"
    "sourcein"
  ]

  generateCompositingTestBitmap = (clearColor, c1, c2) ->
    a = bitmapFactory.newBitmap point 3
    a.clear clearColor
    a.drawRectangle point(0), point(2), color:c1

    b = bitmapFactory.newBitmap point 3
    b.clear clearColor
    b.drawRectangle point(1), point(2), color:c2
    s = b.size
    step = s
    dest = bitmapFactory.newBitmap step.mul point(1, compositeModes.length)

    for compositeMode, mi in compositeModes
      p = point(0, mi).floor().mul step
      temp = bitmapFactory.newBitmap b.size
      temp.drawBitmap point(), a
      temp.drawBitmap point(), b, compositeMode:compositeMode
      dest.drawBitmap p, temp
      # dest.drawBitmap p, a
      # dest.drawBitmap p, b, "source-atop"
    dest

  defaultCheckerColor1 = "#777"
  defaultCheckerColor2 = "white"

  # options
  #   c1: first square color
  #   c2: other square color
  #   size: square size
  draw2x2Checkers = (target, c1, c2)->
    c1 ||= defaultCheckerColor1
    c2 ||= defaultCheckerColor2
    size = target.size.div 2
    target.clear c2
    p = point size
    target.drawRectangle null, p, color:c1
    target.drawRectangle p, p, color:c1
    target

  # numCheckers is a point:
  #   .x = num horizontal checkers
  #   .y = num vertical checkers
  drawCheckers = (target, numCheckers, c1, c2, targetArea)->
    targetArea ||= rect target.size
    c1 ||= defaultCheckerColor1
    c2 ||= defaultCheckerColor2

    checkerSize = targetArea.size.div numCheckers
    xPos = yPos = 0
    while yPos < numCheckers.y
      xPos = 0
      while xPos < numCheckers.x
        c = if ((xPos+yPos)%2) == 0 then c1 else c2
        loc = point targetArea.x + xPos * checkerSize.x, targetArea.y + yPos * checkerSize.y
        target.drawRectangle loc, checkerSize, color:c
        xPos++
      yPos++



  reducedRange = (data, factor = 32) ->
    Math.round a / factor for a in data

  dataWithin = (data1, data2, factor = 0, comment) ->
    assert.eq data1.length, data2.length
    for d1, i in data1
      d2 = data2[i]
      diff = Math.abs(d2-d1)
      assert.ok diff <= factor, "data at index #{i} differs by #{diff} (d1:#{d1}, d2:#{d2}) #{comment}\ndata1: #{inspect data1}\ndata2: #{inspect data2}\n"

  suite "Art.#{bitmapClassName} common bitmap tests", ->
    test "#{bitmapClassName} newBitmap", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      assert.eq bitmap.size, point 2, 2
      data = bitmap.getImageDataArray()
      assert.eq data, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      assert.ok bitmap instanceof BitmapBase

    test "clear to a specific color", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      bitmap.clear color 64/255.0, 127/255.0, 191/255.0, 255/255.0
      console.error "common bitmap tests - attempting to log(a)", bitmap, log
      log bitmap
      console.error "common bitmap tests - attempting to log(b)"
      data = bitmap.getImageDataArray()
      assert.eq data, [
        64, 127, 191, 255,
        64, 127, 191, 255,

        64, 127, 191, 255,
        64, 127, 191, 255
      ]

    test "supportedCompositeModes and bitmap.compositeModeSupported(mode)", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      supportedCompositeModes = bitmap.supportedCompositeModes
      assert.eq bitmap.supportedCompositeModes, bitmap.class.supportedCompositeModes

      for mode in compositeModes
        assert.ok supportedCompositeModes.indexOf(mode) >= 0
        assert.ok bitmap.compositeModeSupported mode

      assert.ok !(supportedCompositeModes.indexOf("something funky") >= 0)
      assert.ok !bitmap.compositeModeSupported "something funky"

    test "clipping area", ->
      bitmap = bitmapFactory.newBitmap point 4
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

    test "clippedTo area", ->
      bitmap = bitmapFactory.newBitmap point 4
      bitmap.drawRectangle null, bitmap.size, color:"#ff0"

      bitmap.clippedTo rect(1, 1, 2, 2), ->
        bitmap.drawRectangle null, bitmap.size, color:"#f0f"
        bitmap.clippedTo rect(0, 0, 2, 4), ->
          bitmap.drawRectangle null, bitmap.size, color:"#0ff"

      log bitmap
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        8, 8, 8, 8
        8, 0, 8, 8
        8, 0, 8, 8
        8, 8, 8, 8
      ]

    test "clippedTo rolls back", ->
      # clipping rolls back
      bitmap = bitmapFactory.newBitmap point 4
      bitmap.drawRectangle null, bitmap.size, color:"#ff0"

      bitmap.clippedTo rect(1, 1, 2, 2), ->
        bitmap.drawRectangle null, bitmap.size, color:"#0ff"

      log bitmap
      bitmap.drawRectangle null, bitmap.size, color:"#f0f"
      log bitmap
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        8, 8, 8, 8
        8, 8, 8, 8
        8, 8, 8, 8
        8, 8, 8, 8
      ]

    test "clone", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      bitmap.clear color 64/255.0, 127/255.0, 191/255.0, 255/255.0
      b2 = bitmap.clone()
      log bitmap
      log b2
      data = b2.getImageDataArray()
      assert.neq bitmap, b2
      assert.eq bitmap.size, b2.size
      assert.eq data, [
        64, 127, 191, 255,
        64, 127, 191, 255,

        64, 127, 191, 255,
        64, 127, 191, 255
      ]

    test "new bitmap same size", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      b2 = bitmap.newBitmap()
      assert.neq bitmap, b2
      assert.eq bitmap.size, b2.size

    test "clear to a transparent color", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      bitmap.clear color 1, .5, 0, .5
      log bitmap
      data = bitmap.getImageDataArray()
      assert.eq reducedRange(data), [
        8, 4, 0, 4,
        8, 4, 0, 4,
        8, 4, 0, 4,
        8, 4, 0, 4
      ]

    test "getImageDataArray with <1 alpha pixels", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      bitmap.clear()
      bitmap.drawRectangle point(0,0), point(1,1), color:color 1, 1, 1, .25
      bitmap.drawRectangle point(1,0), point(1,1), color:color 1, 1, 1, .50
      bitmap.drawRectangle point(0,1), point(1,1), color:color 1, 1, 1, .75
      bitmap.drawRectangle point(1,1), point(1,1), color:color 1, 1, 1, 0
      log bitmap
      assert.eq reducedRange(bitmap.getImageDataArray()), [
        8, 8, 8, 2,   8, 8, 8, 4,
        8, 8, 8, 6,   0, 0, 0, 0,
      ]


    test "clear()", ->
      bitmap = bitmapFactory.newBitmap point 2, 2
      bitmap.clear()
      log bitmap
      assert.eq bitmap.getImageDataArray(), [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    test "drawRectangle", ->
      bitmap = bitmapFactory.newBitmap point(4, 4)
      bitmap.drawRectangle null, rect(1, 1, 2, 2), color:"red"
      bitmap.drawRectangle null, rect(2, 2, 5, 5), color:"#770"
      log bitmap
      assert.eq bitmap.getImageDataArray("red"), [
        0,   0,   0,   0,
        0, 255, 255,   0,
        0, 255, 119, 119,
        0,   0, 119, 119
      ]

    test "drawRectangle with transparency", ->
      bitmap = bitmapFactory.newBitmap point(4, 4)
      draw2x2Checkers bitmap
      bitmap.drawRectangle null, rect(1, 1, 2, 2), color:color 1,0,0,.5
      log bitmap
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        4, 4, 8, 8,
        4, 6, 8, 8,
        8, 8, 6, 4,
        8, 8, 4, 4,
      ]

    test "drawRectangle with transparency 2", ->
      bitmap = bitmapFactory.newBitmap point(4, 4)
      bitmap.clear "black"
      bitmap.drawRectangle null, rect(0, 0, 1, 4), color:color 1, .5, 0, 0
      bitmap.drawRectangle null, rect(1, 0, 1, 4), color:color 1, .5, 0, .25
      bitmap.drawRectangle null, rect(2, 0, 1, 4), color:color 1, .5, 0, .5
      bitmap.drawRectangle null, rect(3, 0, 1, 4), color:color 1, .5, 0, .75
      log bitmap
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        0, 2, 4, 6,
        0, 2, 4, 6,
        0, 2, 4, 6,
        0, 2, 4, 6,
      ]

    test "drawRectangle with transparency on transparency 5x5", ->
      bitmap = bitmapFactory.newBitmap point 5
      bitmap.drawRectangle null, rect(i, 0, 1, 5), color:color 1, 0, 0, i/4 for i in [0..4]
      bitmap.drawRectangle null, rect(0, i, 5, 1), color:color 0, 1, 0, i/4 for i in [0..4]

      # opaqueBitmap = bitmapFactory.newBitmap point 3
      # opaqueBitmap.clear "white"
      # opaqueBitmap.drawBitmap null, bitmap
      log bitmap

      # assert.eq reducedRange(bitmap.getImageDataArray()), [
      #   0, 0, 0, 0,   8, 0, 0, 2,   8, 0, 0, 4,   8, 0, 0, 6,   8, 0, 0, 8,
      #   0, 8, 0, 2,   3, 5, 0, 3,   5, 3, 0, 5,   6, 2, 0, 6,   6, 2, 0, 8,
      #   0, 8, 0, 4,   2, 6, 0, 5,   3, 5, 0, 6,   3, 5, 0, 7,   4, 4, 0, 8,
      #   0, 8, 0, 6,   1, 7, 0, 6,   1, 7, 0, 7,   2, 6, 0, 7,   2, 6, 0, 8,
      #   0, 8, 0, 8,   0, 8, 0, 8,   0, 8, 0, 8,   0, 8, 0, 8,   0, 8, 0, 8
      # ]

      dataWithin bitmap.getImageDataArray(), [
        0,   0, 0,   0,   255,   0, 0,  63,   255,   0, 0, 127,   255,   0, 0, 191,   255,   0, 0, 255,
        0, 255, 0,  63,   109, 146, 0, 110,   153, 102, 0, 158,   177,  78, 0, 206,   192,  63, 0, 254,
        0, 255, 0, 127,    50, 205, 0, 158,    85, 170, 0, 190,   109, 146, 0, 222,   127, 127, 0, 254,
        0, 255, 0, 191,    19, 236, 0, 206,    36, 219, 0, 222,    50, 205, 0, 238,    63, 192, 0, 254,
        0, 255, 0, 255,     0, 255, 0, 255,     0, 255, 0, 255,     0, 255, 0, 255,     0, 255, 0, 255
      ], 2


    test "drawRectangle pixelSnap baseline", ->
      bitmap = bitmapFactory.newBitmap point(4, 4)
      bitmap.clear "#000"
      bitmap.pixelSnap = false
      bitmap.drawRectangle null, rect(1.25, 1.25, 1.75, 1.3), color:"red"
      log bitmap
      imageData = bitmap.getImageDataArray("red")
      assert.within [
        0,   0,   0,   0,
        0, 145, 192,   0,
        0, 105, 141,   0,
        0,   0,   0,   0
      ], imageData, [
        0,   0,   0,   0,
        0, 145, 192,   0,
        0, 105, 141,   0,
        0,   0,   0,   0
      ]

    test "drawRectangle pixelSnap on", ->
      bitmap = bitmapFactory.newBitmap point(4, 4)
      bitmap.pixelSnap = true
      bitmap.clear "#000"
      bitmap.drawRectangle null, rect(1.25, 1.25, 1.75, 1.2), color:"red"
      log bitmap
      imageData = bitmap.getImageDataArray("red")
      assert.eq imageData, [
        0,   0,   0, 0,
        0, 255, 255, 0,
        0,   0,   0, 0,
        0,   0,   0, 0
      ]

    test "drawBitmap on bitmap", ->
      canvasBitmap = bitmapFactory.newBitmap point 3
      textureBitmap = bitmapFactory.newBitmap point 2

      assert.eq textureBitmap.size, point 2

      textureBitmap.clear color 1, 0, 0, 1
      textureBitmap.drawRectangle null, point(1,2), color:color 0, 127/255.0, 1, 1

      canvasBitmap.drawBitmap point(1, 1), textureBitmap
      log canvasBitmap
      data = canvasBitmap.getImageDataArray()
      assert.eq reducedRange(data), [
        0, 0, 0, 0,   0, 0, 0, 0,   0, 0, 0, 0,
        0, 0, 0, 0,   0, 4, 8, 8,   8, 0, 0, 8,
        0, 0, 0, 0,   0, 4, 8, 8,   8, 0, 0, 8
      ]

    test "drawBitmap section", ->
      source = bitmapFactory.newBitmap point 4, 4
      source.clear color 1, 1, 0, 1
      source.drawRectangle point(1), point(2), color:color 1, 0, 0, 1

      target = bitmapFactory.newBitmap point 4, 4
      target.clear color .5, .5, .5, 1
      target.drawBitmap point(1), source, sourceArea:rect 2,2,2,2

      assert.eq reducedRange(source.getImageDataArray()), [
        8, 8, 0, 8,   8, 8, 0, 8,   8, 8, 0, 8,   8, 8, 0, 8,
        8, 8, 0, 8,   8, 0, 0, 8,   8, 0, 0, 8,   8, 8, 0, 8,
        8, 8, 0, 8,   8, 0, 0, 8,   8, 0, 0, 8,   8, 8, 0, 8,
        8, 8, 0, 8,   8, 8, 0, 8,   8, 8, 0, 8,   8, 8, 0, 8
      ]

      assert.eq reducedRange(target.getImageDataArray()), [
        4, 4, 4, 8,   4, 4, 4, 8,   4, 4, 4, 8,   4, 4, 4, 8,
        4, 4, 4, 8,   8, 0, 0, 8,   8, 8, 0, 8,   4, 4, 4, 8,
        4, 4, 4, 8,   8, 8, 0, 8,   8, 8, 0, 8,   4, 4, 4, 8,
        4, 4, 4, 8,   4, 4, 4, 8,   4, 4, 4, 8,   4, 4, 4, 8
      ]

    test "drawBitmap on bitmap with transparency", ->
      canvasBitmap = bitmapFactory.newBitmap point 3
      canvasBitmap.clear "white"
      textureBitmap = bitmapFactory.newBitmap point 2

      assert.eq textureBitmap.size, point 2

      textureBitmap.clear color 1, 0, 0, 1
      textureBitmap.drawRectangle null, point(1,2), color:color 0, 127/255.0, 1, 1

      canvasBitmap.drawBitmap point(1, 1), textureBitmap, opacity:.5
      log canvasBitmap
      log textureBitmap
      assert.eq reducedRange(textureBitmap.getImageDataArray()), [
        0, 4, 8, 8,   8, 0, 0, 8,
        0, 4, 8, 8,   8, 0, 0, 8
      ]

      [
        8, 8, 8, 8,   8, 8, 8, 8,   8, 8, 8, 8,
        8, 8, 8, 8,   4, 8, 8, 8,   8, 4, 4, 8,
        8, 8, 8, 8,   4, 8, 8, 8,   8, 4, 4, 8
      ]


      assert.eq reducedRange(canvasBitmap.getImageDataArray()), [
        8, 8, 8, 8,   8, 8, 8, 8,   8, 8, 8, 8,
        8, 8, 8, 8,   4, 6, 8, 8,   8, 4, 4, 8,
        8, 8, 8, 8,   4, 6, 8, 8,   8, 4, 4, 8
      ]

    test "drawCheckers", ->
      bitmap = bitmapFactory.newBitmap point 16, 16
      drawCheckers bitmap, point(8), "gray", "white"
      drawCheckers bitmap, point(6, 2), "red", "black", rect 0, 0, 12, 4
      drawCheckers bitmap, point(2, 6), "orange", "black", rect 0, 4, 4, 12
      drawCheckers bitmap, point(6, 2), "yellow", "black", rect 4, 12, 12, 4
      drawCheckers bitmap, point(2, 6), "orange", "black", rect 12, 0, 4, 12
      # drawCheckers bitmap, point(8, 2), "red", "black", rect 0, 0, 16, 4
      # drawCheckers bitmap, point(8, 2), "red", "black", rect 0, 0, 16, 4
      log bitmap

    generateTestStretchBitmap = ->
      bitmap = bitmapFactory.newBitmap point 16, 16
      drawCheckers bitmap, point(8), "white", "grey"
      drawCheckers bitmap, point(6, 1), "red", "darkRed", rect 0, 0, 12, 2
      drawCheckers bitmap, point(1, 7), "darkOrange", "orange", rect 0, 2, 2, 14
      drawCheckers bitmap, point(7, 3), "yellow", "#770", rect 2, 10, 14, 6
      drawCheckers bitmap, point(2, 5), "#0f0", "#070", rect 12, 0, 4, 10
      # log bitmap
      bitmap

    testStretch = (name, drawMatrix, targetArea, options = {}) ->
      test name, ->
        src = generateTestStretchBitmap()
        dst = bitmapFactory.newBitmap point 64, 64
        dst.clear "#060"
        sourceArea = rect(2,2,10,8)
        dst.drawStretchedBorderBitmap drawMatrix, targetArea, src, sourceArea, options
        log name, src:src, dst:dst

    testStretch "drawStretchedBorderBitmap no stretching should look identical do drawBitmap",
      matrix(), rect 24, 24, 16, 16

    testStretch "drawStretchedBorderBitmap stretch middle by 2x",
      matrix(), rect 24, 24, 16 + 10, 16 + 8

    testStretch "drawStretchedBorderBitmap stretch middle by 1/2x",
      matrix(), rect 24, 24, 16-5, 16-4

    testStretch "drawStretchedBorderBitmap stretched so there is no middle",
      matrix(), rect 0, 0, 16 - 10, 16 - 8

    testStretch "drawStretchedBorderBitmap Matrix.translate 10",
      Matrix.translateXY(10, 10), rect 0, 0, 16, 16

    testStretch "drawStretchedBorderBitmap Matrix.scale 2",
      Matrix.scale(2), rect 0, 0, 16, 16

    testStretch "drawStretchedBorderBitmap Matrix.scale(2), stretch middl X by 2",
      Matrix.scale(2), rect 0, 0, 26, 16

    testStretch "drawStretchedBorderBitmap Matrix.scale(2).translate(10)",
      Matrix.scale(2).translate(10), rect 0, 0, 16, 16

    testStretch "drawStretchedBorderBitmap borderScale = 2",
      matrix(), rect(0, 0, 16 + 6, 16 + 8), borderScale: 2

    testStretch "drawStretchedBorderBitmap borderScale = 0 has no borders",
      matrix(), rect(0, 0, 10, 8), borderScale: 0

    testStretch "drawStretchedBorderBitmap borders too big",
      matrix(), rect(10, 10, 3, 4)

    test "load image", ->
      bitmap1 = bitmapFactory.newBitmap point 3
      bitmap1.clear "#777"

      EncodedImage.get "#{testAssetRoot}/array_buffer_image_test/sample.jpg"
      .then (image) ->
        bitmap2 = bitmapFactory.newBitmap image
        assert.eq bitmap2.size, point 256, 256
        bitmap1.drawBitmap null, bitmap2
        log bitmap1

        # this is the top-left 3x3 pixels of sample.jpg - a picture of carpet samples
        data = bitmap1.getImageDataArray()
        if eq(data, [72, 114, 156, 255, 69, 112, 152, 255, 73, 116, 150, 255, 52, 98, 142, 255, 36, 84, 126, 255, 31, 81, 119, 255, 28, 78, 126, 255, 17, 72, 117, 255, 40, 89, 128, 255])
          # MSIE = ok
        else if eq(data, [72, 115, 156, 255, 70, 113, 153, 255, 74, 117, 151, 255, 54, 100, 143, 255, 35, 85, 127, 255, 30, 82, 120, 255, 26, 79, 127, 255, 16, 73, 118, 255, 38, 90, 129, 255])
          # SAFARI = ok
        else
          assert.eq data, [74, 115, 154, 255, 72, 113, 151, 255, 75, 117, 149, 255, 56, 100, 141, 255, 38, 85, 125, 255, 34, 82, 118, 255, 30, 79, 125, 255, 21, 73, 116, 255, 42, 90, 127, 255]

    test "compositing target_alphmask is alphamask in the other order", ->
      a = bitmapFactory.newBitmap point 3
      b = bitmapFactory.newBitmap point 3
      for i in [0,1,2]
        a.drawRectangle point(0,i), point(3, 1), color:color 1, .5, 0, i*.5
        b.drawRectangle point(i,0), point(1, 3), color:color 1, .5, 0, i*.5

      temp = bitmapFactory.newBitmap b.size
      temp.clear "white"
      temp.drawBitmap point(), a
      log temp, text:'composite target'
      log b, text:'composite source'

      # assert.eq reducedRange(a.getImageDataArray()), [
      #   0, 0, 0, 0,   0, 0, 0, 0,   0, 0, 0, 0,
      #   8, 4, 0, 4,   8, 4, 0, 4,   8, 4, 0, 4,
      #   8, 4, 0, 8,   8, 4, 0, 8,   8, 4, 0, 8
      # ]

      bAlphamaskOnA = bitmapFactory.newBitmap b.size
      bAlphamaskOnA.drawBitmap point(), a
      bAlphamaskOnA.drawBitmap point(), b, compositeMode:"alphamask"

      temp = bitmapFactory.newBitmap b.size
      temp.clear "white"
      temp.drawBitmap point(), bAlphamaskOnA
      bAlphamaskOnA = temp

      aTargetAlphamaskOnB = bitmapFactory.newBitmap b.size
      aTargetAlphamaskOnB.drawBitmap point(), b
      aTargetAlphamaskOnB.drawBitmap point(), a, compositeMode:"target_alphamask"

      temp = bitmapFactory.newBitmap b.size
      temp.clear "white"
      temp.drawBitmap point(), aTargetAlphamaskOnB
      aTargetAlphamaskOnB = temp

      log bAlphamaskOnA, text:'bAlphamaskOnA'
      log aTargetAlphamaskOnB, text:'aTargetAlphamaskOnB'
      assert.eq bAlphamaskOnA.getImageDataArray(), aTargetAlphamaskOnB.getImageDataArray()


    test "ADD and NORMAL compositing associativity: (red + blue).over(grey) == red + blue + grey", ->
      if bitmapFactory != Neptune.Art.Webgl?.Bitmap
        log "compositing associativity is skipped for #{bitmapClassName} since only Webgl is capable of doing it correctly"
      else
        src = bitmapFactory.newBitmap point 3
        dst = bitmapFactory.newBitmap point 3
        dst.clear "#777"
        r = color 1, 0, 0, .5
        b = color 0, 0, 1, .5
        drawSteps = (target)->
          target.drawRectangle null, rect(0,0,2,1), color:r, compositeMode:"add"
          target.drawRectangle null, rect(1,0,2,1), color:b, compositeMode:"add"
          target.drawRectangle null, rect(0,1,2,1), color:r
          target.drawRectangle null, rect(1,1,2,1), color:b
        drawSteps src
        log src, text: "one-pass ADD & NORMAL compositing: src"
        log dst, text: "one-pass ADD & NORMAL compositing: dst"
        dst.drawBitmap null, src
        log dst, text: "one-pass ADD & NORMAL compositing: composited"

        control = bitmapFactory.newBitmap point 3
        control.clear "#777"
        drawSteps control
        log control, text: "one-pass ADD & NORMAL compositing: control"
        dataWithin control.getImageDataArray(), [246, 119, 119, 255, 246, 119, 246, 255, 119, 119, 246, 255, 187, 60, 60, 255, 94, 30, 157, 255, 60, 60, 187, 255, 119, 119, 119, 255, 119, 119, 119, 255, 119, 119, 119, 255], 1, "control isn't correct"
        dataWithin dst.getImageDataArray(), control.getImageDataArray(), 0, "dst != control"



    test "compositing modes", ->
      dest1 = generateCompositingTestBitmap color(0,0,0,0), "#f00", "#00f"
      # dest2 = generateCompositingTestBitmap color(0,0,0,0), color(1, 0, 0, 1), color(0,0,1,.75)
      # dest3 = generateCompositingTestBitmap color(0,0,0,0), color(1, 0, 0, .75), color(0,0,1,.75)

      logBitmap = bitmapFactory.newBitmap point dest1.size.x*2, dest1.size.y*2
      logBitmap.drawBitmap point(0,0), dest1
      # logBitmap.drawBitmap point(dest1.size.x,0), dest2
      # logBitmap.drawBitmap point(dest1.size.x*2,0), dest3
      log logBitmap, size: dest1.size, text: "#{bitmapClassName} compositeModes: #{compositeModes.join ', '}"
      dataWithin (i / 32 | 0 for i in dest1.getImageDataArray()), [
        7,0,0,7,  7,0,0,7,  0,0,0,0,
        7,0,0,7,  7,0,7,7,  0,0,7,7,
        0,0,0,0,  0,0,7,7,  0,0,7,7,

        7,0,0,7,  7,0,0,7,  0,0,0,0,
        7,0,0,7,  0,0,7,7,  0,0,7,7,
        0,0,0,0,  0,0,7,7,  0,0,7,7,

        0,0,0,0,  0,0,0,0,  0,0,0,0,
        0,0,0,0,  0,0,7,7,  0,0,0,0,
        0,0,0,0,  0,0,0,0,  0,0,0,0,

        0,0,0,0,  0,0,0,0,  0,0,0,0,
        0,0,0,0,  7,0,0,7,  0,0,0,0,
        0,0,0,0,  0,0,0,0,  0,0,0,0,

        7,0,0,7,  7,0,0,7,  0,0,0,0,
        7,0,0,7,  7,0,0,7,  0,0,7,7,
        0,0,0,0,  0,0,7,7,  0,0,7,7,

        7,0,0,7,  7,0,0,7,  0,0,0,0,
        7,0,0,7,  0,0,7,7,  0,0,0,0,
        0,0,0,0,  0,0,0,0,  0,0,0,0
      ],0
      # dataWithin dest2.getImageDataArray(), [255, 0, 0, 255, 255, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 255, 255, 0, 191, 255, 0, 0, 255, 191, 0, 0, 0, 0, 0, 0, 255, 191, 0, 0, 255, 191, 255, 0, 0, 255, 255, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 255, 64, 0, 191, 255, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 254, 191, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 254, 0, 0, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 255, 255, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 255, 255, 0, 0, 255, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 254, 191, 0, 0, 254, 191], 2
      # dataWithin dest3.getImageDataArray(), [254, 0, 0, 191, 254, 0, 0, 191, 0, 0, 0, 0, 254, 0, 0, 191, 191, 0, 191, 255, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 254, 191, 0, 0, 254, 191, 254, 0, 0, 191, 254, 0, 0, 191, 0, 0, 0, 0, 254, 0, 0, 191, 51, 0, 203, 239, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 254, 191, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 143, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 143, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 254, 0, 0, 191, 254, 0, 0, 191, 0, 0, 0, 0, 254, 0, 0, 191, 203, 0, 51, 239, 0, 0, 254, 191, 0, 0, 0, 0, 0, 0, 254, 191, 0, 0, 254, 191], 2


    test "toMemoryBitmap", ->
      bitmap = bitmapFactory.newBitmap point 2
      distractionBitmap = bitmapFactory.newBitmap point 2
      bitmap.clear "#123"
      distractionBitmap.clear "#456"  # make sure toMemoryBitmap gets the specified bitmap and not the last one touched
      memoryBitmap = bitmap.toMemoryBitmap()
      assert.eq memoryBitmap.size, bitmap.size
      assert.eq memoryBitmap.class, Bitmap

      assert.eq memoryBitmap.getImageDataArray(), [
        0x11, 0x22, 0x33, 0xff,     0x11, 0x22, 0x33, 0xff,
        0x11, 0x22, 0x33, 0xff,     0x11, 0x22, 0x33, 0xff,
      ]

    test "drawRectangle gradient", ->
      bitmap = bitmapFactory.newBitmap point 5,3
      bitmap.clear "#777"
      gfs = new GradientFillStyle point(0,0), point(5,0), ["#000", "#f00", "#000"]
      bitmap.drawRectangle null, bitmap.size, fillStyle:gfs
      log bitmap

      # parseInt(val/120) is used for an approximage comparison - webGL gradients aren't exactly the same (should they be?)
      data = (Math.round(val/120) for val in bitmap.getImageDataArray "red")
      assert.eq data, [
        0, 1, 2, 1, 0,
        0, 1, 2, 1, 0,
        0, 1, 2, 1, 0,
      ]

    test "drawRectangle gradient with transparency", ->
      bitmap = bitmapFactory.newBitmap point 5,1
      bitmap.clear "black"
      gfs = new GradientFillStyle point(.5,0), point(4.5,0), [color(0,0,0,.25), color(1,0,0,.5), color(1,1,1,.75)]
      bitmap.drawRectangle null, bitmap.size, fillStyle:gfs
      log bitmap

      # parseInt(val/120) is used for an approximage comparison - webGL gradients aren't exactly the same (should they be?)
      log bitmap.getImageDataArray("red")
      assert.within bitmap.getImageDataArray("red"),
        [0, 48, 118, 159, 186]
        [6, 48, 127, 159, 191]
      # I'm pretty certain the "48" is right. It should be color(.5, 0, 0, (.5 + .25)/2)
      # Then pre-multiply it to get 0.1875 for the r channel
      # 0.1875 * 255 == 47.8125
      # webGL is currently failing this test. Somehow its not correctly observing premultiplication.

    test "blur", ->
      bitmap = bitmapFactory.newBitmap point 4, 4
      bitmap.clear "#000"
      bitmap.drawRectangle point(1), point(2), color:"#fff"
      res = bitmap.blur 1
      assert.eq res, bitmap
      log bitmap

      referenceData = [
        16, 48,  48,  16,
        48, 143, 143, 48,
        48, 143, 143, 48,
        16, 48,  48,  16
      ]

      assert.eq referenceData, bitmap.getImageDataArray "red"
      assert.eq referenceData, bitmap.getImageDataArray "green"
      assert.eq referenceData, bitmap.getImageDataArray "blue"

    test "blurAlpha", ->
      bitmap = bitmapFactory.newBitmap point 4, 4
      bitmap.clear color(0,0,0,0)
      bitmap.drawRectangle point(1), point(2), color:"#fff"
      res = bitmap.blurAlpha 1
      assert.eq res, bitmap
      log bitmap

      referenceDataAlpha = [
        16, 48,  48,  16,
        48, 143, 143, 48,
        48, 143, 143, 48,
        16, 48,  48,  16
      ]
      referenceDataColor = [
        0,0,0,0
        0,255,255,0
        0,255,255,0
        0,0,0,0
      ]

      assert.eq referenceDataAlpha, bitmap.getImageDataArray "alpha"
      assert.eq referenceDataColor, bitmap.getImageDataArray "red"
      assert.eq referenceDataColor, bitmap.getImageDataArray "green"
      assert.eq referenceDataColor, bitmap.getImageDataArray "blue"

    test "blur with clone", ->
      bitmap = bitmapFactory.newBitmap point 4, 4
      bitmap.clear "#000"
      bitmap.drawRectangle point(1), point(2), color:"#fff"
      res = bitmap.blur 1, true
      assert.neq res, bitmap

  suite "Art.#{bitmapClassName}.common bitmap tests.encode", ->

    testToPng = (bitmap) ->
      bitmap.toPng()
      .then (binaryEncoding) ->
        binaryEncoding.toDataUri()
      .then (dataURI) ->
        Binary.EncodedImage.toImage dataURI
      .then (img) ->
        bitmap2 = bitmapFactory.newBitmap img
        log bitmap2
        assert.eq bitmap.getImageDataArray(), bitmap2.getImageDataArray()

    testToJpg = (bitmap) ->
      bitmap.toJpg 1
      .then (binaryEncoding) ->
        binaryEncoding.toDataUri()
      .then (dataURI) ->
        Binary.EncodedImage.toImage dataURI
      .then (img) ->
        bitmap2 = bitmapFactory.newBitmap img
        log bitmap2
        a=reducedRange bitmap.getImageDataArray()
        b=reducedRange bitmap2.getImageDataArray()
        assert.eq a, b

    test "toPng from HTMLImage element", ->
      Bitmap.get "https://upload.wikimedia.org/wikipedia/en/2/24/Lenna.png"
      .then (bitmap) ->
        testToPng bitmap

    test "toPng", ->
      bitmap = bitmapFactory.newBitmap point 16
      drawCheckers bitmap, point(4), "red", "white"

      log bitmap
      testToPng bitmap

    test "toJpg", ->
      bitmap = bitmapFactory.newBitmap point 4
      drawCheckers bitmap, point(2), "blue", "white"

      log bitmap
      testToJpg bitmap
