{
  currentSecond
  each
  present, Promise, BaseObject, RestClient, merge,
  inspect, isString, isObject, log, Validator,
  CommunicationStatus, arrayWith, w
  objectKeyCount, isString, isPlainObject
  objectWithout
  isFunction
  object
  objectHasKeys
} = Foundation = require '@art-suite/art-foundation'
ArtEry = require './namespace'
{success, missing, validStatus, clientFailure, failure} = CommunicationStatus

# validator must be initialized after Request and Pipeline have bene defined
_validator = null
requestConstructorValidator = ->
  _validator ||= new Validator
    pipeline:           required: instanceof: ArtEry.Pipeline
    type:               required: fieldType: "string"
    session:            required: fieldType: "object"
    parentRequest:      instanceof: ArtEry.Request
    originatedOnServer: "boolean"
    props:              "object"
    key:                "string"

###
new Request(options)

IN: options:
  see requestConstructorValidator for the validated options
  below are special-case options

  props: {}
    Any props you want.
    Common props:

    data: - generaly one record's data or an array of record data
    key:  - generally the ID for one record OR the complete set of parameters for a get-query

  # aliases - if either data/key are provided in both props and in these aliases,
  #   these aliases have priority
  data: >> @props.data
  key:  >> @props.key

  NOTE: Request doesn't care about @data, the alias is proved only as a convenience
  NOTE: Request only cares about @key for two things:
    - REST urls
    - cachedGet

    In general, type: "get" and key: "string" is a CACHEABLE request.
    This is why it must be a string.
    Currently there are no controls for HOW cacheable type-get is, though.
    All other requests are NOT cacheable.

CONCEPTS

  context:

    This is the only mutable part of the request. It establishes one shared context for
    a request, all its clones, subrequests, responses and response clones.

    The primary purpose is for subrequests to coordinate their actions with the primary
    request. Currently this is only used server-side.

    There are two contexts when using a remote server: The client-side context is not
    shared with the server-side context. A new context is created server-side when
    responding to the request.

    BUT - there is only one context if location == "both" - if we are running without
    a remote server.
###
module.exports = class Request extends require './RequestResponseBase'

  constructor: (options) ->
    super
    {@verbose, @type, @pipeline, @session, @originalRequest, @parentRequest, @originatedOnServer, @props = {}, context, @remoteRequest} = options
    @_context   = context
    @_startTime = null

    key = options.key ? @_props.key
    options.key = @_props.key = @pipeline.toKeyString key if key?
    @_props.data = options.data if options.data?
    @_originalRequest ?= @

    requestConstructorValidator().validate options, context: "Art.Ery.Request options", logErrors: true

    throw new Error "options.requestOptions is DEPRICATED - use options.props" if options.requestOptions

  @property "verbose originalRequest type pipeline session originatedOnServer parentRequest props data key context remoteRequest"

  @getter
    context:        -> @_context ?= {}
    key:            -> @_props.key
    data:           -> @_props.data
    requestData:    -> @_props.data
    requestProps:   -> @_props
    requestOptions: -> throw new Error "DEPRICATED: use props"
    description: -> "#{@requestString} request"
    summary: -> request: {@props}

  ##############################
  # MISC
  ##############################
  @getter
    request:      -> @
    shortInspect: ->
      "#{if @parentRequest then @parentRequest.shortInspect + " > " else ""}#{@pipeline.getName()}-#{@type}(#{@key || ''})"

    # Also implemented in Response
    beforeFilterLog:  -> @filterLog || []
    afterFilterLog:   -> []
    isRequest:        -> true
    isRootRequest:    -> !@parentRequest
    requestPipelineAndType: -> log.warn "DEPRICATED - use pipelineAndType"; "#{@pipeline.name}-#{@type}"

    propsForClone: ->
      {
        @originalRequest
        @pipeline
        @type
        @props
        @session
        @parentRequest
        @filterLog
        @originatedOnServer
        context: @_context
        @verbose
        @remoteRequest
      }

    urlKeyClause: -> if present @key then "/#{@key}" else ""

  handled: (_handledBy) ->
    @success().then (response) -> response.handled _handledBy

  getRestRequestUrl:    (server) -> "#{server}/#{@pipeline.name}#{@urlKeyClause}"
  getNonRestRequestUrl: (server) -> "#{server}/#{@pipeline.name}-#{@type}#{@urlKeyClause}"

  toPromise: ->
    throw new Error "ArtEry.Request: toPromise can only be called on Response objects."

  restMap =
    get:    "get"
    create: "post"
    update: "put"
    delete: "delete"

  @getRestClientParamsForArtEryRequest: getRestClientParamsForArtEryRequest = ({session, server, restPath, type, key, data}) ->
    urlKeyClause = if present key then "/#{key}" else ""
    server ||= ""
    hasSessionData = objectHasKeys session
    url = if (method = restMap[type]) && (method != "get" || !hasSessionData)
      "#{server}#{restPath}#{urlKeyClause}"
    else
      method = "post"
      "#{server}#{restPath}-#{type}#{urlKeyClause}"

    method: method
    url:    url
    data:   data

  @getter
    remoteRequestProps: ->
      {session, data, props, pipeline, type, key} = @

      propsCount = 0
      props = object props, when: (v, k) -> v != undefined && k != "key" && k != "data"
      data  = object data,  when: (v) -> v != undefined

      remoteRequestData = null
      (remoteRequestData||={}).session = session.signature if session.signature
      (remoteRequestData||={}).props   = props if 0 < objectHasKeys props
      (remoteRequestData||={}).data    = data  if 0 < objectHasKeys data

      getRestClientParamsForArtEryRequest {
        restPath: pipeline.restPath
        server:
          switch pipeline.remoteServer
            when true, ".", "/" then ""
            else pipeline.remoteServer
        type
        key
        session
        data:           remoteRequestData
      }

  @createFromRemoteRequestProps: (options) ->
    {session, pipeline, type, key, requestData, remoteRequest} = options
    {data, props} = requestData
    new Request {
      remoteRequest
      pipeline
      type
      session
      key
      data
      props
      originatedOnClient: true
    }

  sendRemoteRequest: ->
    RestClient.restJsonRequest remoteRequest = @remoteRequestProps
    .catch (error) =>
      if error.info
        {status, response} = error.info
      else
        {status, message} = error

      status ?= failure

      merge response, {status, message}

    .then (remoteResponse) =>
      @addFilterLog "#{remoteRequest.method.toLocaleUpperCase()} #{remoteRequest.url}"
      .toResponse remoteResponse.status, merge remoteResponse, {remoteRequest, remoteResponse}
