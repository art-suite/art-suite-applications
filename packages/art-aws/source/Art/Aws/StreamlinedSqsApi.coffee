{log, findUrlRegExp, object, present, urlJoin, merge} = require 'art-standard-lib'
{config} = require './Config'

module.exports = class StreamlinedSqsApi

  @normalizeQueueUrl: normalizeQueueUrl = (queue, options) ->
    queue ||= options?.queue ? options?.queueUrl ? config?.sqs?.queue ? config?.sqs?.queueUrl
    if queue && findUrlRegExp.test queue
      queue
    else
      queueUrlPrefix = options?.queueUrlPrefix ? config?.sqs?.queueUrlPrefix
      throw new Error "queueUrlPrefix && queue OR queueUrl required" unless present(queueUrlPrefix) && present queue
      urlJoin queueUrlPrefix, queue.replace /[^-_a-zA-Z0-9]/g, '-'

  doesntStartLowercase = /^[^a-z]/
  removeLowerCaseParams = (params) ->
    object params,
      when: (v, k) -> doesntStartLowercase.test k

  @sqsCommands:
    # IN:
    #   name: QueueName (String)
    #   visibilityTimeout: seconds (Number)
    # OUT: queueUrl (string)
    createQueue:
      preprocess: (params, options) ->
        {name, visibilityTimeout} = params
        merge removeLowerCaseParams(params),
          QueueName: name
          Attributes: merge params.Attributes,
            VisibilityTimeout: visibilityTimeout

      postprocess: ({QueueUrl}) -> QueueUrl

    sendMessage:
      preprocess: (params, options) ->
        {body, queue, delaySeconds, deduplicationId, groupId} = params

        merge removeLowerCaseParams(params),
          QueueUrl:               normalizeQueueUrl queue, options
          MessageBody:            JSON.stringify body
          DelaySeconds:           delaySeconds
          MessageDeduplicationId: deduplicationId
          MessageGroupId:         groupId

      postprocess: (data) ->
        {MessageId} = data
        merge data, id: MessageId

    receiveMessage:
      preprocess: (params, options) ->
        {queue, visibilityTimeout, wait, limit} = params

        merge removeLowerCaseParams(params),
          QueueUrl:               normalizeQueueUrl queue, options
          MaxNumberOfMessages:    limit
          VisibilityTimeout:      visibilityTimeout # note: you can set a queue-wide default
          WaitTimeSeconds:        wait ? 5

      postprocess: (data) ->
        {Messages} = data
        for message in Messages || []
          {MessageId, Body, ReceiptHandle} = message
          body = try
            JSON.parse Body
          catch
            Body
          merge message,
            id: MessageId
            body: body
            receiptHandle: ReceiptHandle

    deleteMessage:
      preprocess: (params, options) ->
        {receiptHandle, queue} = params
        merge removeLowerCaseParams(params),
          QueueUrl:       normalizeQueueUrl queue, options
          ReceiptHandle:  receiptHandle

    listQueues:
      preprocess: (params, options) ->
        {QueueNamePrefix} = params
        merge removeLowerCaseParams(params),
          prefix: QueueNamePrefix

      postprocess: ({QueueUrls}) -> QueueUrls

    purgeQueue:
      preprocess: (params, options) ->
        merge removeLowerCaseParams(params),
          QueueUrl: normalizeQueueUrl params.queue, options
