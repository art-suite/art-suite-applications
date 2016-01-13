{
  inspect, log
  isNumber, isPlainObject, isPlainArray, isString, isFunction
  stringToNumberArray
  BaseObject
} = require 'art.foundation'

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

