{extractColors, generatePreviewBitmap, mipmapSize} = Neptune.Art.ColorExtractor

{log, toPlainObjects, w, array, object, isPlainObject, colorRegExp, isPlainArray, isNumber, merge} = require 'art-foundation'
{Bitmap} = require 'art-canvas'
{hslColor, Color, Matrix, point, rgbColor} = require 'art-atomic'

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
  0:    from: point("bottomLeft"),   to: point("topLeft"    )
  90:   from: point("bottomLeft"),   to: point("bottomRight")
  180:  from: point("topRight"  ),   to: point("bottomRight")
  270:  from: point("topRight"  ),   to: point("topLeft"    )

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

drawGradients = (bitmap, {preview}) ->
  {size} = bitmap
  for drawRectangleOptions in preview
    {to, from} = options = merge options, drawRectangleOptions
    bitmap.drawRectangle null, size, merge drawRectangleOptions,
      to:   to    && point(to).mul size
      from: from  && point(from).mul size

module.exports = suite: ->
  log Assets.files
  test "perceptualLightness", ->
    factor = 16
    groups = []
    for color in Color.colorNames#w "#f00 #0f0 #00f"
      {perceptualLightness} = c = rgbColor color
      luma = Math.round perceptualLightness * factor
      (groups[luma] ||= []).push c #[
        # c
        # c2 = rgbColor c.perceptualLightness
        # c.perceptualLightness
        # c2.perceptualLightness
      # ]
    groups = array groups, (group, luma) ->
      (group || []).sort (a, b) -> a.s - b.s
    log groups

  array Assets.files, (file) ->
    test file, ->
      Assets.load file
      .then (bitmap) ->
        {version, colors, colorMap} = colorInfo = extractColors bitmap

        assert.isNumber version
        assert.isPlainArray colorMap
        assert.eq colorMap.length, 9

        assert.eq true, color instanceof Color for color in colorMap
        assert.eq true, color instanceof Color for color in colors

        previewBitmap = generatePreviewBitmap colorInfo

        log "#{file}": {
          bitmap
          colorInfo
          previewBitmap
          mipmap:         bitmap.getMipmap mipmapSize
          upscale:        previewBitmap.scale point area:point(700).div(previewBitmap.size).area, aspectRatio: bitmap.size.aspectRatio
          json: JSON.stringify toPlainObjects colorInfo
        }

