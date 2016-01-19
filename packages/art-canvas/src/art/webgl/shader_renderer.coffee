define [
  'art-foundation'
  'art-atomic'
  '../canvas'
  './namespace'
  './context_manager'
], (Foundation, Atomic, Canvas, Webgl, ContextManager) ->
  {color, Color, point, Point, rect, Rectangle, matrix, Matrix} = Atomic

  class Webgl.ShaderRenderer extends Foundation.BaseObject
    constructor: (contextManager, shaderProgram) ->
      @contextManager = contextManager
      @context = contextManager.context
      @shaderProgram = shaderProgram
      @glProgram = shaderProgram.program
      @uniformLocations={}
      @attributeLocations={}
      @glVertexBuffer = @context.createBuffer()

      @initShaderLocations()

    shaderAttributeNames: -> ["vertexLoc"]
    shaderUniformNames: -> ["color", "vertexMatrix"]

    initShaderLocations: ->
      for name in @shaderAttributeNames()
        @[name+"AttribLocation"] = @context.getAttribLocation @glProgram, name

      for name in @shaderUniformNames()
        @[name+"UniformLocation"] = @context.getUniformLocation @glProgram, name

    startTriangleStrip: (vertexCount) ->
      @drawMode = @context.TRIANGLE_STRIP
      @reset vertexCount

    startTriangleFan: (vertexCount) ->
      @drawMode = @context.TRIANGLE_FAN
      @reset vertexCount

    render: ->
      @shaderProgram.use()
      @bindEverything()
      @drawArrays()

    # this is only broken out for testing, we might want to put it inline in render for performance
    drawArrays: ->
      @context.drawArrays @drawMode, 0, @vertexCount

    ######################
    # one-step functions
    ######################
    # pass in a function that takes the renderer as input
    # Example: # renders a yellow rectangle
    # uniformColorRenderer.renderTriangleFan (r) ->
    #   r.add p for p in rect(10,10,20,20).corners
    #   r.color = color "#ff0"
    renderTriangleFan: (vertexCount, f) -> @startTriangleFan(vertexCount);f @;@render()
    renderTriangleStrip: (vertexCount, f) -> @startTriangleStrip(vertexCount);f @;@render()

    # inputs must be exactly: Atomic.Matrix, Atomic.Rectangle, and Atomic.Color
    renderRectangle: (m, r, c, f) ->
      @startTriangleFan 4
      @color = c
      va = @float32ArrayVertexData
      i = 0
      @matrix = m
      va[0] = r.left
      va[1] = r.top

      va[2] = r.right
      va[3] = r.top

      va[4] = r.right
      va[5] = r.bottom

      va[6] = r.left
      va[7] = r.bottom

      f @ if f
      @render()

    ######################
    # BINDING HELPERS
    ######################

    bindUniformInt:   (uniformLocation, v) -> @context.uniform1i uniformLocation, v
    bindUniformFloat: (uniformLocation, v) -> @context.uniform1f uniformLocation, v
    bindUniformPoint: (uniformLocation, p) -> @context.uniform2f uniformLocation, p.x, p.y
    bindUniformColor: (uniformLocation, c) ->
      if typeof c is "number"
        @context.uniform4f uniformLocation, c, c, c, c
      else
        @context.uniform4f uniformLocation, c.r, c.g, c.b, c.a

    bindUniformVec2:  (uniformLocation, a, b) -> @context.uniform4f uniformLocation, a, b
    bindUniformVec4:  (uniformLocation, a, b, c, d) -> @context.uniform4f uniformLocation, a, b, c, d
    bindUniformMatrix:(uniformLocation, m) ->
      m.fillFloat32Array @matrixData
      @context.uniformMatrix3fv uniformLocation,
        false, # transpose? (must be FALSE)
        @matrixData

    bindFloatArray: (attribLocation, float32Array, floatsPerVector, glBuffer) ->
      gl = @context
      gl.bindBuffer gl.ARRAY_BUFFER, glBuffer
      gl.bufferData gl.ARRAY_BUFFER, float32Array, gl.STATIC_DRAW

      gl.enableVertexAttribArray attribLocation
      gl.bindBuffer gl.ARRAY_BUFFER, glBuffer
      gl.vertexAttribPointer attribLocation, floatsPerVector, gl.FLOAT, false, 0, 0

    ######################
    # INTERNAL METHODS
    ######################
    reset: (vertexCount) ->
      if !@float32ArrayVertexData || @float32ArrayVertexData.length < vertexCount * 2
        @float32ArrayVertexData = new Float32Array vertexCount * 2
      @vertexCount = vertexCount
      @color = 1
      @matrixData ||= new Float32Array [1, 0, 0, 0, 1, 0, 0, 0, 0]

    bindEverything: ->
      @bindVerticies()
      @bindGeometry()
      @bindColor()

    bindVerticies: ->
      @bindFloatArray @vertexLocAttribLocation, @float32ArrayVertexData, 2, @glVertexBuffer

    bindColor: -> @bindUniformColor @colorUniformLocation, @color

    bindGeometry: ->
      drawMatrix = @contextManager.renderTarget.drawMatrix
      m = if @matrix
        @matrix = matrix(@matrix) unless @matrix instanceof Matrix
        @matrix.mul drawMatrix
      else
        drawMatrix
      @bindUniformMatrix @vertexMatrixUniformLocation, m
