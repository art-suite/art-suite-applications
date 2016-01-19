define [
  'art-foundation'
  'art-atomic'
  './namespace'
  './shader_renderer_colored'
  './shader_renderer_textured'
], (Foundation, Atomic, Webgl) ->

  vertexShaderCommonDeclarations = "
    attribute vec2 vertexLoc;
    uniform mat3 vertexMatrix;
    "
  vertexShaderCommonCode = "
    vec3 l = vec3(vertexLoc, 1) * vertexMatrix;
    gl_Position = vec4(l, 1);"

  class Webgl.ShaderPrograms
    @texturedUniformColor:
      rendererClass: Webgl.ShaderRendererTextured
      vertex: "
        #{vertexShaderCommonDeclarations}
        attribute vec2 textureLoc;
        varying vec2 interpolatedTextureLoc;
        void main(void)
          {
          #{vertexShaderCommonCode}
          interpolatedTextureLoc = textureLoc;
          }"
      fragment: "
        precision highp float;
        varying vec2 interpolatedTextureLoc;
        uniform sampler2D texture1;
        uniform vec4 color;
        void main(void) {gl_FragColor = texture2D(texture1, interpolatedTextureLoc) * color;}"

    @uniformColor:
      vertex: "
        #{vertexShaderCommonDeclarations}
        void main(void)
          {
          #{vertexShaderCommonCode}
          }"
      fragment: "
        precision highp float;
        uniform vec4 color;
        void main(void) {gl_FragColor = color;}"

    @colored:
      rendererClass: Webgl.ShaderRendererColored
      vertex: "
        #{vertexShaderCommonDeclarations}
        attribute vec4 vertexColor;
        varying vec4 interpolatedColor;
        uniform vec4 color;
        void main(void)
          {
          #{vertexShaderCommonCode}
          interpolatedColor = vertexColor * color;
          }"
      fragment: "
        precision highp float;
        varying vec4 interpolatedColor;
        void main(void) {gl_FragColor = interpolatedColor;}"
