Foundation = require 'art-foundation'
{log, floatEq, min, max, isNumber, isPlainObject, float32Eq0, bound} = Foundation

module.exports = class Paths
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
    return rectangle context, r unless radius

    if isPlainObject radius
      {tl, tr, bl, br, bottomLeft, bottomRight, topLeft, topRight, top, bottom, left, right} = radius
      tr ?= topRight    ? top ? right
      tl ?= topLeft     ? top ? left
      br ?= bottomRight ? bottom ? right
      bl ?= bottomLeft  ? bottom ? left
    else
      tl = tr = bl = br = radius

    return rectangle context, r if float32Eq0(tl) && float32Eq0(tr) && float32Eq0(bl) && float32Eq0(br)

    {w, h} = r
    w = max 0, w
    h = max 0, h

    if floatEq(w, h) && isNumber(radius) && radius >= halfW = w/2
      # perfect circle
      {hCenter, vCenter} = r
      context.arc hCenter, vCenter, halfW, 0, Math.PI*2, true
      return

    # rounded rectangle
    maxRadius = min w/2, h/2
    bl = bound 0, bl, maxRadius
    br = bound 0, br, maxRadius
    tl = bound 0, tl, maxRadius
    tr = bound 0, tr, maxRadius
    {left, right, top, bottom} = r

    context.moveTo left  ,          top    + tl
    context.arcTo  left  ,          top   ,                 left   + tl,      top   ,           tl
    context.lineTo right  - tr,     top
    context.arcTo  right ,          top   ,                 right ,           top    + tr,      tr
    context.lineTo right ,          bottom - br
    context.arcTo  right ,          bottom,                 right  - br,      bottom,           br
    context.lineTo left   + bl,     bottom
    context.arcTo  left  ,          bottom,                 left  ,           bottom - bl,      bl

    context.closePath()

  @curriedRoundedRectangle: (r, radius) ->
    (context) ->
      roundedRectangle context, r, radius
