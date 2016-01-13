# https://developer.mozilla.org/en-US/docs/HTML/Canvas
# NOTE: Point should implement the same API as Rectangle.
# Such methods should work as-if implemented like this:
#    method: (args...) -> new Rectangle(0, 0, @w, @h).method args...

console.log "Including Art.Atomic.Base"
{
  inspect, log, isNumber, isPlainObject, isPlainArray, isString, isFunction, stringToNumberArray
  BaseObject
} = require 'art.foundation'
console.log "Including Art.Atomic.Base", BaseObject

module.exports = class Base extends BaseObject

  _initFromString: (string) ->
    @_init stringToNumberArray(string)...

  constructor: (a, b, c, d, e, f, g) ->
    super
    if isPlainArray a       then @_init a...
    else if isString a      then @_initFromString a
    else if isPlainObject a then @_initFromObject a
    else if a? && !isNumber(a) && !(a instanceof Base) && isFunction(a.toString) then @_initFromString a.toString()
    else                    @_init a, b, c, d, e, f, g

  compare: (b) ->
    return 0 if @eq b
    return -1 if @lte b
    return 1 if @gte b
    NaN

