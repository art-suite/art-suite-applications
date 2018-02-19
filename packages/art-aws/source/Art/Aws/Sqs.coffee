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

  ###
  Option defaults are read out of Art.Aws.config.sqs, but can be overridden here:
  options:
    queueUrl:
      Example: https://sqs.us-east-1.amazonaws.com/465118458885/ZoMigrationDev

    queueUrlPrefix: null
      Example: https://sqs.us-east-1.amazonaws.com/123456789

    accessKeyId:
    secretAccessKey:
  ###
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
