# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
# http://diveintohtml5.info/canvas.html
# http://arcturo.github.io/library/coffeescript/
# http://jsfiddle.net/
# http://mudcu.be/journal/2011/04/globalcompositeoperation/
# Canvas Spec: http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html
# http://dev.w3.org/fxtf/compositing-1/#porterduffcompositingoperators_srcover

# Blurring with just Canvas2D
# this might help:
#   https://developer.mozilla.org/en-US/docs/HTML/Canvas/Drawing_DOM_objects_into_a_canvas
#    combined with css or svg blur filters:
#      http://caniuse.com/#search=blur
# Otherwise there are some "optimized" pure javascript solutions:
#   http://creativejs.com/2011/12/day-5-blur-that-canvas/
Atomic = require "art-atomic"
Foundation = require "art-foundation"
GradientFillStyle = require "./gradient_fill_style"
BitmapBase = require "./bitmap_base"
Paths = require "./paths"
StackBlur = require "./stack_blur"


{
  inspect, log, min, max, Binary, isFunction, isPlainObject, eq, currentSecond, round, isNumber, floatEq0
  Promise
} = Foundation
{EncodedImage} = Binary
{point, Point, rect, Rectangle, matrix, Matrix, color, Color, IdentityMatrix, point0} = Atomic

emptyOptions = {}

canvasBlenders =
  add: "lighter"
  normal: "source-over"

  # old, HTML-canvas compatible names
  target_alphamask: "source-in"
  alphamask: "destination-in"
  destover: "destination-over"
  sourcein: "source-atop"
  inverse_alphamask: "destination-out"

  # lowerCamelCase names
  alphaMask: "destination-in"
  targetAlphaMask: "source-in"
  inverseAlphaMask: "destination-out"
  destOver: "destination-over"
  sourceIn: "source-atop"
  replace: "copy"

