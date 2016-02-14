# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
# http://diveintohtml5.info/canvas.html
# http://arcturo.github.io/library/coffeescript/
# http://jsfiddle.net/
# http://mudcu.be/journal/2011/04/globalcompositeoperation/
# Canvas Spec: http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html
# http://dev.w3.org/fxtf/compositing-1/#porterduffcompositingoperators_srcover
define [
  'art-foundation'
  'art-atomic'
  ], (Foundation, Atomic) ->

  {point, Point, rect, Rectangle, matrix, Matrix, color, Color} = Atomic
  {inspect, nextTick, BaseObject, Binary, pureMerge, isString, isNumber, log} = Foundation
  {round, floor} = Math
  {BinaryString} = Binary

  toChannelNumberMap = 0:0, 1:1, 2:2, 3:3, r:0, g:1, b:2, a:3, red:0, green:1, blue:2, alpha:3

  class BitmapBase extends BaseObject
    @bitmapsCreated: 0
    compositeModeSupported: (mode) -> @supportedCompositeModes.indexOf(mode) >= 0
    @pixelSnapDefault = true

    defaultColor: color "black"
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
      canvas: -> @_canvas
      bitmapClass: -> @class # part of the bitmapFactory api
      clippingArea: -> @_clippingArea ||= rect @getSize()
      aspectRatio: -> @getSize().getAspectRatio()

    shouldPixelSnap: (where) ->
      @pixelSnap && (
        (!where) ||
        (where instanceof Point) ||
        where.isTranslateAndScaleOnly
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
      @_canvas = document.createElement 'canvas'
      @_canvas.width = @size.x
      @_canvas.height = @size.y
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
    getImageData: (a, b, c, d) ->
      area = if a==null || a==undefined then rect @size else rect a, b, c, d
      @toMemoryBitmap().context.getImageData area.x, area.y, area.w, area.h

    putImageData: (imageData, location = point(), sourceArea = rect @size) ->
      location = location.sub sourceArea.location

      @_context.putImageData imageData, location.x, location.y,
        sourceArea.x, sourceArea.y, sourceArea.w, sourceArea.h

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

    toPngUri: (callback) ->
      throw new Error "Bitmap.toPngUri: callback is no longer supported; use returned Promise" if callback
      nextTick()
      .then => # use nextTick to ensure all pending draw commands complete before we extract the pixel data
        @toMemoryBitmap().canvas.toDataURL()

    toJpgUri: (quality=.95, callback) ->
      throw new Error "Bitmap.toJpgUri: callback is no longer supported; use returned Promise" if callback
      nextTick()
      .then => # use nextTick to ensure all pending draw commands complete before we extract the pixel data
        @toMemoryBitmap().canvas.toDataURL "image/jpeg", quality

    # results in BinaryString
    toPng: (callback) ->
      throw new Error "Bitmap.toPng: callback is no longer supported; use returned Promise" if callback
      @toPngUri()
      .then (dataURI) ->
        BinaryString.fromDataUri dataURI

    # results in BinaryString
    toJpg: (quality, callback) ->
      throw new Error "Bitmap.toJpg: callback is no longer supported; use returned Promise" if callback
      @toJpgUri quality
      .then (dataURI) ->
        BinaryString.fromDataUri dataURI

    toImage: (callback) ->
      throw new Error "Bitmap.toImage: callback is no longer supported; use returned Promise" if callback
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
      result.drawBitmap Matrix.translate(-@size.x/2,0).scale(-1,1).translate(@size.x/2,0), @
      result

    vFlipped: ->
      result = @newBitmap @size
      result.drawBitmap Matrix.translate(0,-@size.y/2).scale(1,-1).translate(0,@size.y/2), @
      result

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
        m = Matrix.scale(sourceLeftScale, sourceTopScale).translate(targetAreaLeft, targetAreaTop)
        options.sourceArea = rect 0, 0, sourceLeftWidth, sourceTopHeight
        # log topLeft: sourceArea:options.sourceArea, matrix:m
        @drawBitmap m, bitmap, options

      unless topRight
        m = Matrix.scale(sourceRightScale, sourceTopScale).translate(targetCenterAreaRight, targetAreaTop)
        options.sourceArea = rect sourceCenterAreaRight, 0, sourceRightWidth, sourceTopHeight
        # log topRight: sourceArea:options.sourceArea, matrix:m
        @drawBitmap m, bitmap, options

      unless bottomLeft
        m = Matrix.scale(sourceLeftScale, sourceBottomScale).translate(targetAreaLeft, targetCenterAreaBottom)
        options.sourceArea = rect 0, sourceCenterAreaBottom, sourceLeftWidth, sourceBottomHeight
        # log bottomLeft: sourceArea:options.sourceArea, matrix:m
        @drawBitmap m, bitmap, options

      unless bottomRight
        m = Matrix.scale(sourceRightScale, sourceBottomScale).translate(targetCenterAreaRight, targetCenterAreaBottom)
        options.sourceArea = rect sourceCenterAreaRight, sourceCenterAreaBottom, sourceRightWidth, sourceBottomHeight
        # log bottomRight: sourceArea:options.sourceArea, matrix:m
        @drawBitmap m, bitmap, options

      # horizontal row (including center)
      if targetCenterAreaHeight > 0
        unless centerLeft
          m = Matrix.scale(sourceLeftScale, sourceCenterHeightScale).translate(targetAreaLeft, targetCenterAreaTop)
          options.sourceArea = rect 0, sourceTopHeight, sourceLeftWidth, sourceCenterAreaHeight
          @drawBitmap m, bitmap, options

        unless centerCenter || targetCenterAreaWidth <= 0
          m = Matrix.scale(sourceCenterWidthScale, sourceCenterHeightScale).translate(targetCenterAreaLeft, targetCenterAreaTop)
          options.sourceArea = rect sourceCenterAreaLeft, sourceCenterAreaTop, sourceCenterAreaWidth, sourceCenterAreaHeight
          @drawBitmap m, bitmap, options

        unless centerRight
          m = Matrix.scale(sourceRightScale, sourceCenterHeightScale).translate(targetCenterAreaRight, targetCenterAreaTop)
          options.sourceArea = rect sourceCenterAreaRight, sourceTopHeight, sourceRightWidth, sourceCenterAreaHeight
          @drawBitmap m, bitmap, options

      # vertical colum (excluding center)
      if sourceCenterAreaWidth > 0
        unless bottomCenter
          m = Matrix.scale(sourceCenterWidthScale, sourceBottomScale).translate(targetCenterAreaLeft, targetCenterAreaBottom)
          options.sourceArea = rect sourceLeftWidth, sourceCenterAreaBottom, sourceCenterAreaWidth, sourceBottomHeight
          @drawBitmap m, bitmap, options

        unless topCenter
          m = Matrix.scale(sourceCenterWidthScale, sourceTopScale).translate(targetCenterAreaLeft, targetAreaTop)
          options.sourceArea = rect sourceCenterAreaLeft, 0, sourceCenterAreaWidth, sourceTopHeight
          @drawBitmap m, bitmap, options
