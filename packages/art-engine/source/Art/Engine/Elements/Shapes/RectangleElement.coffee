Atomic = require 'art-atomic'
Text = require 'art-text'
ShadowableElement = require '../ShadowableElement'
{Paths} = require '@art-suite/art-canvas'
{pureMerge, float32Eq0, log, AtomElement, defineModule, isPlainObject, isNumber} = require 'art-standard-lib'
{rectanglePath} = Paths

defineModule module, class RectangleElement extends ShadowableElement

  @drawProperty
    radius:
      default:  0
      validate: (v) -> !v || isNumber(v) || isPlainObject(v)
      preprocess: (v) -> v || 0

  # override so Outline child can be "filled"
  fillShape: (target, elementToTargetMatrix, options) ->
    options.radius = @_radius
    options.color ||= @_color
    target.drawRectangle elementToTargetMatrix, @getPaddedArea(), options

  # override so Outline child can draw the outline
  strokeShape: (target, elementToTargetMatrix, options) ->
    options.radius = @_radius
    options.color ||= @_color
    target.strokeRectangle elementToTargetMatrix, @getPaddedArea(), options

  #####################
  # Custom Clipping
  # override to support rounded-rectangle clipping
  #####################
  clipOptions = radius: 0
  _drawWithClipping: (clipArea, target, elementToTargetMatrix)->
    if float32Eq0 @_radius
      super
    else
      clipOptions.radius = @_radius
      lastClippingInfo = target.openClipping rectanglePath, elementToTargetMatrix, @paddedArea, clipOptions
      @_drawChildren target, elementToTargetMatrix
      target.closeClipping lastClippingInfo

  @getter
    hasCustomClipping: -> @_radius > 0