module.exports = class Bitmap extends BitmapBase
  @supportedCompositeModes: (k for k, v of canvasBlenders)
  @getter supportedCompositeModes: -> Bitmap.supportedCompositeModes

  @artToCanvasCompositeModeMap: canvasBlenders

  initContext: ->
    @_context = @_canvas?.getContext "2d"

  @getter
    context: ->
      if !@_context && @_htmlImageElement
        # console.log "Canvas.Bitmap: getContext src/neptune/test/lib/art/webgl/- initFromImage(#{@size}) convert HTMLImageElement to canvas"
        @initNewCanvas @size
        @drawBitmap point(), @_htmlImageElement
        @_htmlImageElement = null

      @_context

    context2D:        -> @getContext()
    htmlImageElement: -> @_htmlImageElement
    htmlElement:      -> @_htmlImageElement || @_canvas

  @get: (url) ->
    EncodedImage.get url
    .then (image) ->
      bitmap = new Bitmap image
      if match = url.match /@([2-9])x\.[a-zA-Z]+$/
        [_, resolution] = match
        bitmap.pixelsPerPoint = resolution | 0
      bitmap

  ###
  Uses the browser's file-request dialog to have the user select a local image file.

  OUT:
    promise.then ({bitmap, file}) ->
      # bitmap is a Canvas.Bitmap
      # file is a javascript File object
  ###
  @requestImage: ->
    Foundation.Browser.File.request accept:"image/*"
    .then ([file]) =>
      EncodedImage.toImage file
      .then (image) =>
        bitmap: new Bitmap image
        file:   file

  initFromImage: (image) ->
    # log "Canvas.Bitmap: initFromImage - keep it an HTMLImageElement"
    @_size = point image.width, image.height
    @_htmlImageElement = image

  @setter
    imageSmoothing: (bool) ->
      @_context.imageSmoothingEnabled =
      @_context.mozImageSmoothingEnabled =
      @_context.webkitImageSmoothingEnabled =
      @_context.msImageSmoothingEnabled =
      @_imageSmoothing = !!bool

  ################
  # BITMAP FACTORY
  ################
  @bitmapClass: @
  @newBitmap: (size) => new @bitmapClass size
  newBitmap: (size) -> new @bitmapClass(size || @size).tap (b) => b.pixelsPerPoint = @pixelsPerPoint

  ################
  # CLIPPING
  ################

  setClippingArea: (area, drawMatrix) ->
    @_setTransform drawMatrix
    if isFunction area
      @_context.beginPath()
      area @_context
      @_context.clip()
    else
      area = @pixelSnapRectangle drawMatrix, area
      @_clippingArea = area.intersection @_clippingArea
      @_context.beginPath()
      @_context.rect area.x, area.y, area.w, area.h
      @_context.clip()

  # execs function "f" while clipping
  clippedTo: (area, f, drawMatrix) ->
    @_context.save()
    previousClippingArea = @_clippingArea
    try
      @setClippingArea area, drawMatrix
      f()
    finally
      @_context.restore()
      @_clippingArea = previousClippingArea

  # set all pixels to exactly the specified color
  # signatures:
  #   () -> clr == "#0000"
  #   (a, b, c, d) -> clr == color a, b, c, d
  clear: (a, b, c, d) ->
    clr = if a? then color a, b, c, d else color 0, 0, 0, 0

    @_clearTransform()

    # set all pixels to transparent black, erasing any previously drawn content
    @_context.clearRect 0, 0, @size.x, @size.y unless clr.a == 1.0

    # set all pixels to transparent black, erasing any previously drawn content
    unless clr.eq color 0, 0, 0, 0
      @_context.globalCompositeOperation = "source-over"
      @_setFillStyle clr
      @_context.fillRect 0, 0, @size.x, @size.y

    @

  #####################
  # STROKES
  #####################

  # if pixelSnap is true, and where anything but a matrix with shx or shy != 0
  #   then, the outer edge of the outline is snapped to the nearest pixel
  #     the upper-left corner is rounded
  #     the lower-right corner is floored
  strokeRectangle: (where, rectangle, options = emptyOptions) ->
    r = rect rectangle

    if @shouldPixelSnap where
      lineWidth = options.lineWidth || 1
      r = @pixelSnapRectangle where, r

      lineWidthMod2 = lineWidth % 2
      grow = if lineWidthMod2 < 1
        -lineWidthMod2/2
      else
        lineWidthMod2/2 - 1

      r = r.grow grow if !floatEq0 grow

    if options.radius
      @strokeShape where, options, =>
        Paths.roundedRectangle @_context, r, min options.radius, r.w/2, r.h/2
    else
      if @_setupDraw where, options, true
        @_context.strokeRect r.x, r.y, r.w, r.h
        @_cleanupDraw options
    @

  strokeShape: (where, options, pathFunction) ->
    if @_setupDraw where, options, true
      @_context.beginPath()
      pathFunction @_context
      @_context.stroke()
      @_cleanupDraw options
    @

  drawBorder: (where, rectangle, options) ->
    if @_setupDraw where, options, true
      p = options.padding || 0
      w = options.width || 1

      a1 = rect rectangle
      g = p - w/2
      a = a1.grow g

      @_context.beginPath()
      Paths.rectangle @_context, a

      @_context.stroke()
      @_cleanupDraw options
    @

  drawLine: (where, fromPoint, toPoint, options = emptyOptions) ->
    if @_setupDraw where, options, true
      @_context.beginPath()
      Paths.line @_context, fromPoint, toPoint
      @_context.stroke()
      @_cleanupDraw options
    @

  #####################
  # FILLS
  #####################
  drawRectangle: (where, rectangle, options = emptyOptions) ->
    r = rect rectangle
    {radius, fillRule} = options

    if @shouldPixelSnap where
      r = @pixelSnapRectangle where, r

    {_context} = @
    if @_setupDraw where, options

      if radius > 0
        _context.beginPath()
        Paths.roundedRectangle _context, r, radius
        _context.fill fillRule || "nonzero"

      else
        _context.fillRect r.x, r.y, r.w, r.h

      @_cleanupDraw options
    @

  fillShape: (where, options, pathFunction) ->
    if @_setupDraw where, options
      _context.beginPath()
      pathFunction _context
      _context.fill options.fillRule || "nonzero"
      @_cleanupDraw options
    @

  # "where" is where to draw the bitmap. It can be: Atomic.Point (upper left corner) or Atomic.Matrix
  # "bitmap" can be an Bitmap or anything a canvas context's drawImage accepts (an HTMLImageElement for example)
  drawBitmap: (where, bitmap, options = emptyOptions) ->

    startTime = currentSecond()
    sourceArea = options.sourceArea

    inputBitmap = bitmap
    bitmap = bitmap.toMemoryDrawableBitmap() if bitmap.toMemoryDrawableBitmap
    bitmap = bitmap._canvas || bitmap._htmlImageElement || bitmap
    inputBitmapSize = inputBitmap.size || point inputBitmap.width, inputBitmap.height

    drawed = ""

    if @shouldPixelSnap where
      {x, y, w, h} = @pixelSnapAndTransformRectangle where, sourceArea?.size || inputBitmapSize

      if sourceArea
        sx = round sourceArea.x
        sy = round sourceArea.y
        sw = round sourceArea.w
        sh = round sourceArea.h
      else
        sx = sy = 0
        sw = inputBitmapSize.x
        sh = inputBitmapSize.y

      if @_setupDraw null, options
        drawed = "pixelSnap - #{inspect [sx, sy, sw, sh]}"
        aboutToDrawTime = currentSecond()
        @_context.drawImage(
          bitmap
          sx, sy, sw, sh
          x,  y,  w,  h
        )
        @_cleanupDraw options
    else
      if @_setupDraw where, options
        aboutToDrawTime = currentSecond()
        if origSourceArea = sourceArea
          drawed = "sourceArea"
          {x, y, w, h} = sourceArea.intersection rect inputBitmap.size # chrome doesn't seem to need this, but FF does
          @_context.drawImage(
            bitmap,
            x, y, w, h
            0, 0, w, h
          )
        else
          drawed = "other"
          @_context.drawImage bitmap, 0, 0

        @_cleanupDraw options

    endTime = currentSecond()
    if endTime - startTime > .1
      log Canvas_Bitmap_drawBitmap:
        slowDraw: "#{(endTime - startTime) * 1000 | 0}ms"
        time2: "#{(endTime - aboutToDrawTime) * 1000 | 0}ms"
        where: where
        options: options
        drawed: drawed
        bitmapSize: [bitmap._size, bitmap.width, bitmap.height]

    @

  drawText:(where, text, options = emptyOptions) ->
    if @_setupDraw where, options
      @_context.font = "#{options.size || 16}px #{options.family || 'Arial'}, Arial"
      @_context.textAlign = options.align || 'start'
      @_context.textBaseline = options.baseline || 'alphabetic'
      @_context.fillText text, 0, 0
      @_cleanupDraw options
    @

  #####################
  # FILTERS
  #####################
  # if toClone is true, creates a new bitmap with the blurred data
  # TODO: toClone should accept "true" which generates a new clone, OR a bitmap, which is where the blurred output is drawn
  blur: (radius, toClone)->
    (if toClone then @clone() else @).tap (target) =>
      StackBlur.blur @, radius, target

  # if toClone is true, creates a new bitmap with the blurred data
  blurAlpha: (radius, options = emptyOptions)->
    (if options.clone then @clone() else @).tap (target) =>
      func = if options.inverted then "blurInvertedAlpha" else "blurAlpha"
      StackBlur[func] @, radius, target

  #####################
  # PRIVATE
  #####################

  _clearTransform: ->
    @_lastTransform = IdentityMatrix
    @_context.setTransform 1, 0, 0, 1, 0, 0

  _setTransform: (m) ->
    # TODO - I think this SHOULD work, but it doesn't...
    # return if eq m, @_lastTransform
    if m
      @_lastTransform = m
      if m instanceof Point
        @_context.setTransform 1, 0, 0, 1, m.x, m.y
      else
        @_context.setTransform m.sx, m.shy, m.shx, m.sy, m.tx, m.ty
    else
      @_clearTransform()

  _setStrokeStyle: (strokeStyle) ->
    @_context.strokeStyle = if strokeStyle.toCanvasStyle
      strokeStyle.toCanvasStyle @_context
    else
      strokeStyle.toString()

  _setFillStyle: (fillStyle) ->
    @_context.fillStyle = if fillStyle.toCanvasStyle
      fillStyle.toCanvasStyle @_context
    else
      fillStyle.toString()

  _setStrokeStyleFromOptions: (options) ->
    @_setStrokeStyle options.fillStyle || options.color || @defaultColorString
    {lineWidth, lineCap, lineJoin, miterLimit} = options
    @_context.lineWidth  = lineWidth   || 1
    @_context.lineCap    = lineCap     || "butt"
    @_context.lineJoin   = lineJoin    || "miter"
    @_context.miterLimit = miterLimit  || 10

  _setFillStyleFromOptions: (options) ->
    @_setFillStyle if options.colors
      fromPoint = options.from || point0
      gradientRadius1 = options.gradientRadius1 || options.gradientRadius
      toPoint = options.to || if gradientRadius1? then fromPoint else @size
      new GradientFillStyle(
        fromPoint
        toPoint
        options.colors
        gradientRadius1
        options.gradientRadius2
      )
    else
      options.fillStyle || options.color || @defaultColorString


  _setupDraw: (where, options, stroke) ->
    {compositeMode, shadow, opacity} = options
    stroke ||= options.stroke
    opacity = 1 unless isNumber opacity

    return false if opacity < 1/256
    {_context} = @

    if stroke
      @_setStrokeStyleFromOptions options
    else
      @_setFillStyleFromOptions options

    if compositeMode && compositeMode != "normal"
      _context.globalCompositeOperation = canvasBlenders[compositeMode] || canvasBlenders.normal

    if opacity < 1
      _context.globalAlpha = opacity

    if shadow
      {blur, offsetX, offsetY, offset} = shadow
      shadowColor = shadow.color
      _context.shadowColor = color shadowColor || "black"
      _context.shadowBlur = blur if blur
      _context.shadowOffsetX = offsetX if offsetX
      _context.shadowOffsetY = offsetY if offsetY

    @_setTransform where
    true

  _cleanupDraw: (options) ->
    {compositeMode, shadow, opacity} = options
    opacity = 1 unless isNumber opacity
    {_context} = @

    if compositeMode && compositeMode != "normal"
      _context.globalCompositeOperation = canvasBlenders.normal

    if opacity < 1
      _context.globalAlpha = 1

    if shadow
      _context.shadowColor = "transparent"
      _context.shadowBlur = 0
      _context.shadowOffsetX = 0
      _context.shadowOffsetY = 0
