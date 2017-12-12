{
  defineModule
  mergeInto
  Promise, object, isPlainObject, deepMerge, compactFlatten, inspect
  log, merge, compare, Validator, isString, isFunction, withSort
  formattedInspect
  mergeIntoUnless
  objectWithExistingValues
  present
  isString
} = require 'art-standard-lib'

{Pipeline, KeyFieldsMixin, pipelines, UpdateAfterMixin} = require 'art-ery'
{Sqs} = ArtAws = require 'art-aws'

defineModule module, class SqsPipeline extends Pipeline
  @abstractClass()

  @getter sqs: -> Sqs.singleton

  @handlers
    sendMessage: ({body}) ->
      @sqs.sendMessage
        queue: @tableName
        body: JSON.stringify body

    # IN: request.data:
    #   visibilityTypeout: time in seconds before the job is requeued
    #   wait: time in seconds to wait for an available job before returning
    # OUT: one message
    receiveMessage: ({data}) ->
      {visibilityTimeout, wait} = data
      @sqs.receiveMessage
        queue: @tableName
        {limit: 1, visibilityTimeout, wait}
      .then (messages) -> messages[0]


    # IN: request.data:
    #   visibilityTypeout: time in seconds before the job is requeued
    #   wait: time in seconds to wait for an available job before returning
    #   limit: max number of messages to return. Default = 10 (also the max possible)
    # OUT: [messages...]
    receiveMessages: ({data}) ->
      {limit = 10, visibilityTimeout, wait} = data
      @sqs.receiveMessage
        queue: @tableName
        {limit, visibilityTimeout, wait}

    # IN: request.key is the receiptHandle
    deleteMessage: ({key}) ->
      @sqs.deleteMessage
        queue: @tableName
        receiptHandle: key
