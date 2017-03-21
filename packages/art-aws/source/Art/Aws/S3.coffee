RestClient = require 'art-rest-client'
{log, present, defineModule, parseUrl, peek, Promise,merge} = require 'art-standard-lib'

# npm querystring doesn't implement escape and unescape, which aws4 needs
QuertyString = require 'querystring'
QuertyString.escape ||= encodeURIComponent
QuertyString.unescape ||= decodeURIComponent

{config} = Config = require "./Config"

{BaseClass} = require 'art-class-system'

defineModule module, class S3 extends BaseClass

    ###
    OUT: Promise -> {location, response}
    REJECTED: Promise -> {event, request}
    ###
    @put: ({bucket, objectName, data, onProgress, mimeType, headers = {}}) =>
      bucket = @_normalizeBucket bucket
      throw new Error "no bucket!" unless bucket

      host = "#{bucket}.s3.amazonaws.com"
      path = "/#{objectName}"
      url = "https://#{host}#{path}"
      headers["Content-Type"] = mimeType if present mimeType

      RestClient.put url, data, headers: headers, onProgress: onProgress
      .then (response) ->
        location: url
        response: response

    @_normalizeBucket: (bucket) -> config.s3Buckets[bucket] || bucket
    @_denormalizeBucket: (bucket) ->
      for k, v of config.s3Buckets
        if bucket == v
          return k
      bucket

    @classGetter
      s3: -> @_s3 ||= new AWS.S3 Config.getNormalizedConfig "S3"

    @parseS3Url: (url) =>
      {host, pathName} = parseUrl url
      key: peek pathName.split "/"
      bucket: @_denormalizeBucket host.split(".")[0]

    @putSdk: ({bucket, key, body}) ->
      Promise.withCallback (callback) => @getS3().putObject
        Bucket: @_normalizeBucket bucket
        Key: key
        Body: body
        callback

    @copy: ({key, toBucket, fromBucket, params}) ->
      toBucket = @_normalizeBucket toBucket
      fromBucket = @_normalizeBucket fromBucket

      # http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#copyObject-property
      Promise.withCallback (callback) =>
        @getS3().copyObject merge(
            params,
            CopySource: "#{fromBucket}/#{key}"
            Bucket: toBucket
            Key: key
            MetadataDirective: "COPY"
          ),
          callback
      .then (res) ->
        copyObjectResult: res
        url: "https://#{toBucket}.s3.amazonaws.com/#{key}"
