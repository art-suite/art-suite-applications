###
SBD TODO

Bluring transparencies has errors. Repro:
  clear background to: color(1,0,0,.5)
  drawRectangle color(0,1,0,1) over a sub-area of the bitmap
  blur

The problem (I think) is transparent colors have equal weight as non-transparent colors.

...

I need to test bluring on the edge of the bitmap. I'm not convinced it works right.

...

Possible speedup and simplification:

One solution which may be faster overall is to reserve one line of pixels in memory plus
the blur radius amount of pixels on each side. Those pixel colors should be repetitions of the edge colors.
Then we can blur over that range with reduced tests in our inner loop.
It looks like "slice" allows us to quickly get a subsection of an ArrayBuffer. That will work for all lines
except the first and last one(s). Just slice and then overwrite the first and end colors with the edge-colors.

UInt8Array .subarray and .set should make moving the pixles to and from pretty fast. The only slow part will
be filling the edge pixels in.

###

###

StackBlur - a fast almost Gaussian Blur For Canvas

Version:  0.5
Author:   Mario Klingemann
Contact:  mario@quasimondo.com
Website:  http://www.quasimondo.com/StackBlurForCanvas
Twitter:  @quasimondo

In case you find this class useful - especially in commercial projects -
I am not totally unhappy for a small donation to my PayPal account
mario@quasimondo.de

Or support me on flattr:
https://flattr.com/thing/72791/StackBlur-a-fast-almost-Gaussian-Blur-Effect-for-CanvasJavascript

Copyright (c) 2010 Mario Klingemann

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
###

