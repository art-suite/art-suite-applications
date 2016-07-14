unless self.AWS
  throw new Error """
    please include AWS:

    clientSide: require 'art-aws/AwsMinAppClientSideSdk'
    serverSide: require 'aws-sdk'
    """
module.exports =
  config: AWS.config
