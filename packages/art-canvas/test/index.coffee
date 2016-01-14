
ArtMocha = require "art.foundation/src/art/dev_tools/test/mocha"
# require 'art.foundation/src/art/dev_tools/test/art_chai'
# require "./tests/art/canvas/asset_loader"

ArtMocha.run ({assert})->

  # suite "My.Test.Suite", ->
  #   test "my test", ->
  #     assert.equal 1, 2

  self.testAssetRoot = "/test/assets"
  require './tests'
# mocha.run()
