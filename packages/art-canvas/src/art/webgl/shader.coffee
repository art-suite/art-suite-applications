define [
  'art.foundation'
  'art.atomic'
  './namespace'
], (Foundation, Atomic, Webgl) ->
  rawErrorLog = Foundation.Log.rawErrorLog

  class Webgl.Shader extends Foundation.BaseObject
    constructor: (context, name, shaderType, shaderCode) ->
      @name = name
      @shaderType = shaderType
      @context = context
      @shaderCode = shaderCode
      @compile()

    compile: ->
      @shader = @context.createShader @shaderType
      @context.shaderSource @shader, @shaderCode
      @context.compileShader @shader
      @reportCompileErrors()

    reportCompileErrors: ->
      unless @context.getShaderParameter @shader, @context.COMPILE_STATUS
        message = @context.getShaderInfoLog @shader
        rawErrorLog "Shader name:#{@name}, type:#{@shaderType}"
        rawErrorLog "Compile error:\n#{message}"
        rawErrorLog "Shader code:\n#{@shaderCode.replace ";    ", ";\n    "}"
