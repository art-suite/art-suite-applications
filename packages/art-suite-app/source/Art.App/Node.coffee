{
  defineModule
  Promise
  merge
} = require 'art-standard-lib'
{configure} = require 'art-config'

defineModule module, merge(
  require 'art-suite/Node'
  init: (options) -> Promise.resolve configure options
)