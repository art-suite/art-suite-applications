Vibrant    = require './Vibrant'

{log, object, merge} = require 'art-foundation'

{rgb256Color, rgbColor, point, Matrix} = require 'art-atomic'
{Bitmap} = require 'art-canvas'

getColorMap = (bitmap) ->
  b = bitmap.getMipmap s = point 3
  final = bitmap.newBitmap s
  final.drawBitmap Matrix.scale(s.div b.size), b

  for r, i in pd = final.imageData.data by 4
    rgb256Color r, pd[i + 1], pd[i + 2]

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

  mipmapSize: mipmapSize = 64

  ###
  IN: imageData - a 1D RGBA pixel array

    Example:

    context = canvas.getContext '2d'
    imageData = context.getImageData 0, 0, canvas.width, canvas.height
    imageDataBuffer = imageData.data.buffer

    log extractColors imageDataBuffer
  ###
  extractColors: (bitmap) ->
    bitmap = bitmap.getMipmap mipmapSize
    imageDataClampedArray = bitmap.imageData.data

    merge
      version:    version.split(".")[0] | 0
      colorMap:   getColorMap bitmap
      new Vibrant(imageDataClampedArray).colors
