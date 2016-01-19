define [
  'art-foundation'
  './namespace'
], (Foundation, Webgl) ->

  class Webgl.OffscreenRenderTarget extends Foundation.BaseObject

    constructor: (contextManager) ->
      @contextManager = contextManager
      @context = @contextManager.context
      @setup()

    setup: ->
      @framebuffer = @context.createFramebuffer()
      @renderbuffer = @context.createRenderbuffer()

    bind: (texture) ->
      @context.bindTexture @context.TEXTURE_2D, texture
      @context.bindFramebuffer @context.FRAMEBUFFER, @framebuffer
      @context.bindRenderbuffer @context.RENDERBUFFER, @renderbuffer
      @context.framebufferTexture2D @context.FRAMEBUFFER, @context.COLOR_ATTACHMENT0, @context.TEXTURE_2D, texture, 0
