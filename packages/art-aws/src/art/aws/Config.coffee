{merge, defineModule, select, newObjectFromEach, mergeInto, Configurable} = require 'art-foundation'

defineModule module, class Config extends Configurable
  @defaults
    credentials:
      accessKeyId:      'blah'
      secretAccessKey:  'blah'

    region:             'us-east-1'

    # map from local-names to S3 bucket names
    s3Buckets:  {}

    # options:
    #   endpoint:         'http://localhost:8081'
    #   accessKeyId:      default: Config.credentials.accessKeyId
    #   secretAccessKey:  default: Config.credentials.secretAccessKey
    #   region:           default: Config.region
    #   maxRetries:       5
    dynamoDb:
      maxRetries: 5


  @getNormalizedDynamoDbConfig: =>
    @getNormalizedConfig "dynamoDb"

  @getNormalizedConfig: (forService) =>
    merge
      accessKeyId:      @config.credentials.accessKeyId
      secretAccessKey:  @config.credentials.secretAccessKey
      region:           @config.region
      maxRetries:       5
      @config[forService]
