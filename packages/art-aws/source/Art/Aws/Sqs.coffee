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
    @_awsSqs = new AWS.SQS merge Config.getNormalizedConfig "sqs", options

  emptyObject = {}
  identifyFunction = (a) -> a
  each sqsCommands,
    ({preprocess = identifyFunction, postprocess = identifyFunction}, command) =>
      @::[command] = (params) ->
        Promise.withCallback (callback) =>
          @_awsSqs[command] preprocess(params ? emptyObject), (err, data) ->
            callback err, postprocess data ? emptyObject

  # sendMessage: (params) ->
  #   Promise.withCallback (callback) =>
  #     @_awsSqs.sendMessage preprocessSendMessage(params), (err, data) ->
  #       callback err, postprocessSendMessage data

  # receiveMessage: (params) ->
  #   Promise.withCallback (callback) =>
  #     @_awsSqs.receiveMessage preprocessReceiveMessage(params), (err, data) ->
  #       callback err, postprocessReceiveMessage data

  # deleteMessage: (params) ->
  #   Promise.withCallback (callback) =>
  #     @_awsSqs.deleteMessage preprocessDeleteMessage(params), (err, data) ->
  #       callback err, postprocessDeleteMessage data

  # listQueues: (params) ->
  #   Promise.withCallback (callback) =>
  #     @_awsSqs.listQueues preprocessListQueues(params), (err, data) ->
  #       callback err, postprocessListQueues data
