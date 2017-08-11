Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
{Canvas} = Neptune.Art

{log} = Foundation
{point, rect} = Atomic
{Bitmap, Paths} = Canvas
{curriedRoundedRectangle} = Paths

testBitmap = (name, bitmapTest) ->
  test name, ->
    bitmap = new Bitmap point 100
    bitmap.clear "#eee"
    bitmapTest bitmap
    log name, bitmap

module.exports = suite: ->
  testBitmap "nested clipping", (bitmap)->
    r1 = rect(10, 10, 40, 80)
    r2 = rect(10, 10, 80, 40)
    bitmap.clippedTo r1, -> bitmap.clear "#ff7"
    bitmap.clippedTo r2, -> bitmap.clear "#ff7"

    bitmap.clippedTo r1, ->
      bitmap.clippedTo r2, ->
        bitmap.clear "#7ff"

  testBitmap "circular path clipping", (bitmap)->
    bitmap.clippedTo curriedRoundedRectangle(rect(10, 10, 80, 80), 1000), ->
      bitmap.clear "#ff7"

  testBitmap "rounded rectangle path clipping", (bitmap)->
    bitmap.clippedTo curriedRoundedRectangle(rect(10, 10, 80, 80), 1000), ->
      bitmap.clear "#ff7"

  testBitmap "nested path clipping", (bitmap)->
    bitmap.clippedTo curriedRoundedRectangle(rect(10, 10, 80, 80), 1000), ->
      bitmap.clear "#ff7"
      bitmap.clippedTo curriedRoundedRectangle(rect(50), 1000), ->
        bitmap.clear "#0ff"

  testBitmap "sibling clips and restoring clips inbetween", (bitmap)->
    bitmap.clippedTo rect(10, 10, 80, 80), ->
      bitmap.clear "#ff7"
      bitmap.clippedTo curriedRoundedRectangle(rect(50), 1000), ->
        bitmap.clear "#0ff"
        bitmap.drawRectangle null, rect(0, 25, 100, 50), color:"#077"

      bitmap.drawRectangle null, rect(0, 40, 100, 20), color:"#0007"

      bitmap.clippedTo curriedRoundedRectangle(rect(50, 50, 50, 50), 1000), ->
        bitmap.clear "#f0f"
        bitmap.drawRectangle null, rect(50, 75, 100, 50), color:"#707"

  testBitmap "rect path rect clipping", (bitmap)->
    bitmap.clippedTo rect(10, 10, 80, 80), ->
      bitmap.clear "#ff7"
      bitmap.clippedTo curriedRoundedRectangle(rect(50), 1000), ->
        bitmap.clear "#0ff"
        bitmap.clippedTo rect(0, 25, 100, 50), ->
          bitmap.clear "#077"


