{point, rect, color} = require 'art-atomic'
{inspect, log} = require 'art-foundation'
{Canvas} = Neptune.Art

exactFill = (bitmap, r, g, b, a) ->
  iData = bitmap.getImageData()
  data = iData.data
  len = data.length
  i = 0
  while i < len
    data[i++] = r
    data[i++] = g
    data[i++] = b
    data[i++] = a
  bitmap.putImageData iData

module.exports = suite: ->
  # test "StackBlurOriginal", ->
  #   bitmap = new Canvas.Bitmap point 128, 128
  #   bitmap.drawRectangle null, rect(32, 32, 64, 64), radius:32
  #   log bitmap
  #   Canvas.StackBlurOriginal.blur bitmap, 32
  #   log bitmap

  test "StackBlur", ->
    bitmap = new Canvas.Bitmap point 128, 128
    bitmap.drawRectangle null, rect(32, 32, 64, 64), radius:32
    log bitmap
    Canvas.StackBlur.blur bitmap, 32
    log bitmap

  test "StackBlur 1.5", ->
    bitmap = new Canvas.Bitmap point 128, 128
    bitmap.drawRectangle null, rect(32, 32, 64, 64), radius:32
    log bitmap
    Canvas.StackBlur.blur bitmap, 1.5
    log bitmap

  test "RGBA blur", ->

    radius = 16
    bitmap = new Canvas.Bitmap p = point 256, 256
    exactFill bitmap, 255, 0, 0, 1

    bitmap.drawRectangle null, rect(0,0,p.w,1), color:"#f70"
    bitmap.drawRectangle null, rect(0,0,1,p.h), color:"#f07"
    bitmap.drawRectangle null, rect(p.w-1,0,1,p.h), color:"#07f"
    bitmap.drawRectangle null, rect(0,p.h-1,p.w,1), color:"#70f"
    bitmap.drawRectangle null, rect(p.mul(point .125, .125), p.mul(.5)), color:"#f00", compositeMode:"add"
    bitmap.drawRectangle null, rect(p.mul(point .375, .125), p.mul(.5)), color:"#0f0", compositeMode:"add"
    bitmap.drawRectangle null, rect(p.mul(point .25, .375), p.mul(.5)), color:"#00f", compositeMode:"add"

    log bitmap
    Canvas.StackBlur.blur bitmap, radius
    log bitmap

  test "Alpha blur", ->

    radius = 16
    bitmap = new Canvas.Bitmap p = point 256, 256
    exactFill bitmap, 255, 0, 0, 1

    bitmap.drawRectangle null, rect(0,0,p.w,1), color:"#f70"
    bitmap.drawRectangle null, rect(0,0,1,p.h), color:"#f07"
    bitmap.drawRectangle null, rect(p.w-1,0,1,p.h), color:"#07f"
    bitmap.drawRectangle null, rect(0,p.h-1,p.w,1), color:"#70f"
    bitmap.drawRectangle null, rect(p.mul(point .125, .125), p.mul(.5)), color:"#f00", compositeMode:"add"
    bitmap.drawRectangle null, rect(p.mul(point .375, .125), p.mul(.5)), color:"#0f0", compositeMode:"add"
    bitmap.drawRectangle null, rect(p.mul(point .25, .375), p.mul(.5)), color:"#00f", compositeMode:"add"

    log bitmap
    Canvas.StackBlur.blurAlpha bitmap, radius
    log bitmap

  test "RGB blur", ->

    radius = 16
    bitmap = new Canvas.Bitmap p = point 256, 256
    exactFill bitmap, 0, 0, 0, 255

    bitmap.drawRectangle null, rect(0,0,p.w,1), color:"#f70"
    bitmap.drawRectangle null, rect(0,0,1,p.h), color:"#f07"
    bitmap.drawRectangle null, rect(p.w-1,0,1,p.h), color:"#07f"
    bitmap.drawRectangle null, rect(0,p.h-1,p.w,1), color:"#70f"
    bitmap.drawRectangle null, rect(p.mul(point .125, .125), p.mul(.5)), color:"#f00", compositeMode:"add"
    bitmap.drawRectangle null, rect(p.mul(point .375, .125), p.mul(.5)), color:"#0f0", compositeMode:"add"
    bitmap.drawRectangle null, rect(p.mul(point .25, .375), p.mul(.5)), color:"#00f", compositeMode:"add"

    log bitmap
    Canvas.StackBlur.blurRGB bitmap, radius
    log bitmap
