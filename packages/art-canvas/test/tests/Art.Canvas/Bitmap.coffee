Atomic = require 'art-atomic'
Foundation = require 'art-foundation'
{Canvas} = Neptune.Art
CommonBitmapTests = require './CommonBitmapTests'
{each, w, Binary, log, eq, defineModule} = Foundation
{point, point0, point1, rect, rgbColor, matrix, Matrix} = Atomic
{Bitmap} = Canvas

array = (a) -> i for i in a

CommonBitmapTests Bitmap, "Canvas.Bitmap"

reducedRange = (data, factor = 32) ->
  Math.round a / factor for a in data

testAndLogBitmap = (testName, setup) ->
  test testName, ->
    {bitmap, test} = setup()
    log bitmap, testName
    test? bitmap

generateTestBitmap = ->
  result = new Bitmap point(5, 5)
  w = result.size.w
  imageData = result.getImageData()
  data = imageData.data
  for y in [0..4]
    for x in [0..4]
      data[((y * w) + x) * 4] = x * 255/4
      data[((y * w) + x) * 4 + 3] = y * 255/4
  result.putImageData imageData

  log result
  result

generateTestBitmap2 = (c = "#f00")->
  result = new Bitmap point(90, 90)
  result.clear()
  result.drawRectangle point(), point(60,60), color:c
  result

generateTestBitmap3 = (c = "#00f")->
  result = new Bitmap point(90, 90)
  result.clear()
  result.drawRectangle point(30,30), point(60,60), color:c
  result

