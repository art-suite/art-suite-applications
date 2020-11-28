{
  defineModule
  log
} = require 'art-standard-lib'
{
  isPoint
  rect
  Matrix: {transform1D}
} = require 'art-atomic'

defineModule module, class Tools
  @transformAndRoundOutRectangle: (where, r) ->

    if isPoint where
      {left, right, bottom, top} = r
      {x, y} = where

      left   = Math.floor  left     + x
      right  = Math.ceil   right    + x
      top    = Math.floor  top      + y
      bottom = Math.ceil   bottom   + y

      rect(
        left
        top
        right - left
        bottom - top
      )

    else if where
      where.transformBoundingRect r, true
    else
      r.roundOut()