define [
  "./namespace"
  'art.atomic'
  'art.foundation'
  "./bitmap_base"
  ], (Canvas, Atomic, Foundation) ->
  {point, matrix, rect, color} = Atomic

  inspect   = Foundation.Inspect.inspect
  nextTick  = Foundation.nextTick

  class BlurStack
    constructor: ->
      @r = @g = @b = @a = 0
      @next = null

  class Canvas.StackBlur extends Foundation.BaseObject
    @blur: (bitmap, radius) -> (new Canvas.StackBlur).blur bitmap, radius
    @blurRGB: (bitmap, radius) -> (new Canvas.StackBlur).blurRGB bitmap, radius
    @blurAlpha: (bitmap, radius) -> (new Canvas.StackBlur).blurAlpha bitmap, radius
    @blurInvertedAlpha: (bitmap, radius) -> (new Canvas.StackBlur).blurInvertedAlpha bitmap, radius

    blur: (bitmap, radius, targetBitmap) ->
      targetBitmap ||= bitmap
      imageData = bitmap.getImageData()
      pixels = imageData.data
      radius = radius + .5 | 0
      @stackBlurCanvasRGBA pixels, bitmap.size.w, bitmap.size.h, radius if radius > 0
      targetBitmap.putImageData imageData

    blurRGB: (bitmap, radius, targetBitmap) ->
      targetBitmap ||= bitmap
      imageData = bitmap.getImageData()
      pixels = imageData.data
      radius = radius + .5 | 0
      @stackBlurCanvasRGB pixels, bitmap.size.w, bitmap.size.h, radius if radius > 0
      targetBitmap.putImageData imageData

    blurAlpha: (bitmap, radius, targetBitmap) ->
      targetBitmap ||= bitmap
      imageData = bitmap.getImageData()
      pixels = imageData.data
      radius = radius + .5 | 0
      @stackBlurCanvasAlpha pixels, bitmap.size.w, bitmap.size.h, radius if radius > 0
      targetBitmap.putImageData imageData

    blurInvertedAlpha: (bitmap, radius, targetBitmap) ->
      targetBitmap ||= bitmap
      imageData = bitmap.getImageData()
      pixels = imageData.data
      radius = radius + .5 | 0
      @invertAlpha pixels, bitmap.size.area
      @stackBlurCanvasAlpha pixels, bitmap.size.w, bitmap.size.h, radius if radius > 0
      targetBitmap.putImageData imageData

    invertAlpha: (pixels, numPixels) ->
      i = 0
      end = numPixels*4-4
      end8 = end - (end%8)
      while i <= end
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
        pixels[i+3] = 255 - pixels[i+3];i+=4
      while i <= end
        pixels[i+3] = 255 - pixels[i+3];i+=4

    createStack: (radius) ->
      @stackStart = new BlurStack()
      stack = @stackStart

      for i in [1.. 2 * radius] by 1
        stack = stack.next = new BlurStack()
        @stackEnd = stack if i is radius + 1

      stack.next = @stackStart

    rgbaPass: (radius, pixels, outterStep, outterEnd, innerStep, innerEndDelta) ->
      radiusPlus1 = radius + 1

      # stackWeight is the sum of the area under a 2D pyramid with height radiusPlus1
      stackWeight = radiusPlus1 * radiusPlus1
      oneOverStackWeight = 1 / stackWeight

      # firstPixelSumWeight a slice of the stackWeight pyramid - it is all left columns plus the center column
      firstPixelSumWeight = (stackWeight + radiusPlus1) / 2

      stackStart = @stackStart
      stackEnd = @stackEnd
      outterPos = 0
      while outterPos <= outterEnd

        ###################
        # prime stack
        ###################
        r_in_sum = g_in_sum = b_in_sum = a_in_sum = 0

        pr = pixels[outterPos    ]
        pg = pixels[outterPos + 1]
        pb = pixels[outterPos + 2]
        pa = pixels[outterPos + 3]
        if pa < 255
          weight = pa / 255
          pr *= weight
          pg *= weight
          pb *= weight

        r_out_sum = radiusPlus1 * pr
        g_out_sum = radiusPlus1 * pg
        b_out_sum = radiusPlus1 * pb
        a_out_sum = radiusPlus1 * pa

        r_sum = firstPixelSumWeight * pr
        g_sum = firstPixelSumWeight * pg
        b_sum = firstPixelSumWeight * pb
        a_sum = firstPixelSumWeight * pa

        stackIn = stackStart
        for i in [0..radius] by 1
          stackIn.r = pr
          stackIn.g = pg
          stackIn.b = pb
          stackIn.a = pa
          stackIn = stackIn.next

        innerEnd = outterPos + innerEndDelta
        rbs = radius
        innerRadiusEnd = outterPos + radius * innerStep
        innerPos = outterPos + innerStep
        while innerPos <= innerRadiusEnd
          readPos = innerPos
          readPos = innerEnd if innerPos > innerEnd

          pr = pixels[readPos    ]
          pg = pixels[readPos + 1]
          pb = pixels[readPos + 2]
          pa = pixels[readPos + 3]
          if pa < 255
            weight = pa / 255
            pr *= weight
            pg *= weight
            pb *= weight

          r_in_sum += stackIn.r = pr
          g_in_sum += stackIn.g = pg
          b_in_sum += stackIn.b = pb
          a_in_sum += stackIn.a = pa

          r_sum += pr * rbs
          g_sum += pg * rbs
          b_sum += pb * rbs
          a_sum += pa * rbs
          rbs--

          stackIn = stackIn.next
          innerPos += innerStep

        stackOut = stackEnd

        ###################
        # blur pixels
        ###################

        readPosOffset = radiusPlus1 * innerStep
        innerPos = outterPos
        while innerPos <= innerEnd

          # write pixels
          pixels[innerPos + 3] = pa = a_sum * oneOverStackWeight

          unless pa is 0
            pa = oneOverStackWeight * 255 / pa
            pixels[innerPos    ] = r_sum * pa
            pixels[innerPos + 1] = g_sum * pa
            pixels[innerPos + 2] = b_sum * pa
          else
            pixels[innerPos] = pixels[innerPos + 1] = pixels[innerPos + 2] = 0

          # update sums for pixel in stackOut
          r_sum -= r_out_sum
          g_sum -= g_out_sum
          b_sum -= b_out_sum
          a_sum -= a_out_sum

          r_out_sum -= stackIn.r
          g_out_sum -= stackIn.g
          b_out_sum -= stackIn.b
          a_out_sum -= stackIn.a

          # update sums for pixel adding to stackIn
          readPos = innerPos + readPosOffset
          readPos = innerEnd if readPos > innerEnd

          pr = pixels[readPos    ]
          pg = pixels[readPos + 1]
          pb = pixels[readPos + 2]
          pa = pixels[readPos + 3]
          if pa < 255
            weight = pa / 255
            pr *= weight
            pg *= weight
            pb *= weight

          r_in_sum += stackIn.r = pr
          g_in_sum += stackIn.g = pg
          b_in_sum += stackIn.b = pb
          a_in_sum += stackIn.a = pa

          r_sum += r_in_sum
          g_sum += g_in_sum
          b_sum += b_in_sum
          a_sum += a_in_sum

          r_out_sum += pr = stackOut.r
          g_out_sum += pg = stackOut.g
          b_out_sum += pb = stackOut.b
          a_out_sum += pa = stackOut.a

          r_in_sum -= pr
          g_in_sum -= pg
          b_in_sum -= pb
          a_in_sum -= pa

          stackIn = stackIn.next
          stackOut = stackOut.next
          innerPos += innerStep
        outterPos += outterStep

    rgbPass: (radius, pixels, outterStep, outterEnd, innerStep, innerEndDelta) ->
      radiusPlus1 = radius + 1

      # stackWeight is the sum of the area under a 2D pyramid with height radiusPlus1
      stackWeight = radiusPlus1 * radiusPlus1
      oneOverStackWeight = 1 / stackWeight

      # firstPixelSumWeight a slice of the stackWeight pyramid - it is all left columns plus the center column
      firstPixelSumWeight = (stackWeight + radiusPlus1) / 2

      stackStart = @stackStart
      stackEnd = @stackEnd
      outterPos = 0
      while outterPos <= outterEnd

        ###################
        # prime stack
        ###################
        r_in_sum = g_in_sum = b_in_sum = 0

        pr = pixels[outterPos    ]
        pg = pixels[outterPos + 1]
        pb = pixels[outterPos + 2]

        r_out_sum = radiusPlus1 * pr
        g_out_sum = radiusPlus1 * pg
        b_out_sum = radiusPlus1 * pb

        r_sum = firstPixelSumWeight * pr
        g_sum = firstPixelSumWeight * pg
        b_sum = firstPixelSumWeight * pb

        stackIn = stackStart
        for i in [0..radius] by 1
          stackIn.r = pr
          stackIn.g = pg
          stackIn.b = pb
          stackIn = stackIn.next

        innerEnd = outterPos + innerEndDelta
        rbs = radius
        innerRadiusEnd = outterPos + radius * innerStep
        innerPos = outterPos + innerStep
        while innerPos <= innerRadiusEnd
          readPos = innerPos
          readPos = innerEnd if innerPos > innerEnd

          pr = pixels[readPos    ]
          pg = pixels[readPos + 1]
          pb = pixels[readPos + 2]

          r_in_sum += stackIn.r = pr
          g_in_sum += stackIn.g = pg
          b_in_sum += stackIn.b = pb

          r_sum += pr * rbs
          g_sum += pg * rbs
          b_sum += pb * rbs
          rbs--

          stackIn = stackIn.next
          innerPos += innerStep

        stackOut = stackEnd

        ###################
        # blur pixels
        ###################

        readPosOffset = radiusPlus1 * innerStep
        innerPos = outterPos
        while innerPos <= innerEnd

          # write pixels
          pixels[innerPos    ] = r_sum * oneOverStackWeight
          pixels[innerPos + 1] = g_sum * oneOverStackWeight
          pixels[innerPos + 2] = b_sum * oneOverStackWeight

          # update sums for pixel in stackOut
          r_sum -= r_out_sum
          g_sum -= g_out_sum
          b_sum -= b_out_sum

          r_out_sum -= stackIn.r
          g_out_sum -= stackIn.g
          b_out_sum -= stackIn.b

          # update sums for pixel adding to stackIn
          readPos = innerPos + readPosOffset
          readPos = innerEnd if readPos > innerEnd

          pr = pixels[readPos    ]
          pg = pixels[readPos + 1]
          pb = pixels[readPos + 2]

          r_in_sum += stackIn.r = pr
          g_in_sum += stackIn.g = pg
          b_in_sum += stackIn.b = pb

          r_sum += r_in_sum
          g_sum += g_in_sum
          b_sum += b_in_sum

          r_out_sum += pr = stackOut.r
          g_out_sum += pg = stackOut.g
          b_out_sum += pb = stackOut.b

          r_in_sum -= pr
          g_in_sum -= pg
          b_in_sum -= pb

          stackIn = stackIn.next
          stackOut = stackOut.next
          innerPos += innerStep
        outterPos += outterStep

    alphaPass: (radius, pixels, outterStep, outterEnd, innerStep, innerEndDelta) ->
      radiusPlus1 = radius + 1

      # stackWeight is the sum of the area under a 2D pyramid with height radiusPlus1
      stackWeight = radiusPlus1 * radiusPlus1
      oneOverStackWeight = 1 / stackWeight

      # firstPixelSumWeight a slice of the stackWeight pyramid - it is all left columns plus the center column
      firstPixelSumWeight = (stackWeight + radiusPlus1) / 2

      stackStart = @stackStart
      stackEnd = @stackEnd
      outterPos = 3
      outterEnd += 3
      while outterPos <= outterEnd

        ###################
        # prime stack
        ###################
        a_in_sum = 0
        pa = pixels[outterPos]
        a_out_sum = radiusPlus1 * pa
        a_sum = firstPixelSumWeight * pa

        stackIn = stackStart
        for i in [0..radius] by 1
          stackIn.a = pa
          stackIn = stackIn.next

        innerEnd = outterPos + innerEndDelta
        rbs = radius
        innerRadiusEnd = outterPos + radius * innerStep
        innerPos = outterPos + innerStep
        while innerPos <= innerRadiusEnd
          readPos = innerPos
          readPos = innerEnd if innerPos > innerEnd

          pa = pixels[readPos]
          a_in_sum += stackIn.a = pa
          a_sum += pa * rbs
          rbs--

          stackIn = stackIn.next
          innerPos += innerStep

        stackOut = stackEnd

        ###################
        # blur pixels
        ###################

        readPosOffset = radiusPlus1 * innerStep
        innerPos = outterPos
        while innerPos <= innerEnd

          # write pixels
          pixels[innerPos] = a_sum * oneOverStackWeight

          # update sums for pixel in stackOut
          a_sum -= a_out_sum
          a_out_sum -= stackIn.a

          # update sums for pixel adding to stackIn
          readPos = innerPos + readPosOffset
          readPos = innerEnd if readPos > innerEnd

          a_in_sum += stackIn.a = pixels[readPos]
          a_sum += a_in_sum
          a_out_sum += pa = stackOut.a
          a_in_sum -= pa

          stackIn = stackIn.next
          stackOut = stackOut.next
          innerPos += innerStep
        outterPos += outterStep

    stackBlurCanvasRGBA: (pixels, width, height, radius) ->
      return if radius <= 0

      @createStack radius

      @rgbaPass radius, pixels, 4, (width - 1) * 4, width * 4, (height - 1) * width * 4
      @rgbaPass radius, pixels, width * 4, (height - 1) * width * 4, 4, (width - 1) * 4

    stackBlurCanvasAlpha: (pixels, width, height, radius) ->
      return if radius <= 0

      @createStack radius
      @alphaPass radius, pixels, 4, (width - 1) * 4, width * 4, (height - 1) * width * 4
      @alphaPass radius, pixels, width * 4, (height - 1) * width * 4, 4, (width - 1) * 4

    stackBlurCanvasRGB: (pixels, width, height, radius) ->
      return if radius <= 0

      @createStack radius
      @rgbPass radius, pixels, 4, (width - 1) * 4, width * 4, (height - 1) * width * 4
      @rgbPass radius, pixels, width * 4, (height - 1) * width * 4, 4, (width - 1) * 4
