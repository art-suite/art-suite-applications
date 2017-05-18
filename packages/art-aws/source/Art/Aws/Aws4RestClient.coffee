{defineModule, urlRegexp, getEnv, merge, log, select} = require 'art-standard-lib'

# https://github.com/mhart/aws4
aws4 = require 'aws4'

defineModule module, class Aws4RestClient extends require 'art-rest-client'
  @singletonClass()

  ###
  IN:
    credentials: (optional)
      secretAccessKey:  "<your-secret-access-key>"
      accessKeyId:      "<your-access-key-id>"
      sessionToken:     "<your-session-token>"

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
    {@service, @credentials} = options || {}

    unless @credentials
      env = getEnv()
      if accessKeyId = env.accessKeyId || env.AWS_ACCESS_KEY_ID
        @credentials =
          accessKeyId:      accessKeyId
          secretAccessKey:  env.AWS_SECRET_ACCESS_KEY || env.secretAccessKey
          sessionToken:     env.AWS_SESSION_TOKEN     || env.sessionToken

  sign: (options) ->
    {url, headers, body} = options
    [__, protocol, __, host, __, port, __, path = '/'] = url.match urlRegexp
    host = "#{host}:#{port}" if port?

    merge options,
      headers:
        @_getSignatureHeaders {
          host
          @service
          path
          headers
          body
        }

  _getSignatureHeaders: (signOptions) ->
    select aws4.sign(signOptions, @credentials).headers, "X-Amz-Date", "Authorization"

  _normalizedRestRequest: (options) -> super @sign options
