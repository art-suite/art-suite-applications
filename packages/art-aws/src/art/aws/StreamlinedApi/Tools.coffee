{
  isPlainObject, isPlainArray
  capitalize, decapitalize
} = require 'art-foundation'

module.exports = class Tools
  @deepCapitalizeAllKeys: (a) =>
    if isPlainObject a
      out = {}
      out[capitalize k] = @deepCapitalizeAllKeys v for k, v of a
      out
    else if isPlainArray a
      @deepCapitalizeAllKeys v for v in a
    else
      a

  @deepDecapitalizeAllKeys: (a) =>
    if isPlainObject a
      out = {}
      out[decapitalize k] = @deepDecapitalizeAllKeys v for k, v of a
      out
    else if isPlainArray a
      @deepDecapitalizeAllKeys v for v in a
    else
      a
