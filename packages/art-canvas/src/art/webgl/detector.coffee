define [
  './namespace'
  'art.foundation'
], (Webgl, Foundation) ->

  helpMessage = "This web browser does not support Webgl, or it is disabled. We recommend using Chrome (http://www.google.com/chrome) or Firefox (http://www.mozilla.org/firefox). You might also try updating your video driver."

  class Webgl.Detector extends Foundation.BaseObject
    @detect: (onFailure = null)->
      if !window.WebGLRenderingContext
        @log helpMessage
        onFailure helpMessage if onFailure
        return false

      canvas = document.createElement 'canvas'
      context = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
      if !context
        @log helpMessage
        onFailure helpMessage if onFailure
        return false

      true
