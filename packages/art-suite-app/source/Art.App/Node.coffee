{
  defineModule
  Promise
} = require 'art-standard-lib'
{ConfigRegistry} = require 'art-config'

defineModule module, class Node
  @init: (options) ->
    Promise.resolve ConfigRegistry.configure options
