define [
  'art.foundation'
  'art.atomic'
  '../canvas'
  './namespace'
  './shader_renderer'
], (Foundation, Atomic, Canvas, Webgl, ShaderRenderer) ->
  {color, Color, point, Point, rect, Rectangle, matrix, Matrix} = Atomic

  class Webgl.ShaderRendererColored extends ShaderRenderer
    constructor: ->
      super
      @glColorBuffer = @context.createBuffer()

    addColor: (c) ->
      @colorData = @colorData.concat [c.r, c.g, c.b, c.a]

    shaderAttributeNames: -> super.concat ["vertexColor"]

    reset: ->
      super
      @float32ArrayColorData = null
      @colorData = []
      @color = null

    bindEverything: ->
      super
      @bindColors()

    bindColors: ->
      @float32ArrayColorData ||= new Float32Array @colorData
      @bindFloatArray @vertexColorAttribLocation, @float32ArrayColorData, 4, @glColorBuffer
