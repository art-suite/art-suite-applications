{present, pathJoin} = require 'art-standard-lib'
{config} = require './Config'

module.exports = class StreamlinedSqsApi

  @normalizeQueueUrl: normalizeQueueUrl = (queue) ->
    {queueUrlPrefix} = config
    throw new Error "queueUrlPrefix required" unless present queueUrlPrefix
    pathJoin queueUrlPrefix, queue.replace /[^-_a-zA-Z0-9]/g, '-'

  @preprocessSqsCommand:
    sendMessage: (params) ->
      {body, queue, delaySeconds, deduplicationId, groupId} = params

      merge params,
        QueueUrl:               normalizeQueueUrl queue
        MessageBody:            body
        DelaySeconds:           delaySeconds
        MessageDeduplicationId: deduplicationId
        MessageGroupId:         groupId

    receiveMessage: (params) ->
      {queue, visibilityTimeout, wait, limit} = params

      merge params,
        QueueUrl:               normalizeQueueUrl queue
        MaxNumberOfMessages:    limit
        VisibilityTimeout:      visibilityTimeout # note: you can set a queue-wide default
        WaitTimeSeconds:        wait ? 5

    deleteMessage: (params) ->
      {receiptHandle, queue} = params
      merge params,
        QueueUrl:       normalizeQueueUrl queue
        ReceiptHandle:  receiptHandle

    listQueues: (params) ->
      {QueueNamePrefix} = params
      merge params, prefix: QueueNamePrefix

  @postprocessSqsCommand:
    sendMessage: (data) ->
      {MessageId} = data
      merge data, id: MessageId

    receiveMessage: (data) ->
      {Messages} = data
      merge data,
        messages: for message in messages
          {MessageId, Body, ReceiptHandle} = message
          merge message,
            id: MessageId
            body: Body
            receiptHandle: ReceiptHandle

    deleteMessage: (data) -> data

    listQueues: ({QueueUrls}) -> QueueUrls
