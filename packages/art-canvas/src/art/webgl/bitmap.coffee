define [
  'art.foundation'
  'art.atomic'
  '../canvas'
  './namespace'
  './context_manager'
], (Foundation, Atomic, Canvas, Webgl, ContextManager) ->
  {color, Color, point, Point, rect, Rectangle, matrix, Matrix} = Atomic

  inspect = Foundation.Inspect.inspect
  eq = Foundation.Eq.eq

  white = color 1,1,1,1

  superSuperConstructor = Canvas.BitmapBase.__super__.constructor

  class Webgl.Bitmap extends Canvas.BitmapBase
    @supportedCompositeModes: Webgl.ContextManager.supportedCompositeModes
    @getter supportedCompositeModes: -> Bitmap.supportedCompositeModes

    constructor: (a, b) ->
      if a instanceof Webgl.ContextManager
        superSuperConstructor.apply(@, arguments)
        @initFromContextManager a, b
      else super  # creates a new context

    ################
    # bitmapFactory
    newBitmap: (size) -> new @bitmapClass(@_contextManager, size || @size).tap (b) => b.pixelsPerPoint = @pixelsPerPoint
    ################

    setClippingArea: (area) ->
      if area
        @_clippingArea = area = (area||rect(@size)).roundIn 1, 1/256

        # Remember: point(0,0) is the upper-left corner for textures and the lower-left corner for the main frameBuffer
        @_contextManager.viewport = if @texture
          area
        else
          rect area.x, @size.y - area.bottom, area.w, area.h
      else
        @_contextManager.viewport = rect @size
        @_clippingArea = null
      @updateDrawMatrix()

    # execs funciton "f" while clipping
    clippedTo: (area, f) ->
      previousClippingArea = @_clippingArea
      try
        @setClippingArea a = area.intersection @_clippingArea
        f()
      finally
        @setClippingArea previousClippingArea

    populateClone: (result)->
      result.initFromContextManager @_contextManager, @size
      super

    initFromContextManager: (cm, initializer) ->
      @_contextManager = cm
      @_context = @_contextManager.context
      [@_size, @texture] = cm.newTexture initializer

    initContext: ->
      @_contextManager = new Webgl.ContextManager @_canvas
      @_context = @_contextManager.context

    @getter
      isTexture: -> !!@texture

    toMemoryDrawableBitmap: ->
      if @isTexture
        @toMemoryBitmap()
      else
        @

    toMemoryBitmap: ->
      memoryBitmap = new Canvas.Bitmap @size
      if @isTexture
        imageData = memoryBitmap.context.createImageData @size.x, @size.y
        @fillImageData imageData
        memoryBitmap.putImageData imageData
      else
        memoryBitmap.clear color 0, 0, 0, 0 # we should be able to do this just with drawBitmap and the right blend mode
        memoryBitmap.drawBitmap point(), @

      memoryBitmap

    ######################
    # draw
    ######################

    startGL: (mode = "normal")->
      @_contextManager.setRenderTarget @
      @_contextManager.setGLBlender mode
      @updateDrawMatrix() unless @drawMatrix

    updateDrawMatrix: ->
      tx = ty = 0
      sx = sy = 1
      size = if @_clippingArea
        tx = -@_clippingArea.x
        ty = -@_clippingArea.y
        @_clippingArea.size
      else
        @size
      if @texture
        sx = 2/size.x
        sy = 2/size.y
        tx = tx * sx - 1
        ty = ty * sy - 1
      else
        sx = 2/size.x
        sy = -2/size.y
        tx = tx * sx - 1
        ty = ty * sy + 1
      @drawMatrix = new Matrix sx, sy, 0, 0, tx, ty #.scale(@vertexScaler).translate(@vertexTranslator)

    clear: (a, b, c, d) ->
      clr = if a? then color a, b, c, d else color 0, 0, 0, 0
      @startGL()
      clr = clr.premultiplied
      @_context.clearColor clr.r, clr.g, clr.b, clr.a
      @_context.clear @_context.COLOR_BUFFER_BIT

    # where options: Matrix, Point or null
    # rectangle options: Rectangle or Point
    # options:
    #
    drawRectangle: (where, rectangle, options) ->

      {compositeMode, fillStyle} = options
      clr = options.color

      rectangle = rect rectangle
      if @shouldPixelSnap where
        rectangle = @pixelSnapRectangle where, rectangle

      if fillStyle instanceof Canvas.GradientFillStyle
        @drawLinearGradientRectangle where, rectangle, fillStyle, compositeMode
      else
        c = color(clr).premultiplied
        @startGL compositeMode
        @_contextManager.uniformColorRenderer.renderRectangle where, rectangle, c
        @

    drawLinearGradientRectangle: (where, rectangle, gfs, compositeMode) ->
      gfsBitmap = @gradientBitmap gfs, point 512, 1

      gp1 = gfs.from
      gp2 = gfs.to
      gradientV = gp2.sub gp1
      factor = 1 / gradientV.magnitudeSquared
      xRect = if rectangle instanceof Point then rectangle = rect(rectangle) else rect(rectangle.size)

      @startGL compositeMode
      @_contextManager.texturedUniformColorRenderer.renderRectangle where, rectangle, white, (renderer)->
        renderer.texture = gfsBitmap.texture
        renderer.addTextureLocation point p.sub(gp1).dot(gradientV) * factor, 0 for p in xRect.corners
      @

    # where options: Matrix, Point or null
    drawBitmap: (where, bitmap, options) ->
      unless bitmap.texture
        bitmap = @newBitmap bitmap

      # where = @pixelSnapWhere where if @shouldPixelSnap where

      if options
        sourceArea = options.sourceArea
        opacity = options.opacity
        compositeMode = options.compositeMode

      bitmapSize = bitmap.size

      opacity = if opacity? then opacity else 1
      r = if !sourceArea
        sourceArea = bitmapSize
      else if sourceArea.x != 0 || sourceArea.y != 0
        new Rectangle 0, 0, sourceArea.w, sourceArea.h
      else
        sourceArea

      @startGL compositeMode
      @_contextManager.texturedUniformColorRenderer.renderRectangle where, r, opacity, (renderer) ->
        renderer.texture = bitmap.texture
        xScaler = 1/bitmapSize.x
        yScaler = 1/bitmapSize.y
        data = renderer.allocateTextureLocations 4
        data[0] = sourceArea.left * xScaler
        data[1] = sourceArea.top * yScaler

        data[2] = sourceArea.right * xScaler
        data[3] = sourceArea.top * yScaler

        data[4] = sourceArea.right * xScaler
        data[5] = sourceArea.bottom * yScaler

        data[6] = sourceArea.left * xScaler
        data[7] = sourceArea.bottom * yScaler
      @

    ############################
    # blur
    ############################
    # if toClone is true, creates a new bitmap with the blurred data
    blur: (radius, toClone)->
      @log "WARNING: WebGL blurring not implemented efficiently, yet..."
      mem = @toMemoryBitmap().blur radius
      toClone = if toClone then @clone() else @
      toClone.drawBitmap null, mem, compositeMode:"replace"
      toClone

    # if toClone is true, creates a new bitmap with the blurred data
    blurAlpha: (radius, options)->
      @log "WARNING: WebGL alpha-blurring not implemented efficiently, yet..."
      toClone = if options?.clone then @clone() else @
      options && options.clone = null
      mem = @toMemoryBitmap().blurAlpha radius, options
      toClone.drawBitmap null, mem, compositeMode:"replace"
      toClone

    ######################
    # canvas2d compatibility
    ######################

    setTransform: -> 1
    fillText: ->

    #TODO: implement putImageData:
    getImageData: (a, b, c, d) ->
      return super unless @texture
      r = if a? then rect a, b, c, d else rect @size

      imageData =
        data: new Uint8Array r.area * 4
        width: r.w
        height: r.h

      @fillImageData imageData, r

      imageData

    bindTexture: ->
      @_context.bindTexture @_context.TEXTURE_2D, @texture

    demultiplyImageData: (data) ->
      for r,i in data by 4
        g = data[i+1]
        b = data[i+2]
        a = data[i+3]
        m = 255.0/a
        # BASIC version
        # data[i  ] = r * m
        # data[i+1] = g * m
        # data[i+2] = b * m
        # SPECIAL-ADD-COMPOSITING version
        #   with special-add-compositing r,g,b can be > a
        data[i  ] = if r > a then 255 else r * m
        data[i+1] = if g > a then 255 else g * m
        data[i+2] = if b > a then 255 else b * m
        data[i+3] = a = r if r > a
        data[i+3] = a = g if g > a
        data[i+3] = a = b if b > a
      null


    fillImageData: (imageData, r = rect @size) ->
      @startGL()
      data = imageData.data
      if data.buffer
        data = new Uint8Array data.buffer
        @_context.readPixels r.x, r.y, r.w, r.h, @_context.RGBA, @_context.UNSIGNED_BYTE, data
        @demultiplyImageData data
      else
        tempData = new Uint8Array r.w * r.h * 4
        @_context.readPixels r.x, r.y, r.w, r.h, @_context.RGBA, @_context.UNSIGNED_BYTE, tempData
        @demultiplyImageData tempData
        for v, i in tempData
          data[i] = v




    ######################
    # private
    ######################

    gradientBitmap: (gradientFillStyle, size = point 1024, 1) ->
      bitmap = @newBitmap size
      colors = gradientFillStyle.premultipliedColorPositions
      lastX = 0
      lastC = colors[0].c

      w = size.x
      r = rect 0, 0, 0, size.y

      bitmap.startGL()
      renderer = @_contextManager.coloredRenderer
      for colorN, i in colors
        if i > 0
          r = rect r.x, r.y, colorN.n * w - r.x, r.h
          c = colorN.c

          renderer.renderRectangle null, r, white, ->
            renderer.addColor lastC
            renderer.addColor c
            renderer.addColor c
            renderer.addColor lastC

          r = rect r.right, r.y, r.w, r.h
          lastC = c
      bitmap
