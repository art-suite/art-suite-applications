{isRect} = require 'art-atomic'
{log, floatEq, min, max, isNumber, isPlainObject, isFunction, float32Eq0, bound} = require 'art-standard-lib'

###
Path functions all take the same signature:
  context: the HTML5 2d-canvas context
  pathArea: a point or rectangle
    ALL PATHS SHOULD BE 100% INSIDE
    THE AREA SPECIFIEDY BY 'SIZE'
    Paths should scale to just fit within
    the pathArea specified.

  options: optional options-object
    Example: rectanglePath takes a 'radius' parameter

EXCEPTION: linePath - is special for now
###
module.exports = class Paths

  @linePath: (context, fromPoint, toPoint) ->
    context.moveTo fromPoint.x, fromPoint.y
    context.lineTo toPoint.x, toPoint.y

  # TODO: options for pie-charts
  @circlePath: (context, pathArea, options) ->
    {hCenter, vCenter, w, h} = pathArea
    radius = min(w, h) / 2
    context.arc hCenter, vCenter, radius, 0, Math.PI*2, true
    context.closePath()
  @circlePath.obtuse = true

  ###
  options:
    radius:
      number >= 0
      OR
      object:
        With one or more number props:
          tl, tr, bl, br, bottomLeft, bottomRight, topLeft, topRight, top, bottom, left, right
        Each specifies one or two corners to set the radius for
  ###
  @rectanglePath: (context, pathArea, options) ->
    roundedRectanglePath context, pathArea, options?.radius
  @rectanglePath.obtuse = true

  @roundedRectanglePath: roundedRectanglePath = (context, r, radius) ->
    unless radius? && !float32Eq0 radius
      {left, right, top, bottom} = r

      context.moveTo left , top
      context.lineTo right, top
      context.lineTo right, bottom
      context.lineTo left , bottom
      context.closePath()
    else

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

  @roundedRectanglePath.obtuse = true

  # DEPRICATED
  @roundedRectangle: (a, b, c) ->
    log.error "DEPRIACTED - use roundedRectanglePath"
    roundedRectanglePath a, b, c

  # DEPRICATED
  @rectangle: rectangle = (context, r) ->
    log.error "DEPRIACTED - use rectanglePath"
    {left, right, top, bottom} = r

    context.moveTo left , top
    context.lineTo right, top
    context.lineTo right, bottom
    context.lineTo left , bottom
    context.closePath()

  # DEPRICATED
  @curriedRoundedRectangle: (r, radius) ->
    log.error "DEPRICATED - use roundedRectanglePath && pathOptions"
    (context) ->
      roundedRectanglePath context, r, radius
