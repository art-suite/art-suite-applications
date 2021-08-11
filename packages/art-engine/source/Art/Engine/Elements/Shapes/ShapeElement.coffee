Foundation = require '@art-suite/art-foundation'
Atomic = require 'art-atomic'
Text = require 'art-text'
ShadowableElement = require '../ShadowableElement'
{pureMerge, isFunction, createWithPostCreate} = Foundation

module.exports = createWithPostCreate class ShapeElement extends ShadowableElement

  constructor: ->
    super
    @_lastPathFunction = null
    @_curriedPathFunction = null

  @drawProperty
    fillRule: default: "nonzero", validate: (r) -> r == "nonzero" || r == "evenodd"

    path:
      default: (context, size) ->
        # example path (a rectangle)
        {w, h} = size
        context.beginPath()
        context.moveTo 0, 0
        context.lineTo 0, h
        context.lineTo w, h
        context.lineTo w, 0
        context.lineTo 0, 0
        context.closePath()

      validate: (f) -> isFunction f

  drawBasic: (target, elementToTargetMatrix, compositeMode, opacity) ->
    @_prepareDrawOptions @_drawOptions, compositeMode, opacity
    @fillShape target, elementToTargetMatrix, @_drawOptions

  # override so Outline child can be "filled"
  fillShape: (target, elementToTargetMatrix, options) ->
    options.color ||= @_color
    options.fillRule = @_fillRule
    target.fillShape elementToTargetMatrix, options, @_path, @paddedSize

  # override so Outline child can draw the outline
  strokeShape: (target, elementToTargetMatrix, options) ->
    options.color ||= @_color
    target.strokeShape elementToTargetMatrix, options, @_path, paddedSize
