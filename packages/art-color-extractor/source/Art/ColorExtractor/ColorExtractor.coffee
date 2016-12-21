ColorThief = require './ColorThief'
Vibrant    = require './Vibrant'
Gradify    = require './Gradify'

{log, object} = require 'art-foundation'
quantize = require 'quantize'

module.exports =
  ###
  IN: imageData - a 1D RGBA pixel array

    Example:

    context = canvas.getContext '2d'
    imageData = context.getImageData 0, 0, canvas.width, canvas.height
    imageDataBuffer = imageData.data.buffer

    log extractColors imageDataBuffer
  ###
  extractColors: (imageDataBuffer, imageSize) ->
    imageDataClampedArray = new Uint8ClampedArray imageDataBuffer

    gradify = new Gradify imageDataClampedArray, imageSize

    # gradify:
    #   dominantColor:  gradify.rawColor
    #   gradients:      gradify.rawGradients

    # quantized:        new ColorThief().getPalette imageDataClampedArray

    vibrant: new Vibrant(imageDataClampedArray).rgbs
