###
 * Color Thief v2.0
 * by Lokesh Dhakar - http:#www.lokeshdhakar.com
 *
 * License
 * -------
 * Creative Commons Attribution 2.5 License:
 * http:#creativecommons.org/licenses/by/2.5/
 *
 * Thanks
 * ------
 * Nick Rabinowitz - For creating quantize.js.
 * John Schulz - For clean up and optimization. @JFSIII
 * Nathan Spady - For adding drag and drop support to the demo page.
###
quantize = require 'quantize'
{defineModule, log} = require 'art-foundation'

defineModule module, class ColorThief

  ###
  IN:
    pixels
    colorCount: (default = 10) number of colors to return
    quality:    (default = 10) 1 == highest quality, slowest

  SBD true??? BUGGY: Function does not always return the requested amount of colors. It can be +/- 2.
  ###
  getPalette: (pixels, colorCount = 10, quality = 10) ->

    pixelCount = pixels.length / 4

    # Store the RGB values in an array format suitable for quantize function
    pixelArray = []
    for i in [0...pixelCount] by quality
      offset = i * 4
      r = pixels[offset + 0]
      g = pixels[offset + 1]
      b = pixels[offset + 2]
      a = pixels[offset + 3]

      # If pixel is mostly opaque and not white
      # if a >= 125 && !(r > 250 && g > 250 && b > 250)
      pixelArray.push [r, g, b]

    quantize pixelArray, colorCount
    .palette()
