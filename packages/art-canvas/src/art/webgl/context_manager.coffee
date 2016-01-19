# Premultiplied Alpha - we have to use it for OpenGL, sadly. This means we lose some quality when alpha is non-one
# Details: http://stackoverflow.com/questions/19395874/how-to-handle-alpha-compositing-correctly-with-opengl
# The non premultipled equation: (src and dst pixels)
#   final.a = src.a + dst.a * (1 - src.a)
#   final.v = (src.v * src.a + dst.v * dst.a * (1 - src.a)) / final.a
#   -- two multiplication factors for dst AND the dividing by final.a are impossible in OpenGL
# Interesting - potentially we can do Add and Normal compositing in the same pass: http://blog.rarepebble.com/111/premultiplied-alpha-in-opengl/
#

define [
  'art-foundation'
  'art-atomic'
  '../canvas'
  './namespace'
  './shader'
  './offscreen_render_target'
  './shader_program'
  './shader_programs'
  './shader_renderer'
], (Foundation, Atomic, Canvas, Webgl) ->
  {color, Color, point, Point, rect, Rectangle, matrix, Matrix} = Atomic

  inspect = Foundation.Inspect.inspect

  blendModeSetters =
    replace:            (gl) -> gl.disable gl.BLEND
    normal:             (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.ONE,                  gl.ONE_MINUS_SRC_ALPHA
    add:                (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.ONE,                  gl.ONE
    associative_add:    (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFuncSeparate gl.ONE, gl.ONE, gl.ZERO, gl.ONE
      # This is possible because we use pre-multiplied alpha
      # If "@" represents a normal-compositing operation and "+" represents an associative_add, then associative_add allows the following to be true:
      #   (a + b) @ c === a + (b @ c)
      # In other words:
      #   (a + b) @ c, associatve_add a onto b then normal-composite the result with c
      # has the same result as:
      #   a + (b @ c), normal-composite b onto c then associatve_add a onto the result
      # How it works: The only difference is we don't add the source pixels alpha to the destination pixel.
      #  The effect is the color channel values can then exceed the alpha channel value.
      #  Since we are using pre-multiplied alphas, a normal correctPixel should never have color values greater than the alpha channel.
      #  Color values greater than the alpha channel become effectively super-bright colors.
      #  Since the source pixel is also pre-multiplied,Even though we are ignoring the source pixels alpha channel, the alpha channels data is already encoded in the color channels.
    alphamask:          (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.ZERO,                 gl.SRC_ALPHA
    target_alphamask:   (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.DST_ALPHA,            gl.ZERO        # as-if you used "alphamask" except you swapped the target and source pixel before compositing
    destover:           (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.ONE_MINUS_DST_ALPHA,  gl.ONE
    sourcein:           (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.DST_ALPHA,            gl.ONE_MINUS_SRC_ALPHA

    sub:                (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_REVERSE_SUBTRACT;  gl.blendFunc gl.ONE,                  gl.ONE
    erase:              (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.ZERO,                 gl.ONE_MINUS_SRC_ALPHA
    mul:                (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.DST_COLOR,            gl.ZERO
    inverse_alphamask:  (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFunc gl.ZERO,                 gl.ONE_MINUS_SRC_ALPHA # as-if you used "alphamask" except you inverted the source alpha before compositing
      # Multiply all channels of the target pixel by the inverse alpha of the source pixel
    inverse_alpha:      (gl) -> gl.enable gl.BLEND; gl.blendEquation gl.FUNC_ADD;               gl.blendFuncSeparate gl.ZERO, gl.ONE, gl.ZERO, gl.ONE_MINUS_SRC_ALPHA
      # Same as inverse_alphamask except it only applies to the Alpha channel

  class Webgl.ContextManager extends Foundation.BaseObject
    @supportedCompositeModes: (k for k, v of blendModeSetters)

    constructor: (canvas) ->
      @canvas = canvas

      @canvas.addEventListener "webglcontextlost", (event) -> @log "WEBGL CONTEXT LOST"

      contextOptions =
        premultipliedAlpha: false
      @context = @canvas.getContext("webgl", contextOptions) || @canvas.getContext("experimental-webgl", contextOptions)
      if window.WebGLDebugUtils
        @log "!!!!!!!!!!!!!!!!!!! Using WebGLDebugUtils !!!!!!!!!!!!!"
        @context = WebGLDebugUtils.makeDebugContext @context

      Webgl.Detector.detect (message) -> throw new Error message unless @context

      @offscreenRenderTarget = new Webgl.OffscreenRenderTarget @

      @shaders = {}
      @shaderPrograms = {}
      @renderers = {}
      @initBasicShaders()

    # Remember: point(0,0) is the upper-left corner for textures and the lower-left corner for the main frameBuffer
    @setter viewport: (r) -> @context.viewport r.x, r.y, r.w, r.h

    #########################
    # bitmapFactory api
    @getter bitmapClass: -> Webgl.Bitmap # part of the bitmapFactory api
    newBitmap: (size) -> new Webgl.Bitmap @, size
    #########################

    shaderProgram: (name) -> @shaderPrograms[name] ||= @compileShaderProgram name
    renderer: (name) -> @renderers[name] ||= @buildRenderer name

    buildRenderer: (name) ->
      program = @shaderProgram name
      rendererClass = program.rendererClass || Webgl.ShaderRenderer
      new rendererClass @, program

    compileShaderProgram: (name) ->
      definition = Webgl.ShaderPrograms[name]
      throw new Error "ShaderProgram #{inspect name} not found in Webgl.ShaderPrograms" unless definition
      new Webgl.ShaderProgram @context, name,
        new Webgl.Shader(@context, name+"FragmentShader", @context.FRAGMENT_SHADER, definition.fragment),
        new Webgl.Shader(@context, name+"VertexShader", @context.VERTEX_SHADER, definition.vertex),
        definition.rendererClass

    newTexture: (a) ->
      size = if a instanceof Point then a
      else if a instanceof Canvas.Bitmap
        loadPixelDataFrom = a.canvas
        a.size
      else if a instanceof HTMLCanvasElement
        loadPixelDataFrom = a
        point a.width, a.height
      else if a instanceof HTMLImageElement
        loadPixelDataFrom = a
        point a.width, a.height

      throw new Error("size must be >= 1,1") if !(size.x >= 1 && size.y >= 1)

      gl = @context
      texture = gl.createTexture()
      gl.bindTexture gl.TEXTURE_2D, texture
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR  # or NEAREST
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR  # or NEAREST
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE

      gl.pixelStorei gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true

      if loadPixelDataFrom
        gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, loadPixelDataFrom
      else
        gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, size.width, size.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null

      [size, texture]

    bindGlobalRenderTarget: ->
      @context.bindTexture @context.TEXTURE_2D, null
      @context.bindFramebuffer @context.FRAMEBUFFER, null
      @context.bindRenderbuffer @context.RENDERBUFFER, null

    setRenderTarget: (bitmap) ->
      return if @renderTarget == bitmap # no change
      if bitmap.texture?
        @offscreenRenderTarget.bind bitmap.texture
      else
        @bindGlobalRenderTarget()
      size = bitmap.size
      if clippingArea = bitmap.clippingArea
        height = size.y
        @context.viewport clippingArea.x, height - clippingArea.bottom, clippingArea.w, clippingArea.h
      else
        @context.viewport 0, 0, size.x, size.y
      @renderTarget = bitmap

    setGLBlender: (mode)->
      return if @blenderMode == mode # no change

      blendModeSetter = blendModeSetters[mode]
      throw "invalid blend mode: #{mode}" unless blendModeSetter
      blendModeSetter @context

      @blenderMode = mode

    initBasicShaders: ->
      @uniformColorRenderer = @renderer "uniformColor"
      @texturedUniformColorRenderer = @renderer "texturedUniformColor"
      @coloredRenderer = @renderer "colored"
