Color      = require './Color'
Point      = require './Point'
Rectangle  = require './Rectangle'
Matrix     = require './Matrix'
Perimeter  = require './Perimeter'

{compactFlatten} = require 'art-standard-lib'

module.exports = [
  compactFlatten [Color,      "isColor",      "rgbColor",   "newColor", "color", "hslColor", "rgb256Color", "colorNames", "colorNamesMap", "hsl2Rgb"]
  compactFlatten [Rectangle,  "isRect",       "rect",       "nothing", "everything"]
  compactFlatten [Matrix,     "isMatrix",     "matrix",     "identityMatrix"]
  compactFlatten [Perimeter,  "isPerimeter",  "perimeter",  "perimeter0"]
  compactFlatten [Point,      "isPoint",      "point",      "pointWithAspectRatioAndArea", Object.keys Point.namedPoints]

  package: _package = require "../../../package.json"
  version: _package.version
]
