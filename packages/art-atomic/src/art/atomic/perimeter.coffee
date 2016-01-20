# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# NOTE: Point should implement the same API as Rectangle.
# Such methods should work as-if implemented like this:
#    method: (args...) -> new Rectangle(0, 0, @w, @h).method args...

Foundation = require 'art-foundation'
AtomicBase = require './base'
Point      = require './point'
{
  log
  inspect
  floatEq
  isPlainObject
  isString
} = Foundation
{point} = Point

module.exports = class Perimeter extends AtomicBase
  @perimeter: perimeter = (a, b, c, d) ->
    # just return if a already a Point
    return a if a instanceof Perimeter
    if isString(a) && p = namedPerimeters[a]
      return p

    return perimeter0 if !b? && (floatEq a, 0) || !a

    new Perimeter a, b, c, d

  _initFields: ->
    @left = @right = @top = @bottom = 0

  _initFromObject: (obj) ->
    @_initFields()
    @left =    (obj.left   || 0) + (obj.l || 0) + (obj.h || 0) + (obj.horizontal || 0)
    @right =   (obj.right  || 0) + (obj.r || 0) + (obj.h || 0) + (obj.horizontal || 0)
    @top =     (obj.top    || 0) + (obj.t || 0) + (obj.v || 0) + (obj.vertical || 0)
    @bottom =  (obj.bottom || 0) + (obj.b || 0) + (obj.v || 0) + (obj.vertical || 0)

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

  @namedPerimeters: namedPerimeters =
    perimeter0:             perimeter0 = Object.freeze new Perimeter 0

  for k, v of @namedPerimeters
    @[k] = v

  toArray: -> [@left, @right, @top, @bottom]
  toString: toString = -> "[#{@toArray().join ', '}]"
  toJson: toString

  getInspectedString: -> "perimeter(#{@toArray().join ', '})"

  @getter
    width: -> @left + @right
    height: -> @top + @bottom

  toObject: ->
    left:   @left
    right:  @right
    top:    @top
    bottom: @bottom

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

