{extractColors} = Neptune.Art.ColorExtractor

{log, toPlainObjects, w, array, object, isPlainObject, isPlainArray, isNumber, merge} = require 'art-foundation'
{Bitmap} = require 'art-canvas'

files = w "
  boy2.jpg
  rose.jpg
  boy1.jpg
  cockpit.jpg
  colors.jpg
  dessert.jpg
  leaves.jpg
  science.jpg
  "

{point, rgbColor} = require 'art-atomic'

mediaColorToColor = (mc) ->
  return null unless mc
  rgbColor(
    mc[0] / 255
    mc[1] / 255
    mc[2] / 255
    if mc[3]? then mc[3] else 1
  )

colorInfoToMediaColor = (colorInfo) ->
  if rgb = colorInfo?.gradify?.dominantColor
    mediaColorToColor rgb
  else "#444"
    # colorInfo?.vibrant?.Vibrant

atomify = (o) ->
  if isPlainObject o
    object o, (v) -> atomify v

  else if isPlainArray o
    if (o.length == 3 || o.length == 4) && isNumber o[1]
      mediaColorToColor o
    else
      array o, (v) -> atomify v
  else o

gradientAngles =
  0:    from: point("bottomLeft"),   to: point "topLeft"
  90:   from: point("bottomLeft"),   to: point "bottomRight"
  180:  from: point("topRight"  ),   to: point "bottomRight"
  270:  from: point("topRight"  ),   to: point "topLeft"

colorInfoToDrawRectangles = (colorInfo) ->
  if gradients = colorInfo?.gradify?.gradients
    firstGradient = true
    for [angle, colorA, colorB] in gradients by -1
      fromTo = gradientAngles[angle]
      colorA = mediaColorToColor colorA
      colorB = mediaColorToColor colorB

      if firstGradient
        firstGradient = false
        if colorA.a == 0
          colorA = colorInfoToMediaColor colorInfo
        else if colorB.a == 0
          colorB = colorInfoToMediaColor colorInfo

      if colorA.eq colorB
        color: colorA
      else
        merge fromTo, colors: [colorA, colorB]
  else
    [color: colorInfoToMediaColor colorInfo]

drawGradients = (bitmap, colorInfo) ->
  {size} = bitmap
  for drawRectangleOptions in a = colorInfoToDrawRectangles colorInfo
    options = merge options, drawRectangleOptions
    bitmap.drawRectangle null, size, merge drawRectangleOptions,
      to: options.to?.mul size
      from: options.from?.mul size
  log toPlainObjects a

module.exports = suite: ->

  array files, (file) ->
    test file, ->
      Bitmap.get testAssetRoot + "/" + file
      .then (bitmap) ->
        colors = atomify colorInfo = extractColors bitmap.imageDataBuffer, bitmap.size
        gradientBitmap = new Bitmap bitmap.size
        drawGradients gradientBitmap, colorInfo

        log {
          colors
          bitmaps: [bitmap, gradientBitmap]
          file
        }

