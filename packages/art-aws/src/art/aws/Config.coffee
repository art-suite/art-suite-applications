{merge, select, newObjectFromEach, mergeInto} = require 'art-foundation'

module.exports = class Config
  @config: configured: false

  ###
  IN: config: {}
    EXAMPLE:
      credentials:
        accessKeyId:      'blahblah'
        secretAccessKey:  'blahblah'
      region:             'us-east-1'

      s3Buckets:
        tempBucket:       'my-name'

      dynamoDb:
        endpoint:         'http://localhost:8081'
  ###
  @configure: (config) =>
    AWS.config.credentials = config.credentials
    AWS.config.region      = config.region

    mergeInto @config,
      select config, "region", "credentials"
      dynamoDb: merge
        accessKeyId:      config.credentials.accessKeyId
        secretAccessKey:  config.credentials.secretAccessKey
        region:           config.region
        maxRetries:       5
        config.dynamoDb

      s3Buckets: newObjectFromEach config.s3Buckets || {}, (id) -> {id}

      configured: true