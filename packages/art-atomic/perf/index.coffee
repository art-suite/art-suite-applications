{Mocha, Perf} = require "art-testbench"
self.benchmark = Perf.benchmark

require '../'
require "art-testbench/testing"
.init
  synchronous: true
  defineTests: -> require './perfs'
