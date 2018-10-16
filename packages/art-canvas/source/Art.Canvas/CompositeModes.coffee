{object, w, dashCase, lowerCamelCase} = require 'art-standard-lib'
module.exports = class CompositeModes
  @compositeModeMap:
    ###
    NEW - October 2018
    The HTMLCanvas composite mode naming just isn't intutive to me

    Goals:
    - cover the core 8 "alpha" composite modes
    - support all the offical named modes
    - don't be confusing with the offical named modes
    - use "source" and "target" - target is just so much more format-friendly; plus it's shorter

    Scheme:
      [color-operation][alpha-operation]

      color-operations:
        sourceTop:      colorBlend source, target
        targetTop:      colorBlend target, source

      alpha-operation:
        union:          pixel-set-union:                        1 - (1 - a.alpha) * (1 - b.alpha)
        intersection:   pixel-set-intersection:                 target.alpha * source.alpha
        inTarget:       use-target-pixel-set:                   target.alpha
        inSource:       use-source-pixel-set:                   source.alpha
        withoutSource:  pixel-set-subtraction(target - source): target.alpha * (1 - source.alpha)
        withoutTarget:  pixel-set-subtraction(source - target): source.alpha * (1 - target.alpha)

    Def'n:
      alphaBlend: (a, b)                  -> 1 - (1 - a.alpha) * (1 - b.alpha)
      colorBlend: (topPixel, bottomPixel) -> rgb(topPixel) * alpha.alpha + rgb(bottomPixel) * (1 - alpha.alpha)

      blend: (topPixel, bottomPixel) ->
        rgb:    colorBlend topPixel, bottomPixel
        alpha:  alphaBlend topPixel, bottomPixel
    ###
    sourceTopUnion:         "source-over"       # blend source, target
    sourceTopInTarget:      "source-atop"       # alpha: target,                color: colorBlend source, target
    sourceTopIntersection:  "source-in"         # alpha: target * source,       color: colorBlend source, target
    sourceWithoutTarget:    "source-out"        # alpha: source * (1 - target), color: source
    targetTopUnion:         "destination-over"  # blend target, source
    targetTopInSource:      "destination-atop"  # alpha: source,                color: colorBlend target, source
    targetTopIntersection:  "destination-in"    # alpha: target * source,       color: colorBlend source, target
    targetWithoutSource:    "destination-out"   # alpha: target * (1 - source), color: target

    normal:                 "source-over"

    # DEPRICATED
    alphaMask:        "destination-in"   # use: targetTopIntersection
    targetAlphaMask:  "source-in"        # use: sourceTopIntersection
    inverseAlphaMask: "destination-out"  # use: targetWithoutSource
    destOver:         "destination-over" # use: targetTopUnion
    add:              "lighter"          # use: lighter
    replace:          "copy"             # use: copy
    # sourcein / sourceIn: "source-atop" # Ooops! I had this for a while, and renaming the standard HTMLCanvas terms with different syntax was just a bad idea!

  @htmlCanvasCompositeModes: w "
    sourceIn
    sourceOut
    sourceOver
    sourceAtop
    destinationOver
    destinationIn
    destinationOut
    destinationAtop
    copy
    lighter
    xor

    screen
    darken
    multiply
    overlay
    lighten
    colorBurn
    colorDodge
    hardLight
    softLight
    difference
    exclusion
    hue
    saturation
    color
    luminosity
    "

  @artCanvasCoreCompositeModes: Object.keys @compositeModeMap

  for mode in @htmlCanvasCompositeModes
    @compositeModeMap[mode] = dashCase mode

  for k of Object.keys @compositeModeMap
    @compositeModeMap[dashCase k] =
    @compositeModeMap[lowerCamelCase k] =
    @compositeModeMap[k]

  # DEPRIATED
  @artToCanvasCompositeModeMap: @compositeModeMap
