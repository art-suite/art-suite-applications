{defineModule, merge, log} = require 'art-foundation'
{rgbColor, rgb256Color, point} = require 'art-atomic'

toRgbColor = ([r, g, b, a]) ->
  a *= 255 if a > 0
  rgb256Color r, g, b, a

gradientAngles =
  0:    from: point("bottomLeft"),   to: point "topLeft"
  90:   from: point("bottomLeft"),   to: point "bottomRight"
  180:  from: point("topRight"  ),   to: point "bottomRight"
  270:  from: point("topRight"  ),   to: point "topLeft"

defineModule module, class GradifyHelper

  @gradientsToDrawRectangleParams: ({rawGradients, rawColor}) ->
    rawColor = toRgbColor rawColor
    firstGradient = true
    for [angle, colorA, colorB] in rawGradients by -1
      fromTo = gradientAngles[angle]
      colorA = toRgbColor colorA
      colorB = toRgbColor colorB

      if firstGradient
        firstGradient = false
        if colorA.a == 0
          colorA = rawColor
        else if colorB.a == 0
          colorB = rawColor

      if colorA.eq colorB
        color: colorA
      else
        merge fromTo, colors: [colorA, colorB]