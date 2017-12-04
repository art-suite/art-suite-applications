{
  w
  merge
  Promise
  each
} = require 'art-standard-lib'
{BaseClass} = require 'art-class-system'

{
  preprocessSqsCommand
  postprocessSqsCommand
} = require './StreamlinedSqsApi'
Config = require "./Config"

module.exports = class Sqs extends BaseClass
  @singletonClass()

  constructor: (options = {}) ->
    @_awsSqs = new AWS.SQS merge Config.getNormalizedConfig "sqs", options

  identifyFunction = (a) -> a
  each w("sendMessage receiveMessage deleteMessage listQueues"),
    (command) =>
      preprocess  = preprocessSqsCommand[command]  || identifyFunction
      postprocess = postprocessSqsCommand[command] || identifyFunction
      @::[command] = (params) ->
        Promise.withCallback (callback) =>
          @_awsSqs[command] preprocess(params), (err, data) ->
            callback err, postprocess data

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
