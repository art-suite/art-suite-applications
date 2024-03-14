RestClient = require 'art-rest-client'
{isArray, isPlainObject, upperCamelCase, lowerCamelCase, object, isString, log, present, defineModule, parseUrl, peek, Promise,merge} = require 'art-standard-lib'

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

    getBucketAndKey = (urlOrBucketKey) =>
      {bucket, key} = if isString urlOrBucketKey
        @parseS3Url urlOrBucketKey
      else
        urlOrBucketKey

      Bucket: @_normalizeBucket bucket
      Key:    key

    ###
    OUT: (NodeJs)
      acceptRanges:  "bytes"
      restore:       'ongoing-request="false", expiry-date="Fri, 08 Jun 2018 00:00:00 GMT"'
      lastModified:  2015-10-17 21:05:44 UTC
      contentLength: 1037232
      eTag:          '"6c1e52458eaeaaf5f1cd361dda121d5a"'
      contentType:   ""
      metadata:      {}
      storageClass:  "GLACIER"
      body:          {Buffer length: 1037232}

    ###
    @get: (urlOrBucketKey) =>
      log get: urlOrBucketKey
      Promise.withCallback (callback) =>
        @getS3().getObject getBucketAndKey(urlOrBucketKey), callback
      .then lowerCamelCaseProps

    @delete: (urlOrBucketKey) =>
      Promise.withCallback (callback) =>
        @getS3().deleteObject getBucketAndKey(urlOrBucketKey), callback

    @_normalizeBucket: _normalizeBucket = (bucket) -> config.s3Buckets[bucket] || bucket
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
      bucket: @_denormalizeBucket host.split(".s3.amazonaws")[0]

    @putSdk: ({bucket, key, body}) ->
      Promise.withCallback (callback) => @getS3().putObject
        Bucket: @_normalizeBucket bucket
        Key: key
        Body: body
        callback

    @copy: ({key, toBucket, fromBucket, params}) ->
      toBucket = @_normalizeBucket toBucket
      fromBucket = @_normalizeBucket fromBucket

      # log s3Copy: {key, fromBucket, toBucket}

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

    renameProps = (obj, renameAction) ->
      if isPlainObject obj
        object obj,
          key:  (v, k) -> renameAction k
          with: (v)    -> renameProps v, renameAction

      else if isArray obj
        renameProps v, renameAction for v in obj

      else
        obj

    upperCamelCaseProps = (obj) -> renameProps obj, upperCamelCase
    lowerCamelCaseProps = (obj) -> renameProps obj, lowerCamelCase

    # SEE https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#listObjectsV2-property
    # IN:       params: Same API except JavaScript standard lowerCamelCase props are also allowed
    # OUT:      promise.then -> Same API except all props are JavaScript standard lowerCamelCase
    # NOTE:     VALUES are not altered, so if AWS requires an UpperCamelCase VALUE, you must privide it (i.e. 'Bulk' not 'bulk')
    # EXAMPLE:  S3.list {bucket, startAfter, prefix}
    @list: (params) ->
      Promise.withCallback (callback) =>
        @getS3().listObjectsV2(
          upperCamelCaseProps params
          callback
        )
      .then (res) ->
        res = lowerCamelCaseProps res
        res.contents = for item in res.contents
          lowerCamelCaseProps item
        res

    # SEE: https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#restoreObject-property
    # IN:       params: Same as AWS except JavaScript standard lowerCamelCase props are allowed
    # OUT:      promise.then -> Same API except all props are JavaScript standard lowerCamelCase
    # NOTE:     VALUES are not altered, so if AWS requires an UpperCamelCase VALUE, you must privide it (i.e. 'Bulk' not 'bulk')
    # EXAMPLE:  S3.restore {} bucket, key, restoreRequest: days: 1 glacierJobParameters: tier: :Bulk
    ###
    2018-04-26
                pricing     ETA/ETC
    bulk:       $.0025/gb   5-12 hours
    standard:   $.01/gb     3-5 hours
    expedited:  $.03/gb     1-5 minutes
    ###
    @restore: (params) ->
      Promise.withCallback (callback) =>
        @getS3().restoreObject(
          upperCamelCaseProps params
          callback
        )
      .then lowerCamelCaseProps
