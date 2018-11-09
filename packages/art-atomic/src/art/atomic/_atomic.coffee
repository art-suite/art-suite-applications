Color      = require './color'
Point      = require './point'
Rectangle  = require './rectangle'
Matrix     = require './matrix'
Perimeter  = require './perimeter'

module.exports = [
  [Color,     "isColor",    "rgbColor",     "newColor", "color", "hslColor", "rgb256Color", "colorNames", "colorNamesMap", "hsl2Rgb"]
  [Point,     "isPoint",    "point",        "point0", "point1", "pointWithAspectRatioAndArea"]
  [Rectangle, "isRect",     "rect",         "nothing", "everything"]
  [Matrix,    "isMatrix",   "matrix",       "identityMatrix"]
  [Perimeter, "perimeter",  "isPerimeter",  "perimeter0"]

  package: _package = require "../../../package.json"
  version: _package.version
]
