ColorThief = require './ColorThief'
Vibrant    = require './Vibrant'
Gradify    = require './Gradify'

{log, object, merge} = require 'art-foundation'
quantize = require 'quantize'

{gradientsToDrawRectangleParams} = require './GradifyHelper'

{rgb256Color, point, Matrix} = require 'art-atomic'

sbdGradients = (bitmap) ->
  b = bitmap.getMipmap s = point 3
  final = bitmap.newBitmap s
  final.drawBitmap Matrix.scale(s.div b.size), b
  log {bitmap, final}
  val = 7
  upscale1 = final.getScaled val
  upscale1.blur blur = Math.ceil val / 5

  upscale2 = upscale1.getScaled point area:point(700).div(upscale1.size).area, aspectRatio: bitmap.size.aspectRatio
  upscale2.drawBitmap Matrix.scale(upscale2.size.div upscale1.size), upscale1

  colors = for r, i in pd = final.imageData.data by 4
    rgb256Color r, pd[i + 1], pd[i + 2]

  log [{val, blur, upscale1}, upscale2, colors]
  colors

module.exports =
  version: version = (require '../../../package.json').version

  ###
  IN: imageData - a 1D RGBA pixel array

    Example:

    context = canvas.getContext '2d'
    imageData = context.getImageData 0, 0, canvas.width, canvas.height
    imageDataBuffer = imageData.data.buffer

    log extractColors imageDataBuffer
  ###
  extractColors: (imageDataBuffer, imageSize, bitmap) ->
    imageDataClampedArray = new Uint8ClampedArray imageDataBuffer

    # gradify = new Gradify imageDataClampedArray, imageSize


    # gradify:
    #   dominantColor:  gradify.rawColor
    #   gradients:      gradify.rawGradients

    # quantized:  new ColorThief().getPalette imageDataClampedArray
    merge
      version:    version
      colorMap:   sbdGradients bitmap
    # gradients:  gradientsToDrawRectangleParams gradify
      new Vibrant(imageDataClampedArray).rgbs
