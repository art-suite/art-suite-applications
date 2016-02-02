{Mocha, Perf} = require "art-foundation/dev_tools/test"
self.benchmark = Perf.benchmark

Mocha.run ({assert})->
  require './perfs'
