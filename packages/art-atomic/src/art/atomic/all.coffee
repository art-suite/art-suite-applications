define [
  'art.foundation'
  "./namespace"
  './color'
  './matrix'
  './point'
  './rectangle'
  './perimeter'
  ], (Foundation, Atomic, Color, Matrix, Point, Rectangle, Perimeter) ->
    {createAllClass, select} = Foundation

    createAllClass Atomic,
      select Perimeter, "perimeter", "perimeter0"
      select Point, "point", "point0", "point1", "isPoint"
      select Color, "color", "hslColor", "colorNames", "colorNamesMap"
      select Matrix, "matrix", "identityMatrix"
      select Rectangle, "rect", "nothing", "everything"

    class All extends Atomic

