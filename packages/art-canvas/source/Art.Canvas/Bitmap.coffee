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
GradientFillStyle = require "./GradientFillStyle"
BitmapBase = require "./BitmapBase"
StackBlur = require "./StackBlur"
{roundedRectanglePath, rectanglePath, linePath} = require "./Paths"

isSimpleRectangle = (pathFunction, pathOptions) ->
  (pathFunction == rectanglePath || pathFunction == roundedRectanglePath) &&
  (!(radius = pathOptions?.radius)? || radius == 0)

{
  inspect, log, min, max, Binary, isFunction, isPlainObject, eq, currentSecond, round, isNumber, floatEq0
  Promise
  isPlainObject
  isString
  getEnv
} = require 'art-standard-lib'

{Binary, Browser} = require "art-foundation"
{EncodedImage} = Binary

{point, Point, rect, Rectangle, matrix, Matrix, rgbColor, Color, IdentityMatrix, point0} = Atomic

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

  @get: (url, options) ->
    EncodedImage.get url, options
    .then (image) ->
      bitmap = new Bitmap image
      if isString(url) && match = url.match /@([2-9])x\.[a-zA-Z]+$/
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
    Browser.File.request accept: "image/*"
    .then ([file]) =>
      EncodedImage.toImage file
      .then (image)  => new Bitmap image
      .then (bitmap) =>

        log ArtCanvasBitmap_requestImage:
          size:     bitmap.size
          tainted:  bitmap.tainted
          type:     file.type

        {bitmap, file, mimeType: file.type}

  initFromImage: (image) ->
    @_size = point image.naturalWidth || image.width, image.naturalHeight || image.height
    @_htmlImageElement = image
    if getEnv().debugTaint
      {tainted} = @
      message = "Canvas.Bitmap.initFromImage #{@_size}, tainted: #{tainted}, #{image.src?.slice(0,100)}"
      if tainted
        log.error message
      else log message

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

  ###
  IN:
    area is either:
      rectangle or point
      OR
      path-function
  ###

  setClippingArea: (area, drawMatrix, pathArea, pathOptions) ->
    {_context} = @
    if isFunction area
      pathFunction = area unless simple = isSimpleRectangle area, pathOptions
      area = pathArea

    if area
      @_setTransform drawMatrix
      transformedArea = @transformAndRoundOutRectangle drawMatrix, area
      area = @pixelSnapRectangle drawMatrix, area
      @_clippingArea = transformedArea.intersection @_clippingArea
    else
      @_setTransform drawMatrix

    _context.beginPath()
    if pathFunction
      pathFunction _context, area, pathOptions
    else
      _context.rect area.x, area.y, area.w, area.h
    _context.clip()


  # execs function "f" while clipping
  clippedTo: (area, f, drawMatrix, pathArea, pathOptions) ->
    @_context.save()
    previousClippingArea = @_clippingArea
    try
      @setClippingArea area, drawMatrix, pathArea, pathOptions
      f()
    finally
      @_context.restore()
      @_clippingArea = previousClippingArea

  # returns lastClippingInfo
  openClipping: (area, drawMatrix, pathArea, pathOptions) ->
    @_context.save()
    lastClippingInfo = @_clippingArea
    @setClippingArea area, drawMatrix, pathArea, pathOptions
    lastClippingInfo || rect @size

  closeClipping: (lastClippingInfo) ->
    @_context.restore()
    @_clippingArea = lastClippingInfo

  transparent = rgbColor "transparent"

  # set all pixels to exactly the specified color
  # signatures:
  #   () -> clr == "#0000"
  #   (a, b, c, d) -> clr == color a, b, c, d
  clear: (a, b, c, d) ->
    @clearArea null, if a? then rgbColor a, b, c, d else transparent
    @

  clearOutsideArea: (area, color) ->
    return unless area
    {left:x, top:y, w, h} = area
    throw new Error "area(#{area}) must start in the top-right corner" unless x == 0 && y == 0

    {w: currentWidth, h: currentHeight} = @size
    w = min w, currentWidth
    h = min h, currentHeight
    return if w == currentWidth && h == currentHeight

    if h == currentHeight
      @clearArea rect w, 0, currentWidth - w, currentHeight
    else if w == currentWidth
      @clearArea rect 0, h, currentWidth, currentHeight - h
    else
      @clearArea rect w, 0, currentWidth - w, currentHeight
      @clearArea rect 0, h, w, currentHeight - h

  clearArea: (area, color = transparent) ->

    if area
      {left:x, top:y, w, h} = area
    else
      x = y = 0
      {w, h} = @size

    @_clearTransform()

    # pre-clear all pixels to 0-0-0-0
    @_context.clearRect x, y, w, h unless color.a == 1.0

    # fill-all-pixels with the specified color
    unless color.eq transparent
      @_context.globalCompositeOperation = "source-over"
      @_setFillStyle color
      @_context.fillRect x, y, w, h


  #####################
  # STROKES
  #####################

  # if pixelSnap is true, and where anything but a matrix with shx or shy != 0
  #   then, the outer edge of the outline is snapped to the nearest pixel
  #     the upper-left corner is rounded
  #     the lower-right corner is floored
  strokeRectangle: (where, rectangle, options = emptyOptions) ->
    r = rect rectangle
    {radius} = options
    {_context} = @

    if @shouldPixelSnap where
      lineWidth = options.lineWidth || 1
      r = @pixelSnapRectangle where, r

      lineWidthMod2 = lineWidth % 2
      grow = if lineWidthMod2 < 1
        -lineWidthMod2/2
      else
        lineWidthMod2/2 - 1

      r = r.grow grow if !floatEq0 grow

    if @_setupDraw where, options, true
      if radius > 0 || isPlainObject radius
        _context.beginPath()
        roundedRectanglePath _context, r, radius
        _context.stroke()

      else
        _context.strokeRect r.x, r.y, r.w, r.h
      @_cleanupDraw options
    @

  strokeShape: (where, options, pathFunction, pathArea, pathOptions) ->
    {_context} = @
    if @_setupDraw where, options, true
      if isSimpleRectangle pathFunction, pathOptions
        if @shouldPixelSnap where
          pathArea = @pixelSnapRectangle where, pathArea
        {top, left, w, h} = pathArea
        _context.strokeRect left, top, w, h
      else
        _context.beginPath()
        pathFunction _context, pathArea, pathOptions
        _context.stroke()
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
      rectanglePath @_context, a

      @_context.stroke()
      @_cleanupDraw options
    @

  drawLine: (where, fromPoint, toPoint, options = emptyOptions) ->
    {_context} = @
    if @_setupDraw where, options, true
      _context.beginPath()
      linePath _context, fromPoint, toPoint
      _context.stroke()
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

      if radius > 0 || isPlainObject radius
        _context.beginPath()
        roundedRectanglePath _context, r, radius
        _context.fill fillRule || "nonzero"

      else
        _context.fillRect r.x, r.y, r.w, r.h

      @_cleanupDraw options
    @

  fillShape: (where, options, pathFunction, pathArea, pathOptions) ->
    {_context} = @
    if @_setupDraw where, options
      if isSimpleRectangle pathFunction, pathOptions
        if @shouldPixelSnap where
          pathArea = @pixelSnapRectangle where, pathArea

        {top, left, w, h} = pathArea
        _context.fillRect left, top, w, h
      else
        _context.beginPath()
        pathFunction _context, pathArea, pathOptions
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
      global.slowDraw = target: @, source: bitmap, where: where, options: options
      log Canvas_Bitmap_drawBitmap:
        message: "details: global.slowDraw"
        slowDraw: "#{(endTime - startTime) * 1000 | 0}ms"
        time2: "#{(endTime - aboutToDrawTime) * 1000 | 0}ms"
        where: where
        options: options
        drawed: drawed
        bitmapSize: [bitmap._size, bitmap.width, bitmap.height]

    @

  ###
  IN:
    options:
      fontFamily:
      fontSize:
      align:
      baseline:

      DEPRICATED:
        size:
        family:
  ###
  drawText:(where, text, options = emptyOptions) ->
    if @_setupDraw where, options
      @_context.font = "#{options.fontSize || options.size || 16}px #{options.fontFamily || options.family || 'Arial'}, Arial"
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

  _getFillStyleFromOptions: (options) ->
    if options.colors
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

  _setStrokeStyleFromOptions: (options) ->
    @_setStrokeStyle @_getFillStyleFromOptions options
    {lineWidth, lineCap, lineJoin, miterLimit, lineDash} = options
    @_context.setLineDash lineDash || []
    @_context.lineWidth  = lineWidth   || 1
    @_context.lineCap    = lineCap     || "butt"
    @_context.lineJoin   = lineJoin    || "miter"
    @_context.miterLimit = miterLimit  || 10

  _setFillStyleFromOptions: (options) ->
    @_setFillStyle @_getFillStyleFromOptions options


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
      _context.shadowColor = rgbColor shadowColor || "black"
      _context.shadowBlur = blur if blur
      offsetX ||= 0
      offsetY ||= 0
      if where instanceof Matrix
        ###
        Shadows seem to ignore scale and rotation transformations.

        It seems someone wanted to enforce consistent shadows while completely breaking
        the setTransform abstraction. Bah! :)

        I believe this was a design mistake. It introduces inconsistencies both subtle
        and large. For example, it makes shadow placement vary across devices depending
        upon their devicePixelsPerPoint. No other draw command works this way.

        Consistent shadows should be up to the programmer, not the drawing engine.

        I believe this hack solves the problem. Shadow SHAPE does obey setTransforms. It
        is also correctly proporitonal to the shape it is creating a shadow of. Said shape
        fully obeys setTrasform - including location. Only the vector from the center of
        the shape to the center of the shadow seems to ignore setTransform.
         - July 2016, SBD
        ###
        _context.shadowOffsetX = Matrix.transform1D offsetX, offsetY, where.sx, where.shx, 0
        _context.shadowOffsetY = Matrix.transform1D offsetY, offsetX, where.sy, where.shy, 0
      else
        _context.shadowOffsetX = offsetX
        _context.shadowOffsetY = offsetY

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
