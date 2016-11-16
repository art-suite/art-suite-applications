{
  defineModule
  ConfigRegistry
  Promise
} = require 'art-foundation'

defineModule module, class Node
  @init: (options) ->
    Promise.resolve ConfigRegistry.configure options
