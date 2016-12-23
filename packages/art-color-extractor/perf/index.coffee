global.Assets = require '../test/assets'

require '../'
require "art-foundation/benchmark"
.run -> require './perfs'
