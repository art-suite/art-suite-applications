{defineModule, BaseObject} = require 'art-foundation'
###
  CanvasImage Class
  Class that wraps the html image element and canvas.
  It also simplifies some of the canvas context manipulation
  with a set of helper functions.
###
defineModule module, class CanvasImage extends BaseObject

  constructor: (image, width, height) ->
    @canvas  = document.createElement 'canvas'
    @context = @canvas.getContext '2d'

    @width  = @canvas.width  = width || image.width
    @height = @canvas.height = height || image.height

    @context.drawImage image, 0, 0, @width, @height

  clear:              -> @context.clearRect 0, 0, @width, @height
  update: (imageData) -> @context.putImageData imageData, 0, 0
  removeCanvas:       -> @canvas.parentNode.removeChild @canvas

  @getter
    pixelCount: -> @width * @height
    imageData:  -> @context.getImageData 0, 0, @width, @height
