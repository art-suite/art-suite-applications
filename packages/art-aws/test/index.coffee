{Mocha} = require "art-foundation/dev_tools/test"

global.AWS = require 'aws-sdk'
require '../src/art'

Mocha.run ({assert})->
  self.testAssetRoot = "/test/assets"
  require './tests'
