require '../index'
ArtMocha = require "art-foundation/src/art/dev_tools/test/mocha"

ArtMocha.run ({assert})->
  require './tests'
