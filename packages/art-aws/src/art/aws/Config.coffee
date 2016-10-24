{merge, select, newObjectFromEach, mergeInto} = require 'art-foundation'

module.exports = class Config
  @config: configured: false

  ###
  IN: config: {}
    EXAMPLE:
      credentials:
        accessKeyId:      'AKIAI6A2ZKODQMKSV34A'
        secretAccessKey:  'ZG/vWdmnOJ0bWaKPjSZKr8n6WtxWrcvu0Km9G9NA'
      region:             'us-east-1'

      s3Buckets:
        tempBucket:       'oz-dev-expiring-uploads'

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

      s3Buckets: newObjectFromEach config.s3buckets || {}, (id) -> {id}

      configured: true