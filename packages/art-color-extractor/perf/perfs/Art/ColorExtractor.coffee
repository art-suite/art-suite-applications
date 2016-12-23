{extractColors, generatePreviewBitmap, mipmapSize} = Neptune.Art.ColorExtractor

{log, toPlainObjects, w, array, object, isPlainObject, isPlainArray, isNumber, merge} = require 'art-foundation'
{Bitmap} = require 'art-canvas'
{Matrix, point, rgbColor} = require 'art-atomic'

{extractColors, generatePreviewBitmap} = Neptune.Art.ColorExtractor

module.exports = suite: ->
  bitmap = null
  colorInfo = null
  suiteSetup ->
    Assets.load "8mpSunset.jpg"
    .then (_bitmap) ->
      bitmap = _bitmap
      colorInfo = extractColors bitmap
      previewBitmap = generatePreviewBitmap colorInfo

      mipmap =
        mipmap:        m = bitmap.getMipmap mipmapSize
        size:          m.size
        colorInfo:     mmCi = extractColors m
        previewBitmap: generatePreviewBitmap mmCi

      log setup: {bitmap, colorInfo, previewBitmap, mipmap}

  benchmark "bitmap.mipmap", -> bitmap.getMipmap mipmapSize
  benchmark "extractColors bitmap", -> extractColors bitmap
  benchmark "generatePreviewBitmap", -> generatePreviewBitmap colorInfo