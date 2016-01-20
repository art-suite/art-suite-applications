Foundation = require 'art-foundation'
Atomic     = require "./namespace"
Color      = require './color'
Matrix     = require './matrix'
Point      = require './point'
Rectangle  = require './rectangle'
Perimeter  = require './perimeter'

{createAllClass, select} = Foundation

createAllClass Atomic,
  select Perimeter, "perimeter", "perimeter0"
  select Point, "point", "point0", "point1", "isPoint"
  select Color, "color", "hslColor", "colorNames", "colorNamesMap"
  select Matrix, "matrix", "identityMatrix"
  select Rectangle, "rect", "nothing", "everything"
