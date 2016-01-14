define [
  'art.foundation'
  ], (Foundation) ->
  {log, floatEq, min} = Foundation

  class Paths
    @rectangle: rectangle = (context, r) ->
      {left, right, top, bottom} = r

      context.moveTo left , top
      context.lineTo right, top
      context.lineTo right, bottom
      context.lineTo left , bottom
      context.closePath()

    @line: (context, fromPoint, toPoint) ->
      context.moveTo fromPoint.x, fromPoint.y
      context.lineTo toPoint.x, toPoint.y

    @roundedRectangle: roundedRectangle = (context, r, radius) ->
      return rectangle context, r unless radius? && radius > 0
      {w, h} = r

      if floatEq(w, h) && radius >= halfW = w/2
        # perfect circle
        {hCenter, vCenter} = r
        context.arc hCenter, vCenter, halfW, 0, Math.PI*2, true

      else
        # rounded rectangle
        radius = min radius, w/2, h/2
        {left, right, top, bottom} = r

        context.moveTo left  ,          top    + radius
        context.arcTo  left  ,          top   ,                 left   + radius,  top   ,           radius
        context.lineTo right  - radius, top
        context.arcTo  right ,          top   ,                 right ,           top    + radius,  radius
        context.lineTo right ,          bottom - radius
        context.arcTo  right ,          bottom,                 right  - radius,  bottom,           radius
        context.lineTo left   + radius, bottom
        context.arcTo  left  ,          bottom,                 left  ,           bottom - radius,  radius

        context.closePath()

    @curriedRoundedRectangle: (r, radius) ->
      (context) ->
        roundedRectangle context, r, radius