defineModule module, suite:
  basic: ->
    test "allocate", ->
      bitmap = new Bitmap point(400, 300)
      assert.equal 400, bitmap.size.x

    test "getImageDataArray (all channels)", ->
      bitmap = new Bitmap point(2, 2)
      bitmap.clear rgbColor 1/255, 2/255, 3/255, 255/255
      data = bitmap.getImageDataArray()
      assert.eq data, [1, 2, 3, 255, 1, 2, 3, 255, 1, 2, 3, 255, 1, 2, 3, 255]

    test "getImageDataArray (red channel)", ->
      bitmap = new Bitmap point(2, 2)
      bitmap.clear rgbColor 1/255, 2/255, 3/255, 255/255
      data = bitmap.getImageDataArray("red")
      assert.eq data, [1, 1, 1, 1]

    test "clear", ->
      bitmap = new Bitmap point(2, 2)
      bitmap.drawRectangle null, rect(0, 0, 2, 2), color:"red"
      bitmap.clear()
      assert.eq bitmap.getImageDataArray(), [
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0
      ]

    test "clear '#f1f1f1'", ->
      bitmap = new Bitmap point(2, 2)
      bitmap.drawRectangle null, rect(0, 0, 2, 2), color:"red"
      bitmap.clear "#f1a52f"
      assert.eq bitmap.getImageDataArray(), [
        241, 165, 47, 255
        241, 165, 47, 255
        241, 165, 47, 255
        241, 165, 47, 255
      ]

    test "new", ->
      bitmap = new Bitmap point(2, 2)
      assert.eq bitmap.getImageDataArray(), [
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0
      ]

  stroke: ->

    test "drawLine", ->
      bitmap = new Bitmap point 3
      bitmap.drawLine null, point0, point(3), color: "black"
      log bitmap, "drawLine"
      assert.within (v * 8 / 255 | 0 for v in bitmap.getImageDataArray("alpha")), [
        6,1,0
        1,6,1
        0,1,6
      ], [
        8,0,0
        0,8,0
        0,0,8
      ]

    test "drawBorder", ->
      bitmap = new Bitmap point 3
      bitmap.drawBorder null, rect(0,0,3,3), color: "white"
      assert.within (v * 8 / 255 | 0 for v in bitmap.getImageDataArray("red")), [
        7,8,7
        8,0,8
        7,8,7
      ], [
        8,8,8
        8,0,8
        8,8,8
      ]

    test "strokeRectangle lineWidth:1", ->
      bitmap = new Bitmap point(6, 6)
      bitmap.clear "black"
      bitmap.pixelSnap = false
      bitmap.strokeRectangle null, rect(1, 1, 4, 4), color:"red", lineWidth:1, lineJoin:"miter"
      log bitmap
      data = reducedRange(bitmap.getImageDataArray("red"))
      unless eq(data, [
        0, 4, 4, 4, 4, 0,
        4, 8, 4, 4, 8, 4,
        4, 4, 0, 0, 4, 4,
        4, 4, 0, 0, 4, 4,
        4, 8, 4, 4, 8, 4,
        0, 4, 4, 4, 4, 0
      ])
        assert.eq data, [
          2, 4, 4, 4, 4, 2,
          4, 6, 4, 4, 6, 4,
          4, 4, 0, 0, 4, 4,
          4, 4, 0, 0, 4, 4,
          4, 6, 4, 4, 6, 4,
          2, 4, 4, 4, 4, 2
        ]


    renderStrokeRectangleWithSnap = (where, r, opts) ->
      m = matrix where
      r2 = m.transform r.br
      size = r2.add(point (opts.lineWidth/2 || 1)).ceil()
      log size:size
      bitmap = new Bitmap size
      bitmap.pixelSnap = true
      bitmap.clear "black"
      opts.color = "#f00"
      bitmap.strokeRectangle where, r, opts
      scale = 20
      b2 = new Bitmap bitmap.size.mul scale
      b2.imageSmoothing = false
      b2.drawBitmap Matrix.scale(scale), bitmap
      opts.color = "#0ff"
      opts.compositeMode = "add"
      b2.pixelSnap = false
      # b2.strokeRectangle m.scale(scale), r, opts
      log b2
      bitmap

    test "strokeRectangle pixelSnap=true lineWidth:1 ", ->
      bitmap = renderStrokeRectangleWithSnap null, rect(1, 1, 4, 4), color:"red", lineWidth:1
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        0, 0, 0, 0, 0, 0,
        0, 8, 8, 8, 8, 0,
        0, 8, 0, 0, 8, 0,
        0, 8, 0, 0, 8, 0,
        0, 8, 8, 8, 8, 0,
        0, 0, 0, 0, 0, 0
      ]

    test "strokeRectangle pixelSnap=true lineWidth:.5 ", ->
      bitmap = renderStrokeRectangleWithSnap null, rect(1, 1, 4, 4), color:"red", lineWidth:.5
      assert.within reducedRange(bitmap.getImageDataArray("red")), [
        0, 0, 0, 0, 0, 0,
        0, 6, 4, 4, 6, 0,
        0, 4, 0, 0, 4, 0,
        0, 4, 0, 0, 4, 0,
        0, 6, 4, 4, 6, 0,
        0, 0, 0, 0, 0, 0
      ], [
        0, 0, 0, 0, 0, 0,
        0, 8, 8, 8, 8, 0,
        0, 8, 0, 0, 8, 0,
        0, 8, 0, 0, 8, 0,
        0, 8, 8, 8, 8, 0,
        0, 0, 0, 0, 0, 0
      ]

    test "strokeRectangle pixelSnap=true lineWidth:1.5 ", ->
      bitmap = renderStrokeRectangleWithSnap null, rect(1, 1, 4, 4), color:"red", lineWidth:1.5
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        2, 4, 4, 4, 4, 2,
        4, 8, 8, 8, 8, 4,
        4, 8, 0, 0, 8, 4,
        4, 8, 0, 0, 8, 4,
        4, 8, 8, 8, 8, 4,
        2, 4, 4, 4, 4, 2
      ]

    test "strokeRectangle pixelSnap=true lineWidth:1, scale:1.5,1", ->
      bitmap = renderStrokeRectangleWithSnap log(Matrix.scaleXY(1.5, 1)), rect(.5, 1, 3, 4), color:"red", lineWidth:1, lineJoin:"miter"
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        0, 0, 0, 0, 0, 0,
        0, 8, 8, 8, 8, 0,
        0, 8, 4, 4, 8, 0,
        0, 8, 4, 4, 8, 0,
        0, 8, 8, 8, 8, 0,
        0, 0, 0, 0, 0, 0
      ]

    test "strokeRectangle pixelSnap=true lineWidth:2", ->
      bitmap = renderStrokeRectangleWithSnap null, rect(1, 1, 4, 4), color:"red", lineWidth:2, lineJoin:"miter"
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        8, 8, 8, 8, 8, 8
        8, 8, 8, 8, 8, 8
        8, 8, 0, 0, 8, 8
        8, 8, 0, 0, 8, 8
        8, 8, 8, 8, 8, 8
        8, 8, 8, 8, 8, 8
      ]

    test "strokeRectangle pixelSnap=true lineWidth:3", ->
      bitmap = renderStrokeRectangleWithSnap null, rect(2, 2, 5, 5), color:"red", lineWidth:3, lineJoin:"miter"
      assert.eq reducedRange(bitmap.getImageDataArray("red")), [
        0, 0, 0, 0, 0, 0, 0, 0, 0
        0, 8, 8, 8, 8, 8, 8, 8, 0
        0, 8, 8, 8, 8, 8, 8, 8, 0
        0, 8, 8, 8, 8, 8, 8, 8, 0
        0, 8, 8, 8, 0, 8, 8, 8, 0
        0, 8, 8, 8, 8, 8, 8, 8, 0
        0, 8, 8, 8, 8, 8, 8, 8, 0
        0, 8, 8, 8, 8, 8, 8, 8, 0
        0, 0, 0, 0, 0, 0, 0, 0, 0

      ]


  fill: ->
    test "compositing", ->
      a = generateTestBitmap2 "#f00"
      log a
      b = generateTestBitmap3 "#00f"
      log b
      modes = [
        'source-over','source-in','source-out','source-atop',
        'destination-over','destination-in','destination-out','destination-atop',
        'lighter','darker','copy','xor'
        'normal', 'multiply', 'screen', 'overlay',
        'darken', 'lighten', 'color-dodge', 'color-burn',
        'hard-light', 'soft-light', 'difference', 'exclusion'
        'hue', 'saturation', 'color', 'luminocity'
      ]
      s = b.size
      step = s.add 10
      dest = new Bitmap step.mul point(4,(modes.length+3)/4)

      for m, mi in modes
        p = point(mi % 4, mi / 4).floor().mul step
        temp = new Bitmap b.size
        temp.drawBitmap point(), a
        temp.drawBitmap point(), b, m
        dest.drawBitmap p, temp
        # dest.drawBitmap p, a
        # dest.drawBitmap p, b, "source-atop"
      log dest

    test "drawRectangle", ->
      bitmap = new Bitmap point(4, 4)
      bitmap.drawRectangle null, rect(1, 1, 2, 2), color:"red"
      b2 = new Bitmap point(4, 4)
      b2.clear "#000"
      log bitmap
      log b2
      b2.drawBitmap point(), bitmap
      log b2
      assert.eq bitmap.getImageDataArray("red"), [
        0,   0,   0, 0,
        0, 255, 255, 0,
        0, 255, 255, 0,
        0,   0,   0, 0
      ]

      bitmap.drawRectangle null, rect(2, 2, 2, 2), color:"#700"
      assert.eq bitmap.getImageDataArray("red"), [
        0,   0,   0,   0,
        0, 255, 255,   0,
        0, 255, 119, 119,
        0,   0, 119, 119
      ]

    test "drawRectangle radius:20", ->
      bitmap = new Bitmap point 100, 100
      bitmap.clear "#ddd"
      bitmap.drawRectangle point(10, 10), point(80, 80), color:"red", radius:20
      log bitmap

  toImage: ->
    test "pixelsPerPoint=2", ->
      bitmap = new Bitmap point 100, 80
      bitmap.clear "orange"
      bitmap.pixelsPerPoint = 2
      log bitmap:bitmap
      bitmap.toImage()
      .then (img) ->
        log img:img
        assert.eq img.width, 50
        assert.eq img.height, 40

    test "basic", ->
      bitmap = new Bitmap point 100, 80
      bitmap.clear "orange"
      log bitmap:bitmap
      bitmap.toImage()
      .then (img) ->
        log img:img
        assert.eq img.width, 100
        assert.eq img.height, 80

  getAutoCropRectangle: ->
    bitmapSize = point 10
    test "blank image", ->
      assert.eq rect(), new Bitmap(10).getAutoCropRectangle()

    test "full image", ->
      assert.eq rect(bitmapSize), new Bitmap(bitmapSize).clear("black").getAutoCropRectangle()

    testAndLogBitmap "rectangle in the middle", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(1, 2, 3, 4), color: "black"
      test: (bitmap) -> assert.eq r, bitmap.getAutoCropRectangle()

    testAndLogBitmap "rectangle at left", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(0, 2, 3, 4), color: "black"
      test: (bitmap) -> assert.eq r, bitmap.getAutoCropRectangle()

    testAndLogBitmap "rectangle at right", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(7, 2, 3, 4), color: "black"
      test: (bitmap) -> assert.eq r, bitmap.getAutoCropRectangle()

    testAndLogBitmap "rectangle at top", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(1, 0, 3, 4), color: "black"
      test: (bitmap) -> assert.eq r, bitmap.getAutoCropRectangle()

    testAndLogBitmap "rectangle at bottom", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(1, 6, 3, 4), color: "black"
      test: (bitmap) -> assert.eq r, bitmap.getAutoCropRectangle()

    testAndLogBitmap "two rectangles", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle(null, r = rect(1, 2, 3, 4), color: "red").drawRectangle(null, r = rect(5, 6, 7, 8), color: "blue")
      test: (bitmap) -> assert.eq rect(1, 2, 9, 8), bitmap.getAutoCropRectangle()

    testAndLogBitmap "threshold test 1", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(1, 2, 3, 4), color: "#0001"
      test: (bitmap) -> assert.eq r, bitmap.getAutoCropRectangle()

    testAndLogBitmap "threshold test 2", ->
      bitmap: new Bitmap(bitmapSize).drawRectangle null, r = rect(1, 2, 3, 4), color: rgbColor 0, 0, 0, .1
      test: (bitmap) -> assert.eq rect(), bitmap.getAutoCropRectangle(128)

  "new transformed bitmaps": ->
    newTestBitmap = ->
      b = new Bitmap point 128, 64
      b.drawRectangle null, b.size, colors: {0:"orange", 0.45:"orange", 0.55:"yellow", 1:"yellow"}, to: b.size
      b
    properties = w "
      mipmap
      flipped
      rotated180
      flippedAndRotated180
      rotated180AndFlipped
      rotated90Clockwise
      rotated90ClockwiseAndFlipped
      flippedAndRotated90CounterClockwise
      rotated90CounterClockwise
      rotated90CounterClockwiseAndFlipped
      flippedAndRotated90Clockwise
      "
    each properties, (property) ->
      test property, -> log "#{property}": newTestBitmap()[property]

    test "scale", -> log "scale": newTestBitmap().scale 2
    test "resize", -> log "resize": newTestBitmap().resize 64
