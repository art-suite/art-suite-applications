Foundation = require '@art-suite/art-foundation'
Atomic = require 'art-atomic'
Canvas = require '@art-suite/art-canvas'
AtomElement = require './AtomElement'
{PointLayout, PointLayoutBase} = require '../Layout'
{log, isPlainObject, min, max, createWithPostCreate, isNumber, merge} = Foundation
{rgbColor, Color, point, Point, rect, Rectangle, matrix, Matrix, point0, point1} = Atomic
{GradientFillStyle} = Canvas

{normalizeShadow} = require '../NormalizeProps'

# can be a gradient fill or a solid-color fill
# if the @gradient property is set (including indirectly by setting the @colors property), then it is a gradient
# Otherwise, the @color property is used and @from and @to properties are ignored.
module.exports = createWithPostCreate class ShadowableElement extends AtomElement
  @registerWithElementFactory: -> @ != ShadowableElement

  @getter
    cacheable: -> @getHasChildren()

  defaultOffset = new PointLayout y: 2
  noShadow =
    color: rgbColor 0,0,0,0
    blur: 0
    offset: new PointLayout 0

  @drawLayoutProperty
    shadow:
      default: null
      validate:   (v) -> !v || v == true || isPlainObject v
      # preprocess: normalizeShadow
      preprocess: (v) ->
        return null unless v
        {color, offset, blur} = v
        color = rgbColor color || "#0007"
        return null if color.a < 1/255
        offset = if offset?
          if offset instanceof PointLayoutBase
            offset
          else
            new PointLayout offset
        else
          defaultOffset

        blur = 4 unless blur?

        blur: blur
        offset: offset
        color: color

  @getter
    normalizedCanvasShadow: (pending)->
      shadow = @getShadow pending
      return null if !shadow || shadow == noShadow
      {offset} = shadow
      x = offset.layoutX @_currentSize
      y = offset.layoutY @_currentSize
      merge shadow,
        offsetX: x
        offsetY: y

  _expandRectangleByShadow: (r, pending, normalizedCanvasShadow) ->
    return r unless normalizedCanvasShadow
    {x, y, w, h} = r
    {blur, offsetX, offsetY} = normalizedCanvasShadow
    offsetX ||= 0
    offsetY ||= 0
    blur ||= 0
    blur *= 1.25 # chrome seems to blur just a tad extra
    expandLeft    = max 0, blur - offsetX
    expandTop     = max 0, blur - offsetY
    expandRight   = max 0, blur + offsetX
    expandBottom  = max 0, blur + offsetY
    r.with(
      x - expandLeft
      y - expandTop
      w + expandLeft + expandRight
      h + expandTop + expandBottom
    )

  @virtualProperty
    drawAreaPadding: (pending) -> 0
    baseDrawArea: (pending) ->
      @_expandRectangleByShadow @getPreFilteredBaseDrawArea(pending),
        pending
        @getNormalizedCanvasShadow pending

  _prepareDrawOptions: (drawOptions, compositeMode, opacity)->
    super
    drawOptions.shadow = @normalizedCanvasShadow
