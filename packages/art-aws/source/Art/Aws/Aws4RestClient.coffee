{objectWithout, formattedInspect, select, isString, defineModule, urlRegexp, getEnv, merge, log, select} = require 'art-standard-lib'

{getAwsServiceConfig, getAwsCredentials} = Config = require './Config'

# https://github.com/mhart/aws4
aws4 = require 'aws4'

defineModule module, class Aws4RestClient extends (require 'art-rest-client').RestClientClass
  @singletonClass()

  ###
  IN:
    service: string (required)
    credentials: (optional)
      secretAccessKey:  "<your-secret-access-key>"
      accessKeyId:      "<your-access-key-id>"
      sessionToken:     "<your-session-token>"

  Art.Aws.Config
    If credentials isn't specified in options, credentials is taken from:
      Art.Aws.Config.getCredentials @service
      See: Art.Aws.Config

    Example config:

    Art: Aws:
      # elasticsearch
      elasticsearch: credenticals: {...}

  ENVIRONMENT
    if credential isn't supplied, they are looked for in "getEnv()".

    NOTE: getEnv() returns the parsed query-string in browsers and the shell-environment in node.

    Here are the env vars:
      secretAccessKey or AWS_SECRET_ACCESS_KEY
      accessKeyId     or AWS_ACCESS_KEY_ID
      sessionToken    or AWS_SESSION_TOKEN

  ###
  constructor: (options) ->
    super
    throw new Error "service required" unless isString options?.service
    {@service, @endpoint, @credentials} = options
    @credentials ||= getAwsCredentials @service
    @endpoint ||= getAwsServiceConfig(@service)?.endpoint

    # log Aws4RestClient: {@service, @endpoint, @credentials}

    # unless @credentials
    #   env = getEnv()
    #   if accessKeyId = env.accessKeyId || env.AWS_ACCESS_KEY_ID
    #     @credentials =
    #       accessKeyId:      accessKeyId
    #       secretAccessKey:  env.AWS_SECRET_ACCESS_KEY || env.secretAccessKey
    #       sessionToken:     env.AWS_SESSION_TOKEN     || env.sessionToken

  pathJoin = (base, path) ->
    path = if path then path.replace /^\//, '' else ''
    base = if base then base.replace /\/$/, '' else ''
    "#{base}/#{path}"

  sign: (options) ->
    {url, headers, body, method} = options
    unless urlRegexp.test url
      unless @endpoint
        throw new Error "url does not have a host and no endpoint specified for service. #{formattedInspect {@service, url}}"
      url = pathJoin @endpoint, url

    [__, protocol, __, host, __, port, path = '/', __, query] = matched = url.match urlRegexp
    throw new Error "unvalid url: #{formattedInspect {url}}" unless host
    host = "#{host}:#{port}" if port?

    if query
      path = "#{path}?#{query}"

    merge options,
      url: url
      headers:
        @_getSignatureHeaders {
          method
          host
          @service
          path
          headers: select headers, "content-type", "Content-Type"
          body
        }

  _getSignatureHeaders: (signOptions) ->
    objectWithout aws4.sign(signOptions, @credentials).headers, "Host", "Content-Length"

  _normalizedRestRequest: (options) -> super @sign options
