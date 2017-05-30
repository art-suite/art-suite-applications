{isNode} = require 'art-standard-lib'

if isNode
  # prevent webpack from including Server code
  nodeOnlyRequire = eval 'require'
  global.AWS = nodeOnlyRequire 'aws-sdk'
else
  require '../../../Client'

unless self.AWS
  throw new Error """
    Art.Aws: global.AWS required

    Please use one of the following:

      > require 'art-aws/Client'
      > require 'art-aws/Server'
    """
module.exports = [
  config: require('./Config').config
  require './DynamoDb'
  package: _package = require "art-aws/package.json"
  version: _package.version
]
