{object, clone, w, dashCase, lowerCamelCase, merge, log} = require 'art-standard-lib'
module.exports = class CompositeModes
  @artCanvasCoreCompositeModeMap:
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
      alphaUnion: (a, b)                  -> 1 - (1 - a.alpha) * (1 - b.alpha)
      colorBlend: (topPixel, bottomPixel) -> rgb(topPixel) * alpha.alpha + rgb(bottomPixel) * (1 - alpha.alpha)

      blend: (topPixel, bottomPixel) ->
        rgb:    colorBlend topPixel, bottomPixel
        alpha:  alphaUnion topPixel, bottomPixel
    ###
    sourceTopUnion:         "source-over"       # alpha: alphaUnion,            color: colorBlend source, target
    sourceTopInTarget:      "source-atop"       # alpha: target,                color: colorBlend source, target
    sourceTopIntersection:  "source-in"         # alpha: target * source,       color: source
    sourceWithoutTarget:    "source-out"        # alpha: source * (1 - target), color: source
    targetTopUnion:         "destination-over"  # alpha: alphaUnion,            color: colorBlend target, source
    targetTopInSource:      "destination-atop"  # alpha: source,                color: colorBlend target, source
    targetTopIntersection:  "destination-in"    # alpha: target * source,       color: target
    targetWithoutSource:    "destination-out"   # alpha: target * (1 - source), color: target
    add:                    "lighter"
    replace:                "copy"

    # preferred aliases
    normal:                 "source-over"
    sourceTop:              "source-over"
    targetTop:              "destination-over"

  @artCanvasCoreCompositeModes: Object.keys @artCanvasCoreCompositeModeMap

  @compositeModeMap: merge @artCanvasCoreCompositeModeMap,

    # DEPRICATED
    alphaMask:        "destination-in"   # use: targetTopIntersection
    targetAlphaMask:  "source-in"        # use: sourceTopIntersection
    inverseAlphaMask: "destination-out"  # use: targetWithoutSource
    destOver:         "destination-over" # use: targetTopUnion
    # sourcein / sourceIn: "source-atop" # Ooops! I had this for a while, and renaming the standard HTMLCanvas terms with different syntax was just a bad idea!

  @htmlCanvasCompositeModes: w "
    source-in
    source-out
    source-over
    source-atop
    destination-over
    destination-in
    destination-out
    destination-atop
    copy
    lighter
    xor

    screen
    darken
    multiply
    overlay
    lighten
    color-burn
    color-dodge
    hard-light
    soft-light
    difference
    exclusion
    hue
    saturation
    color
    luminosity
    "

  @normalizedCompositeModeMap:
    "source-atop":        "sourceTopInTarget"
    "source-in":          "sourceTopIntersection"
    "source-out":         "sourceWithoutTarget"
    "destination-atop":   "targetTopInSource"
    "destination-in":     "targetTopIntersection"
    "destination-out":    "targetWithoutSource"
    "lighter":            "add"
    "copy":               "replace"
    "source-over":        "normal"
    "destination-over":   "targetTop"

  for mode in @htmlCanvasCompositeModes
    @compositeModeMap[lowerCamelCase mode] = htmlCanvasName = dashCase mode
    @compositeModeMap[htmlCanvasName] = htmlCanvasName

    @normalizedCompositeModeMap[htmlCanvasName] ?= htmlCanvasName

  for k, v of @compositeModeMap
    @normalizedCompositeModeMap[k] = @normalizedCompositeModeMap[v]

  # DEPRIATED
  @artToCanvasCompositeModeMap: @compositeModeMap
