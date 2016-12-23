Vibrant    = require './Vibrant'

{log, object, merge} = require 'art-foundation'

{rgb256Color, point, Matrix} = require 'art-atomic'
{Bitmap} = require 'art-canvas'

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


previewBitmapScale = 7
previewBitmapBlur = 2

module.exports =
  version: version = (require '../../../package.json').version

  getColorMapBitmap: getColorMapBitmap = (colorMap) ->
    {imageData} = colorMapBitmap = new Bitmap 3
    i = 0
    {data} = imageData
    for color in colorMap
      {r256,g256,b256} = rgbColor color
      data[i + 0] = r256
      data[i + 1] = g256
      data[i + 2] = b256
      data[i + 3] = 255
      i += 4

    colorMapBitmap.putImageData imageData


  generatePreviewBitmap: ({colorMap})->
    getColorMapBitmap(colorMap).getScaled previewBitmapScale
    .blur previewBitmapBlur

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

    merge
      version:    version
      colorMap:   sbdGradients bitmap
      new Vibrant(imageDataClampedArray).rgbs
