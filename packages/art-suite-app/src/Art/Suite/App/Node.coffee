{
  defineModule
  ConfigRegistry
} = require 'art-foundation'

defineModule module, class Node
  @init: (options) -> ConfigRegistry.configure options
