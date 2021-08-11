Foundation = require '@art-suite/art-foundation'
Atomic = require 'art-atomic'
Canvas = require '@art-suite/art-canvas'
ShadowableElement = require '../ShadowableElement'

{log, createWithPostCreate} = Foundation
{GradientFillStyle} = Canvas

# can be a gradient fill or a solid-color fill
# if the @gradient property is set (including indirectly by setting the @colors property), then it is a gradient
# Otherwise, the @color property is used and @from and @to properties are ignored.
module.exports = createWithPostCreate class FillElement extends ShadowableElement

  @virtualProperty
    preFilteredBaseDrawArea: (pending) ->
      @getParent(pending).getPreFilteredBaseDrawArea pending

  getNormalizedCanvasShadow: (pending) ->
    if @getShadow pending
      super
    else
      @getParent(pending)?.getNormalizedCanvasShadow pending

  ###
  NOTE:

  _prepareDrawOptions replaces values, even with null ones.
  Hence, we prepare two separate draw optons and the merge them.
  ###
  _drawOptionsTemp = {}
  drawBasic: (target, elementToTargetMatrix, compositeMode, opacity) ->
    @_parent._prepareDrawOptions? @_drawOptions, compositeMode, opacity
    @_prepareDrawOptions _drawOptionsTemp, compositeMode, opacity
    @_drawOptions[k] = v for k, v of _drawOptionsTemp when v
    @_parent.fillShape target, elementToTargetMatrix, @_drawOptions
