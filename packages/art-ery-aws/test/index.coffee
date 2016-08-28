{Mocha} = require "art-foundation/dev_tools/test"

{log} = require 'art-foundation'
global.AWS = require 'aws-sdk'
AWS.config.region = 'us-west-2'
AWS.config.endpoint = "http://localhost:8081"
{config} = require 'art-aws'
config.dynamoDb =
  accessKeyId:    'thisIsSomeInvalidKey'
  secretAccessKey:'anEquallyInvalidSecret!'
  region:         'us-east-1'
  endpoint:       'http://localhost:8081'
  maxRetries:     5

Mocha.run ({assert})->
  self.testAssetRoot = "/test/assets"
  require './tests'
