{
  merge
  Promise
  each
} = require 'art-standard-lib'
{BaseClass} = require 'art-class-system'

{sqsCommands} = require './StreamlinedSqsApi'
Config = require "./Config"

module.exports = class Sqs extends BaseClass
  @singletonClass()

  constructor: (options = {}) ->
    @_awsSqs = new AWS.SQS merge @sqsConfig = Config.getNormalizedConfig "sqs", options

  emptyObject = {}
  identifyFunction = (a) -> a
  each sqsCommands,
    ({preprocess = identifyFunction, postprocess = identifyFunction}, command) =>
      @::[command] = (params) ->
        Promise.withCallback (callback) =>
          @_awsSqs[command] preprocess(params ? emptyObject), (err, data) ->
            callback err, postprocess data ? emptyObject
