# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# NOTE: Point should implement the same API as Rectangle.
# Such methods should work as-if implemented like this:
#    method: (args...) -> new Rectangle(0, 0, @w, @h).method args...

AtomicBase = require './Base'
Point      = require './Point'
{
  log
  inspect
  floatEq
  isPlainObject
  isString
  min
} = require 'art-standard-lib'
{point} = Point
{rect} = require './Rectangle'

module.exports = class Perimeter extends AtomicBase
  @defineAtomicClass fieldNames: "left right top bottom"
  @isPerimeter: isPerimeter = (v) -> v?.constructor == Perimeter

  @perimeter: perimeter = (a, b, c, d) ->
    # just return if a already a Point
    return a if isPerimeter a
    if isString(a) && p = namedPerimeters[a]
      return p

    return perimeter0 if !b? && (floatEq a, 0) || !a

    new Perimeter a, b, c, d

  _initFields: ->
    @left = @right = @top = @bottom = 0

  _initFromObject: (obj) ->
    @_init(
      (obj.left   || 0) + (obj.l || 0) + (obj.h || 0) + (obj.horizontal || 0)
      (obj.right  || 0) + (obj.r || 0) + (obj.h || 0) + (obj.horizontal || 0)
      (obj.top    || 0) + (obj.t || 0) + (obj.v || 0) + (obj.vertical || 0)
      (obj.bottom || 0) + (obj.b || 0) + (obj.v || 0) + (obj.vertical || 0)
    )

  _init: (a, b, c, d) ->
    @_initFields()
    argLength = if a?
      if b?
        if c?
          if d? then 4
          else 3
        else 2
      else 1
    else 0

    switch argLength
      when 0 then @left = @right = @top = @bottom = 0
      when 1 then @left = @right = @top = @bottom = a
      when 2 then @left = @right = a; @top = @bottom = b
      when 4 then @left = a; @right = b; @top = c; @bottom = d
      else throw new Error "invalid number of arguments: #{inspect arguments}"

  @getter
    exportedValue: ->
      {left, right, top, bottom} = @
      if (left == right) && (left == top) && (left == bottom)
        left
      else
        out = {}
        if left == right
          out.h = left if left != 0
        else
          out.left = left if left != 0
          out.right = right if right !=0
        if top == bottom
          out.v = top if top != 0
        else
          out.top = top if top != 0
          out.bottom = bottom if bottom != 0
    width: -> @left + @right
    height: -> @top + @bottom
    w: -> @left + @right
    h: -> @top + @bottom
    needsTranslation: -> @left != 0 || @top != 0

  subtractedFromSize: (size) ->
    w = @getWidth()
    h = @getHeight()

    if floatEq(w, 0) && floatEq(h, 0)
      size
    else
      point size.x - w, size.y - h

  addedToSize: (size) ->
    w = @getWidth()
    h = @getHeight()

    if floatEq(w, 0) && floatEq(h, 0)
      size
    else
      point size.x + w, size.y + h

  minWH: (maxW, maxH) ->
    out = @with(
      min @left,    maxW
      min @right,   maxW
      min @top,     maxH
      min @bottom,  maxH
    )
    # if out != @ && out.eq @
    #   log "WAT#{@eq out.left, out.right, out.top, out.bottom}"
    out

  ###
  Named Instances
  ###
  @namedPerimeters: namedPerimeters =
    perimeter0: perimeter0 = (new Perimeter 0).freeze()

  for k, v of @namedPerimeters
    @[k] = v

  pad: (rectangle) ->
    {left:x, top:y, w, h} = rectangle
    {left, right, top, bottom} = @
    rectangle.withRect(
      x + left
      y + top
      w - left - right
      h - top  - bottom
    )

  # translate: (rectangle) ->
  #   {x, y, w, h} = rectangle
  #   {left, top} = @
  #   rectangle.with(
  #     x + left
  #     y + top
  #     w
  #     h
  #   )

