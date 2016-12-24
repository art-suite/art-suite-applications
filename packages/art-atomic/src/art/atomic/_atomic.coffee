Color      = require './color'
Point      = require './point'
Rectangle  = require './rectangle'
Matrix     = require './matrix'
Perimeter  = require './perimeter'

module.exports = [
  [Color,     "newColor", "color", "hslColor", "rgb256Color", "rgbColor", "colorNames", "colorNamesMap"]
  [Point,     "point", "point0", "point1", "isPoint", "pointWithAspectRatioAndArea"]
  [Rectangle, "rect", "nothing", "everything"]
  [Matrix,    "matrix", "identityMatrix"]
  [Perimeter, "perimeter", "perimeter0"]

  package: _package = require "art-atomic/package.json"
  version: _package.version
]
