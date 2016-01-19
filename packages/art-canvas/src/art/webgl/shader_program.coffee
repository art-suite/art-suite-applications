define [
  'art-foundation'
  'art-atomic'
  './namespace'
], (Foundation, Atomic, Webgl) ->
  rawErrorLog = Foundation.Log.rawErrorLog

  class Webgl.ShaderProgram extends Foundation.BaseObject
    constructor: (context, name, fragmentShader, vertexShader, rendererClass) ->
      @name = name
      @context = context
      @fragmentShader = fragmentShader
      @vertexShader = vertexShader
      @rendererClass = rendererClass
      @link()

    @getter
      glShaderType: -> if @shaderType == "vertex" then @context.VERTEX_SHADER else @context.FRAGMENT_SHADER

    link: ->
      @program = @context.createProgram()
      @context.attachShader @program, @fragmentShader.shader
      @context.attachShader @program, @vertexShader.shader
      @context.linkProgram @program
      @reportLinkErrors()

    reportLinkErrors: ->
      unless @context.getProgramParameter @program, @context.LINK_STATUS
        message = @context.getProgramInfoLog @program
        rawErrorLog "Program name:#{@name} vertexShader: #{@vertexShader.name} fragmentShader: #{@fragmentShader.name}"
        rawErrorLog "Link error:\n#{message}"

    use: ->
      @context.useProgram @program
