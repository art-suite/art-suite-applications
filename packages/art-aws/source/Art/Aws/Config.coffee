{merge, log, objectHasKeys, formattedInspect, defineModule, select, newObjectFromEach, mergeInto} = require 'art-standard-lib'
{Configurable} = require 'art-config'

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

    sqs:
      queueUrlPrefix: null  # REQUIRED if no queueUrl. Example: https://sqs.us-east-1.amazonaws.com/123456789
      # queueUrl: null      # REQIORED of no queueUrlPrefix
      # queue: null         # appended to queueUrlPrefix if no queueUrl
      # accessKeyId:
      # secretAccessKey:

  # I should really just use 'elasticsearch' everywhere...
  @awsServiceToConfigNameMap: awsServiceToConfigNameMap =
    es: "elasticsearch"

  ###
    Search order:
      @config[service].credentials
      @config[awsServiceToConfigNameMap[service]].credentials
      @config.credentials
  ###
  @getAwsCredentials: (service) =>
    @getAwsServiceConfig(service)?.credentials ||
    @config.credentials

  @getAwsServiceConfig: (service) =>
    @config[service] || @config[awsServiceToConfigNameMap[service]]

  @getNormalizedConfig: (forService, options) =>
    defaultCredentials = @getDefaultConfig().credentials
    rawServiceConfig = @getAwsServiceConfig forService

    config = merge
      accessKeyId:      @config.credentials.accessKeyId
      secretAccessKey:  @config.credentials.secretAccessKey
      region:           @config.region
      maxRetries:       5
      rawServiceConfig?.credentials
      rawServiceConfig
      options

    if config.accessKeyId == defaultCredentials.accessKeyId && !config.endpoint
      log.error """
        Art.Aws invalid configuration for #{forService}.

        Please set one of:
        - Art.Aws.credentails for connection to AWS
        - Art.Aws.#{forService}.endpoint for connection to a local server.

        #{
        if options && objectHasKeys options
          formattedInspect "Art.Aws.config":@config, options: options, "merged config": config
        else
          formattedInspect "Art.Aws.config":@config, "merged config": config
        }

        """
      throw new Error "invalid config options"

    config