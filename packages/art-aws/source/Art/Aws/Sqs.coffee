{
  merge
  Promise
  each
} = require 'art-standard-lib'
{BaseClass} = require 'art-class-system'

{sqsCommands, normalizeQueueUrl} = require './StreamlinedSqsApi'
Config = require "./Config"

module.exports = class Sqs extends BaseClass
  @singletonClass()

  ###
  Option defaults are read out of Art.Aws.config.sqs, but can be overridden here:
  options:
    # direct url to the queue
    queueUrl:
      Example: https://sqs.us-east-1.amazonaws.com/465118458885/ZoMigrationDev

    queueUrlPrefix: null
      Example: https://sqs.us-east-1.amazonaws.com/123456789

    # joined with queueUrlPrefix
    queue: null
      Example: "ZoMigrationDev"

    accessKeyId:
    secretAccessKey:
  ###
  constructor: (options = {}) ->
    @_awsSqs = new AWS.SQS merge @sqsConfig = Config.getNormalizedConfig "sqs", options

  @getter
    queueUrl: -> normalizeQueueUrl null, @sqsConfig

  emptyObject = {}
  identifyFunction = (a) -> a
  each sqsCommands,
    ({preprocess = identifyFunction, postprocess = identifyFunction}, command) =>
      @::[command] = (params) ->
        Promise.withCallback (callback) =>
          @_awsSqs[command] preprocess(params ? emptyObject, @sqsConfig), (err, data) ->
            callback err, postprocess data ? emptyObject
