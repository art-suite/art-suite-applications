{
  defineModule
  Promise
} = require 'art-standard-lib'
{configure} = require 'art-config'

defineModule module, class Node
  @init: (options) ->
    Promise.resolve configure options
