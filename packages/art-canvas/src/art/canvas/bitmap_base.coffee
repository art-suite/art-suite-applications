# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
# http://diveintohtml5.info/canvas.html
# http://arcturo.github.io/library/coffeescript/
# http://jsfiddle.net/
# http://mudcu.be/journal/2011/04/globalcompositeoperation/
# Canvas Spec: http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html
# http://dev.w3.org/fxtf/compositing-1/#porterduffcompositingoperators_srcover
Foundation = require 'art-foundation'
Atomic = require 'art-atomic'

{point, point0, Point, rect, Rectangle, matrix, Matrix, rgbColor, Color} = Atomic
{inspect, nextTick, BaseObject, Binary, pureMerge, isString, isNumber, log, bound, merge} = Foundation
{round, floor, ceil, max, min} = Math
{BinaryString} = Binary

toChannelNumberMap = 0:0, 1:1, 2:2, 3:3, r:0, g:1, b:2, a:3, red:0, green:1, blue:2, alpha:3
alphaChannelOffset = 3
pixelStep = 4

quarterPoint = point 1/4
halfPoint = point 1/2

module.exports = class BitmapBase extends BaseObject
  @bitmapsCreated: 0
  compositeModeSupported: (mode) -> @supportedCompositeModes.indexOf(mode) >= 0
  @pixelSnapDefault = true

  defaultColor: rgbColor "black"
  defaultColorString: "black"

  constructor: (a, b) ->
    super
    @_htmlImageElement = null
    @_canvas = null
    @_clippingArea = null
    @_context = null
    @_size = null
    @_lastTransform = null
    @_imageSmoothing = false

    @pixelSnap = BitmapBase.pixelSnapDefault
    @_pixelsPerPoint = 1

    BitmapBase.bitmapsCreated++
    a = point a, b if b
    if      a instanceof BitmapBase         then @populateClone @
    else if a instanceof HTMLCanvasElement  then @initFromCanvas a
    else if a instanceof HTMLImageElement   then @initFromImage a
    else                                         @initNewCanvas point a, b

  @getter
    hasAlpha: ->
      {size} = @
      if size.x <= 128 && size.y <= 128
        {data} = @imageData
        for v, i in data by 4
          if data[i + 3] < 255
            return true
        false
      else
        @resize(128).hasAlpha

    inspectedObjects: -> @
    canvas: ->
      unless @_canvas
        if @_htmlImageElement
          @initNewCanvas @size
          @drawBitmap null, @_htmlImageElement
        else
          throw new Error "can't get @canvas"
      @_canvas
    bitmapClass: -> @class # part of the bitmapFactory api
    clippingArea: -> @_clippingArea ||= rect @getSize()
    aspectRatio: -> @getSize().getAspectRatio()

  shouldPixelSnap: (where) ->
    @pixelSnap && (
      (!where) ||
      (where instanceof Point) ||
      where.isTranslateAndPositiveScaleOnly
      # NOTE: we could switch back to just isTranslateAndScaleOnly, but then we would need a draw matrix
      # for negative scales
    )

  pixelSnapWhere: (where) ->
    if where instanceof Point
      where.rounded
    else if where
      where.withRoundedTranslation

  pixelSnapRectangle: (where, r) ->
    right  = (x = r.x) + (w = r.w)
    bottom = (y = r.y) + (h = r.h)

    isx = isy = sx = sy = 1
    tx = ty = 0

    if where instanceof Point
      tx = where.x
      ty = where.y
    else if where
      tx = where.tx
      ty = where.ty
      sx = where.sx; isx = 1/sx
      sy = where.sy; isy = 1/sy

    x = (Math.round( (x  * sx) + tx) - tx) * isx
    y = (Math.round( (y  * sy) + ty) - ty) * isy
    w = (Math.round( (right  * sx) + tx) - tx) * isx - x
    h = (Math.round( (bottom * sy) + ty) - ty) * isy - y
    rect x, y, w, h

  pixelSnapAndTransformRectangle: (where, r) ->
    console.error "no r" unless r
    {left, right, top, bottom} = r
    if where instanceof Point
      left += where.x
      right += where.x
      top += where.y
      bottom += where.y
    else if where
      left   = where.transformX left, top
      top    = where.transformY left, top
      right  = where.transformX right, bottom
      bottom = where.transformY right, bottom

    left   = Math.round left
    top    = Math.round top
    right  = Math.round right
    bottom = Math.round bottom

    rect(
      left
      top
      right - left
      bottom - top
    )

  clone: ->
    b = @newBitmap @size
    b.drawBitmap null, @
    b

  crop: (area) ->
    area ||= @getAutoCropRectangle()
    area = rect(area).intersection rect(@size)
    @newBitmap area.size
    .drawBitmap Matrix.translateXY(-area.x, -area.y), @

  initFromCanvas: (canvas) ->
    @_canvas = canvas
    @_size = point @_canvas.width, @_canvas.height
    @initContext()

  initFromImage: (image) ->
    # in chrome, HTMLImageElements are much faster to draw FROM than CanvasElements
    # we should support "optimized" Art.Bitmaps (which can't be drawn to because they are HTMLImageElements)
    # console.log "BitmapBase: initFromImage #{image.width}, #{image.height}"
    @_size = point image.width, image.height
    @initNewCanvas @size
    @drawBitmap point(), image

  initNewCanvas: (size) ->
    return if @_context
    throw new Error "invalid size=#{size} for Art.Canvas.Bitmap" unless size.gt point()
    @_size = size.floor()
    if global.document
      @_canvas = document.createElement 'canvas'
      @_canvas.width = @size.x
      @_canvas.height = @size.y
    else
      # HTMLCanvasElement = require 'canvas'
      @_canvas = new HTMLCanvasElement @size.x, @size.y
    @initContext()

  populateClone: (result)->
    result.initNewCanvas @size
    result.drawBitmap null, @
    result._pixelsPerPoint = @_pixelsPerPoint

  ################################
  # Resolution
  ################################

  # pixelsPerPoint is NOT used internally by BitmapBase or its descendents
  # The intention is being able to tag the intended resoluion of the bitmap so clients can make layout decisions.
  @getter
    pixelsPerPoint: -> @_pixelsPerPoint
    pointsPerPixel: -> 1 / @_pixelsPerPoint
    pointSize: -> @size.div @pixelsPerPoint
    byteSize: -> @size.area * @getBytesPerPixel()
    bytesPerPixel: -> 4

  @setter
    pixelsPerPoint: (v) -> @_pixelsPerPoint = v
    pointsPerPixel: (v) -> @_pixelsPerPoint = 1 / v

  ################################
  # Standard Properties
  ################################
  @property size: point(100,100)
  @property imageSmoothing: false

  ################################
  # Image Data
  ################################
  toMemoryBitmap: -> @
  toMemoryDrawableBitmap: -> @
  @getter
    imageData: (a, b, c, d) ->
      area = if a==null || a==undefined then rect @size else rect a, b, c, d
      @toMemoryBitmap().context.getImageData area.x, area.y, area.w, area.h

    imageDataBuffer: (a, b, c, d) -> @getImageData(a, b, c, d).data.buffer

  putImageData: (imageData, location = point(), sourceArea = rect @size) ->
    location = location.sub sourceArea.location

    @_context.putImageData imageData, location.x, location.y,
      sourceArea.x, sourceArea.y, sourceArea.w, sourceArea.h

    @

  getImageDataArray: (channel=null) ->
    data = @getImageData().data
    if (channel = toChannelNumberMap[channel])?
      i = channel
      end = data.length
      while i < end
        i += 4
        data[i-4]
    else
      v for v in data # convert to array

  toPngUri: ->
    nextTick()
    .then => # use nextTick to ensure all pending draw commands complete before we extract the pixel data
      @toMemoryBitmap().canvas.toDataURL()

  toJpgUri: (quality=.95) ->
    nextTick()
    .then => # use nextTick to ensure all pending draw commands complete before we extract the pixel data
      @toMemoryBitmap().canvas.toDataURL "image/jpeg", quality

  # OUT: results in BinaryString
  toPng: ->
    @toPngUri()
    .then (dataURI) ->
      BinaryString.fromDataUri dataURI

  # OUT: results in BinaryString
  toJpg: (quality) ->
    @toJpgUri quality
    .then (dataURI) ->
      BinaryString.fromDataUri dataURI

  ###
  automatically incode to jpg or png
  png: only if hasAlpha is true
  jpg: all other times
  OUT:
    mimeType:   what mime-type was used
    extension:  what extension was used
    data: binaryString in either PNG or JPG format
  ###
  autoEncode: (quality) ->
    encodePromise = if @hasAlpha
      extension = "png"
      @toPng()
    else
      extension = "jpeg"
      @toJpg quality

    encodePromise.then (data) ->
      {extension, data, mimeType: "image/#{extension}"}

  toImage: ->
    nextTick()
    .then => # use nextTick to ensure all pending draw commands complete before we extract the pixel data
      if @_htmlImageElement
        @_htmlImageElement
      else
        url = @toMemoryBitmap().canvas.toDataURL()
        Binary.EncodedImage.toImage url
        .then (image) =>
          {w, h} = @pointSize
          image.width  = w
          image.height = h
          image

  ################################
  # new bitmap macros
  ################################
  hFlipped: ->
    result = @newBitmap @size
    result.drawBitmap Matrix.translateXY(-@size.x/2,0).scaleXY(-1,1).translateXY(@size.x/2,0), @
    result

  vFlipped: ->
    result = @newBitmap @size
    result.drawBitmap Matrix.translateXY(0,-@size.y/2).scaleXY(1,-1).translateXY(0,@size.y/2), @
    result

  @getter
    flipped: ->
      @newBitmap @size
      .drawBitmap Matrix.scaleXY(-1,1).translateXY(@size.x,0), @

    rotated180: ->
      @newBitmap @size
      .drawBitmap Matrix.rotate(Math.PI).translate(@size), @

    flippedAndRotated180: ->
      @newBitmap @size
      .drawBitmap Matrix.scaleXY(-1,1).rotate(Math.PI).translateXY(0, @size.y), @

    rotated90Clockwise: ->
      @newBitmap @size.swapped
      .drawBitmap Matrix.rotate(Math.PI/2).translateXY(@size.y, 0), @

    flippedAndRotated90Clockwise: ->
      @newBitmap @size.swapped
      .drawBitmap Matrix.scaleXY(-1,1).rotate(Math.PI/2).translateXY(@size.y, @size.x), @

    rotated90CounterClockwise: ->
      @newBitmap @size.swapped
      .drawBitmap Matrix.rotate(-Math.PI/2).translateXY(0, @size.x), @

    flippedAndRotated90CounterClockwise: ->
      @newBitmap @size.swapped
      .drawBitmap Matrix.scaleXY(-1,1).rotate(-Math.PI/2), @

    rotated180AndFlipped: -> @flippedAndRotated180
    rotated90ClockwiseAndFlipped: -> @flippedAndRotated90CounterClockwise
    rotated90CounterClockwiseAndFlipped: -> @flippedAndRotated90Clockwise

    # IN: targetMinSize: number or point
    # If targetMinSize is set, then mipmap is called recursively
    #   and the last mipmap which is >= targetMinSize is returned.
    # else mipmap is computed once, returning a bitmap which is 1/2 the width and height of this one (round up)
    mipmap: (targetMinSize)->
      return @ if targetMinSize && !@size.mul(halfPoint).ceil().gte targetMinSize = point targetMinSize

      result = @scale halfPoint

      if targetMinSize
        result.getMipmap targetMinSize
      else
        result

  # IN: newSize can anything "point" accepts
  resize: (newSize) -> @scale point(newSize).div @size

  # IN: scale can anything "point" accepts
  scale: (scale, highQuality = true) ->
    newSize = @size.mul(scale = point scale).ceil()
    source = @

    if highQuality
      while scale.lte quarterPoint
        scale = scale.mul 2
        source = source.mipmap

    return source if newSize.eq source.size
    newBitmap = @newBitmap newSize
    newBitmap.drawBitmap Matrix.scale(newBitmap.size.div source.size), source

  ################################
  # Draw Macros
  ################################
  drawBorder: (where, r, options) ->
    m = matrix where
    r = rect r
    c = options.color || "#777"
    w = options.width || 1
    p = options.padding || 0

    r = r.grow p

    @drawRectangle m, rect(r.x,          r.y,          r.w, w         ), c #top
    @drawRectangle m, rect(r.x,          r.bottom - w, r.w, w         ), c #bottom
    @drawRectangle m, rect(r.x,          r.y + w,      w, r.h - w * 2 ), c # left
    @drawRectangle m, rect(r.right - w,  r.y + w,      w, r.h - w * 2 ), c # right

  # splits the bitmap into 9 sections based on innerArea
  # targetArea can be Point or Rect
  # options:
  #   all drawBitmap options (opacity, compositeMode)
  #   broderScale: number (future: support Point, or even 4-valued)
  drawStretchedBorderBitmap: (drawMatrix, targetArea, bitmap, sourceCenterArea, options={}) ->
    {hide, show} = options
    bitmapSize = bitmap.size

    borderScale = options.borderScale
    borderScale = 1 unless isNumber borderScale

    sourceCenterAreaLeft    = sourceCenterArea.left
    sourceCenterAreaTop     = sourceCenterArea.top
    sourceCenterAreaRight   = sourceCenterArea.right
    sourceCenterAreaBottom  = sourceCenterArea.bottom
    sourceCenterAreaWidth   = sourceCenterAreaRight - sourceCenterAreaLeft
    sourceCenterAreaHeight  = sourceCenterAreaBottom - sourceCenterAreaTop

    targetAreaLeft          = round drawMatrix.transformX    targetArea.left, 0
    targetAreaTop           = round drawMatrix.transformY 0, targetArea.top
    targetAreaRight         = round drawMatrix.transformX    targetArea.right, 0
    targetAreaBottom        = round drawMatrix.transformY 0, targetArea.bottom
    targetAreaWidth         = targetAreaRight - targetAreaLeft
    targetAreaHeight        = targetAreaBottom - targetAreaTop

    sourceLeftWidth         = sourceCenterAreaLeft
    sourceTopHeight         = sourceCenterAreaTop
    sourceRightWidth        = bitmapSize.w - sourceCenterAreaRight
    sourceBottomHeight      = bitmapSize.h - sourceCenterAreaBottom

    targetCenterAreaLeft    = round drawMatrix.transformX    targetArea.left   + sourceLeftWidth * borderScale, 0
    targetCenterAreaTop     = round drawMatrix.transformY 0, targetArea.top    + sourceTopHeight * borderScale
    targetCenterAreaRight   = round drawMatrix.transformX    targetArea.right  - sourceRightWidth * borderScale, 0
    targetCenterAreaBottom  = round drawMatrix.transformY 0, targetArea.bottom - sourceBottomHeight * borderScale
    targetCenterAreaWidth   = targetCenterAreaRight  - targetCenterAreaLeft
    targetCenterAreaHeight  = targetCenterAreaBottom - targetCenterAreaTop

    # horizontal borders too big
    if targetCenterAreaWidth < 0
      horizontalBorderWidth = targetAreaWidth - targetCenterAreaWidth
      borderReductionRatio = targetAreaWidth / horizontalBorderWidth
      borderRatio = sourceLeftWidth / totalBorderWidth = sourceLeftWidth + sourceRightWidth
      sourceLeftWidth = round sourceLeftWidth * borderReductionRatio
      sourceRightWidth = round sourceRightWidth * borderReductionRatio
      sourceCenterAreaRight = bitmap.size.x - sourceRightWidth
      targetCenterAreaLeft = targetCenterAreaRight = targetAreaLeft + round targetAreaWidth * borderRatio
      targetCenterAreaWidth = 0

    # vertical borders too big
    if targetCenterAreaHeight < 0
      horizontalBorderHeight = targetAreaHeight - targetCenterAreaHeight
      borderReductionRatio = targetAreaHeight / horizontalBorderHeight
      borderRatio = sourceTopHeight / totalBorderHeight = sourceTopHeight + sourceBottomHeight
      sourceTopHeight = round sourceTopHeight * borderReductionRatio
      sourceBottomHeight = round sourceBottomHeight * borderReductionRatio
      sourceCenterAreaBottom = bitmap.size.x - sourceBottomHeight
      targetCenterAreaTop = targetCenterAreaBottom = targetAreaTop + round targetAreaHeight * borderRatio
      targetCenterAreaHeight = 0

    targetLeftWidth         = targetCenterAreaLeft - targetAreaLeft
    targetTopHeight         = targetCenterAreaTop  - targetAreaTop
    targetRightWidth        = targetAreaRight      - targetCenterAreaRight
    targetBottomHeight      = targetAreaBottom     - targetCenterAreaBottom

    # if targetAreaWidth < horizontalBorderWidth = sourceLeftWidth + sourceRightWidth
    #   sourceLeftWidth = floor targetAreaWidth * sourceLeftWidth / horizontalBorderWidth
    #   sourceRightWidth = targetAreaWidth - sourceLeftWidth
    #   targetAreaWidth = 0

    # # vertical borders too big
    # if targetAreaHeight < verticalBorderHeight = sourceTopHeight + sourceBottomHeight
    #   sourceTopHeight = floor targetAreaHeight * sourceTopHeight / verticalBorderHeight
    #   sourceBottomHeight = targetAreaHeight - sourceTopHeight
      # targetAreaHeight = 0


    sourceLeftScale         = targetLeftWidth    / sourceLeftWidth
    sourceTopScale          = targetTopHeight    / sourceTopHeight
    sourceRightScale        = targetRightWidth   / sourceRightWidth
    sourceBottomScale       = targetBottomHeight / sourceBottomHeight
    sourceCenterWidthScale  = targetCenterAreaWidth  / sourceCenterAreaWidth
    sourceCenterHeightScale = targetCenterAreaHeight / sourceCenterAreaHeight

    # @log
    #   drawMatrix:drawMatrix
    #   targetArea:targetArea
    #   sourceCenterArea:sourceCenterArea
    #   sourceBitmapSize: bitmap.size
    #   sourceBitmap: bitmap
    #   borderScale: borderScale
    #   sourceCenterAreaLeft  : sourceCenterAreaLeft
    #   sourceCenterAreaTop   : sourceCenterAreaTop
    #   sourceCenterAreaRight : sourceCenterAreaRight
    #   sourceCenterAreaBottom: sourceCenterAreaBottom
    #   sourceCenterAreaWidth : sourceCenterAreaWidth
    #   sourceCenterAreaHeight: sourceCenterAreaHeight
    #   targetAreaLeft        : targetAreaLeft
    #   targetAreaTop         : targetAreaTop
    #   targetAreaRight       : targetAreaRight
    #   targetAreaBottom      : targetAreaBottom
    #   targetAreaWidth       : targetAreaWidth
    #   targetAreaHeight      : targetAreaHeight
    #   targetCenterAreaLeft  : targetCenterAreaLeft
    #   targetCenterAreaTop   : targetCenterAreaTop
    #   targetCenterAreaRight : targetCenterAreaRight
    #   targetCenterAreaBottom: targetCenterAreaBottom
    #   targetCenterAreaWidth : targetCenterAreaWidth
    #   targetCenterAreaHeight: targetCenterAreaHeight
    #   sourceLeftWidth       : sourceLeftWidth
    #   sourceTopHeight       : sourceTopHeight
    #   sourceRightWidth      : sourceRightWidth
    #   sourceBottomHeight    : sourceBottomHeight
    #   targetLeftWidth       : targetLeftWidth
    #   targetTopHeight       : targetTopHeight
    #   targetRightWidth      : targetRightWidth
    #   targetBottomHeight    : targetBottomHeight
    #   sourceLeftScale       : sourceLeftScale
    #   sourceTopScale        : sourceTopScale
    #   sourceRightScale      : sourceRightScale
    #   sourceBottomScale     : sourceBottomScale
    #   sourceCenterWidthScale: sourceCenterWidthScale
    #   sourceCenterHeightScale: sourceCenterHeightScale


    if show
      topLeft      = !show.topLeft
      topRight     = !show.topRight
      topCenter    = !show.topCenter

      centerLeft   = !show.centerLeft
      centerRight  = !show.centerRight
      centerCenter = !show.centerCenter

      bottomLeft   = !show.bottomLeft
      bottomRight  = !show.bottomRight
      bottomCenter = !show.bottomCenter

    if hide
      {
        topLeft, topCenter, topRight
        centerLeft, centerCenter, centerRight
        bottomLeft, botomCenter, bottomRight
      } = hide

      topLeft = topCenter = topRight = true if hide.top
      bottomLeft = bottomCenter = bottomRight = true if hide.bottom
      topLeft = centerLeft = bottomLeft = true if hide.left
      topRight = centerRight = bottomRight = true if hide.left
      centerLeft = centerCenter = centerRight = true if hide.centerRow
      topCenter = centertCenter = bottomRight = true if hide.centerColumn

    # corners
    unless topLeft
      m = Matrix.scaleXY(sourceLeftScale, sourceTopScale).translateXY(targetAreaLeft, targetAreaTop)
      options.sourceArea = rect 0, 0, sourceLeftWidth, sourceTopHeight
      # log topLeft: sourceArea:options.sourceArea, matrix:m
      @drawBitmap m, bitmap, options

    unless topRight
      m = Matrix.scaleXY(sourceRightScale, sourceTopScale).translateXY(targetCenterAreaRight, targetAreaTop)
      options.sourceArea = rect sourceCenterAreaRight, 0, sourceRightWidth, sourceTopHeight
      # log topRight: sourceArea:options.sourceArea, matrix:m
      @drawBitmap m, bitmap, options

    unless bottomLeft
      m = Matrix.scaleXY(sourceLeftScale, sourceBottomScale).translateXY(targetAreaLeft, targetCenterAreaBottom)
      options.sourceArea = rect 0, sourceCenterAreaBottom, sourceLeftWidth, sourceBottomHeight
      # log bottomLeft: sourceArea:options.sourceArea, matrix:m
      @drawBitmap m, bitmap, options

    unless bottomRight
      m = Matrix.scaleXY(sourceRightScale, sourceBottomScale).translateXY(targetCenterAreaRight, targetCenterAreaBottom)
      options.sourceArea = rect sourceCenterAreaRight, sourceCenterAreaBottom, sourceRightWidth, sourceBottomHeight
      # log bottomRight: sourceArea:options.sourceArea, matrix:m
      @drawBitmap m, bitmap, options

    # horizontal row (including center)
    if targetCenterAreaHeight > 0
      unless centerLeft
        m = Matrix.scaleXY(sourceLeftScale, sourceCenterHeightScale).translateXY(targetAreaLeft, targetCenterAreaTop)
        options.sourceArea = rect 0, sourceTopHeight, sourceLeftWidth, sourceCenterAreaHeight
        @drawBitmap m, bitmap, options

      unless centerCenter || targetCenterAreaWidth <= 0
        m = Matrix.scaleXY(sourceCenterWidthScale, sourceCenterHeightScale).translateXY(targetCenterAreaLeft, targetCenterAreaTop)
        options.sourceArea = rect sourceCenterAreaLeft, sourceCenterAreaTop, sourceCenterAreaWidth, sourceCenterAreaHeight
        @drawBitmap m, bitmap, options

      unless centerRight
        m = Matrix.scaleXY(sourceRightScale, sourceCenterHeightScale).translateXY(targetCenterAreaRight, targetCenterAreaTop)
        options.sourceArea = rect sourceCenterAreaRight, sourceTopHeight, sourceRightWidth, sourceCenterAreaHeight
        @drawBitmap m, bitmap, options

    # vertical colum (excluding center)
    if sourceCenterAreaWidth > 0
      unless bottomCenter
        m = Matrix.scaleXY(sourceCenterWidthScale, sourceBottomScale).translateXY(targetCenterAreaLeft, targetCenterAreaBottom)
        options.sourceArea = rect sourceLeftWidth, sourceCenterAreaBottom, sourceCenterAreaWidth, sourceBottomHeight
        @drawBitmap m, bitmap, options

      unless topCenter
        m = Matrix.scaleXY(sourceCenterWidthScale, sourceTopScale).translateXY(targetCenterAreaLeft, targetAreaTop)
        options.sourceArea = rect sourceCenterAreaLeft, 0, sourceCenterAreaWidth, sourceTopHeight
        @drawBitmap m, bitmap, options


  # INCLUSIVE: returns first line with pixels > threshold
  calculateTop = (data, size, threshold) ->
    lineStep = size.x * pixelStep
    pos = alphaChannelOffset
    while pos < data.length && data[pos] <= threshold
      pos += pixelStep
    floor pos / lineStep

  # INCLUSIVE: returns last line with pixels > threshold
  calculateBottom = (data, size, threshold, top) ->
    lineStep = size.x * pixelStep
    pos = data.length + alphaChannelOffset - pixelStep # start on second to last line
    stopPos = top * lineStep
    while pos > stopPos && data[pos] <= threshold
      pos -= pixelStep
    floor pos / lineStep

  # INCLUSIVE: returns first column with pixels > threshold
  calculateLeft = (data, size, threshold, top, bottom) ->
    lineStep = size.x * pixelStep
    length = data.length
    topOffset = top * lineStep
    bottomOffset = bottom * lineStep
    posX = alphaChannelOffset
    while posX < lineStep
      pos = posX + topOffset
      stop = posX + bottomOffset
      while pos < stop
        return floor posX / pixelStep if data[pos] > threshold
        pos += lineStep
      posX += pixelStep

  # INCLUSIVE: returns last column with pixels > threshold
  calculateRight = (data, size, threshold, top, bottom, left) ->
    lineStep = size.x * pixelStep
    length = data.length
    topOffset = top * lineStep
    bottomOffset = bottom * lineStep
    posX = lineStep - pixelStep + alphaChannelOffset
    outterStop = left * pixelStep
    while posX > outterStop
      pos = posX + topOffset
      stop = posX + bottomOffset
      while pos < stop
        return floor posX / pixelStep if data[pos] > threshold
        pos += lineStep
      posX -= pixelStep

  getAutoCropRectangle: (threshold = 0)->
    {size, context} = @
    data = context.getImageData(0, 0, size.x, size.y).data

    top    = calculateTop    data, size, threshold
    return rect() if top == size.y
    bottom = calculateBottom data, size, threshold, top
    left   = calculateLeft   data, size, threshold, top, bottom
    right  = calculateRight  data, size, threshold, top, bottom, left

    rect left, top, right - left + 1, bottom - top + 1

  emptyOptions = {}
  ###
  IN:
    where:    null, matrix, point
    bitmap:   null or an instance of BitmapBase
    options:
      all drawBitmap's options PLUS:

      targetSize: size of the target area to layout in. Default: @size (target bitmap's size)

      aspectRatio: for the source pixels to be an aspectRatio other than implied by square-pixels.
        This is useful if you want one bitmap to layout exactly the same as another even though
        they have a different size.

      layout: 'zoom', 'fit', 'stretch'

        Selects how to layout.

  Note that pixels will NEVER be drawn outside of rect(point(), targetSize).

  That is why I restricted the layout modes to zoom, fit and stretch.

  ###
  drawBitmapWithLayout: (where, bitmap, options = emptyOptions) ->
    return unless bitmap

    {targetSize = @size, sourceArea, focus, aspectRatio, layout, opacity} = options
    return if opacity < 1/256

    if sourceArea
      sourceArea = sourceArea.mul bitmap.pixelsPerPoint if bitmap.pixelsPerPoint != 1
    else
      sourceArea = rect bitmap.size

    bitmapSize = bitmap.size

    sourceSize = sourceArea.size
    sourceLoc  = sourceArea.location

    aspectRatio ||= sourceSize.aspectRatio

    bitmapToThisMatrix = switch layout
      when "stretch"
        Matrix.scaleXY(
          targetSize.x / sourceSize.x
          targetSize.y / sourceSize.y
        )

      # Preserving Aspect Ratio; Centered: scale the bitmap so it fills all of targetSize
      when "zoom"
        adjustedTargetSize = if aspectRatio != sourceSize.aspectRatio
          point(
            targetSize.x * sourceSize.aspectRatio / aspectRatio
            targetSize.y
          )
        else
          targetSize

        scale = max adjustedTargetSize.x / sourceSize.x, adjustedTargetSize.y / sourceSize.y
        effectiveSourceSizeX = min bitmapSize.x, ceil adjustedTargetSize.x / scale
        effectiveSourceSizeY = min bitmapSize.y, ceil adjustedTargetSize.y / scale

        if focus
          desiredSourceX = sourceSize.x * focus.x - effectiveSourceSizeX * .5
          desiredSourceY = sourceSize.y * focus.y - effectiveSourceSizeY * .5
        else
          desiredSourceX = sourceLoc.x + sourceSize.x * .5 - round effectiveSourceSizeX * .5
          desiredSourceY = sourceLoc.y + sourceSize.y * .5 - round effectiveSourceSizeY * .5

        sourceX = bound 0, desiredSourceX, bitmapSize.x - effectiveSourceSizeX
        sourceY = bound 0, desiredSourceY, bitmapSize.y - effectiveSourceSizeY

        options = merge options, sourceArea: rect sourceX, sourceY, effectiveSourceSizeX, effectiveSourceSizeY

        Matrix.scaleXY(
          targetSize.x / effectiveSourceSizeX
          targetSize.y / effectiveSourceSizeY
        )

      when "fit"
        bitmapToThisMatrix = matrix()
        if aspectRatio != bitmapSize.aspectRatio
          s = bitmapSize
          bitmapSize = s.withAspectRatio aspectRatio
          bitmapToThisMatrix = bitmapToThisMatrix.scale scaler = bitmapSize.div s
          sourceSize = sourceSize.mul scaler
          sourceLoc = sourceLoc.mul scaler

        Matrix
        .translateXY -sourceArea.w/2, -sourceArea.h/2
        .mul bitmapToThisMatrix
        .scale min targetSize.x / sourceSize.x, targetSize.y / sourceSize.y
        .translateXY targetSize.x/2, targetSize.y/2

      else
        throw new Error "unknown mode: #{@_mode}"

    if where
      bitmapToThisMatrix = bitmapToThisMatrix.mul matrix where

    @drawBitmap bitmapToThisMatrix, bitmap, options