{log, findUrlRegExp, object, present, pathJoin, merge} = require 'art-standard-lib'
{config} = require './Config'

module.exports = class StreamlinedSqsApi

  @normalizeQueueUrl: normalizeQueueUrl = (queue = config?.sqs?.queueUrl) ->
    if findUrlRegExp.test queue
      queue
    else
      {queueUrlPrefix} = config
      throw new Error "queue (config.Art.Aws.sqs.queueUrl) or queueUrlPrefix required" unless present queueUrlPrefix
      pathJoin queueUrlPrefix, queue.replace /[^-_a-zA-Z0-9]/g, '-'

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
      preprocess: (params) ->
        {name, visibilityTimeout} = params
        merge removeLowerCaseParams(params),
          QueueName: name
          Attributes: merge params.Attributes,
            VisibilityTimeout: visibilityTimeout

      postprocess: ({QueueUrl}) -> QueueUrl

    sendMessage:
      preprocess: (params) ->
        {body, queue, delaySeconds, deduplicationId, groupId} = params

        merge removeLowerCaseParams(params),
          QueueUrl:               normalizeQueueUrl queue
          MessageBody:            body
          DelaySeconds:           delaySeconds
          MessageDeduplicationId: deduplicationId
          MessageGroupId:         groupId

      postprocess: (data) ->
        {MessageId} = data
        merge data, id: MessageId

    receiveMessage:
      preprocess: (params) ->
        {queue, visibilityTimeout, wait, limit} = params

        merge removeLowerCaseParams(params),
          QueueUrl:               normalizeQueueUrl queue
          MaxNumberOfMessages:    limit
          VisibilityTimeout:      visibilityTimeout # note: you can set a queue-wide default
          WaitTimeSeconds:        wait ? 5

      postprocess: (data) ->
        {Messages} = data
        for message in Messages || []
          {MessageId, Body, ReceiptHandle} = message
          merge message,
            id: MessageId
            body: Body
            receiptHandle: ReceiptHandle

    deleteMessage:
      preprocess: (params) ->
        {receiptHandle, queue} = params
        merge removeLowerCaseParams(params),
          QueueUrl:       normalizeQueueUrl queue
          ReceiptHandle:  receiptHandle

    listQueues:
      preprocess: (params) ->
        {QueueNamePrefix} = params
        merge removeLowerCaseParams(params),
          prefix: QueueNamePrefix

      postprocess: ({QueueUrls}) -> QueueUrls

    purgeQueue:
      preprocess: (params) ->
        merge removeLowerCaseParams(params),
          QueueUrl: normalizeQueueUrl params.queue
