define [
  'art-foundation'
  'art-atomic'
  '../canvas'
  './namespace'
  './context_manager'
], (Foundation, Atomic, Canvas, Webgl, ContextManager) ->
  {color, Color, point, Point, rect, Rectangle, matrix, Matrix} = Atomic

  class Webgl.ShaderRendererTextured extends Webgl.ShaderRenderer
    constructor: ->
      super
      @glTextureBuffer = @context.createBuffer()

    addTextureLocation: (loc) ->
      @textureLocations ||= []
      loc.appendToVector @textureLocations

    shaderAttributeNames: -> super.concat ["textureLoc"]
    shaderUniformNames: -> super.concat ["texture1"]

    # returns the texture-locations Float32Array. Locations are x,y pairs.
    allocateTextureLocations: (numLocations) ->
      @float32ArrayTextureData = new Float32Array numLocations * 2

    reset: ->
      super
      @float32ArrayTextureData = null
      @textureLocations = null
      @texture = null

    bindTexture: ->
      gl = @context
      gl.activeTexture gl.TEXTURE0
      gl.bindTexture gl.TEXTURE_2D, @texture
      @bindUniformInt @texture1UniformLocation, 0
      @float32ArrayTextureData ||= new Float32Array @textureLocations
      @bindFloatArray @textureLocAttribLocation, @float32ArrayTextureData, 2, @glTextureBuffer

    bindEverything: ->
      super
      @bindTexture()
