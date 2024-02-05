{
  objectHasKeys
  clone
  currentSecond, objectWithout, arrayWithoutLast, pureMerge,
  Promise, compactFlatten, object, peek,
  isPlainArray, objectKeyCount, arrayWith, inspect,
  RequestError, isPlainObject, log, CommunicationStatus,
  merge, isJsonType, formattedInspect, w, neq
  success, missing, failure, serverFailure, clientFailure
  Validator
  alignTabs
  isNode
  getDetailedRequestTracingEnabled
  getDetailedRequestTracingExplanation
  getEnv
  cleanStackTrace
  getCleanStackTraceWarning
} = require './StandardImport'

Request = require './Request'
{config} = require './Config'

namespace = require './namespace'

responseValidator = new Validator
  request:  required: true, instanceof: Request
  status:   w "required communicationStatus"
  session:  "object"
  props:    "object"

###
TODO: Merge Response back into Request

  Turns out, Response has very little special functionality.
  At this point, the RequestuestResponseBase / Request / Response class structure
  actually requires more code than just one, Request class would.

What to add to Request:

  @writeOnceProperty "responseStatus responseSession responseProps"

  @getter
    hasResponse: -> !!@responseStatus

  Split out: filterLog into beforeFilterLog and afterFilterLog.
###
###
new Response

IN:
  request: Request (required)
  status: CommunicationStatus (required)
  props: plainObject with all JSON values
  session: plainObject with all JSON values

  data: JSON value
    data is an alias for @props.data
    EFFECT: replaces @props.data
    NOTE: for clientRequest, @props.data is the value returned unless returnResponse/returnResponseObject is requested

  remoteRequest: remoteResponse:
    Available for inspecting what exactly went over-the-wire.
    Otherwise ignored by Response

###


module.exports = class Response extends require './RequestResponseBase'
  constructor: (options) ->
    super merge options, creationStack: options.request.creationStack
    responseValidator.validate options, context: "Art.Ery.Response options", logErrors: true
    {@request, @status, @props = {}, @session, @remoteRequest, @remoteResponse} = options

    throw new Error "options.requestOptions is DEPRICATED - use options.props" if options.requestOptions

    @_props.data = options.data if options.data?

    @_session ?= if neq @request.session, @request.originalRequest.session
      @request.session

    @_endTime = null

    @setGetCache() if @type == "create" || @type == "get"

  isResponse:     true

  @property "request props session remoteResponse remoteRequest"
  @setter "status"

  @getter
    status: ->
      if @_status == failure
        switch @location
          when "server" then return serverFailure
          when "client" then return clientFailure
      @_status

    failed:             -> @_status == failure || @_status == serverFailure

    data:               -> @_props.data
    session:            -> @_session ? @request.session
    responseData:       -> @_props.data
    responseProps:      -> @_props
    responseSession:    -> @_session

    beforeFilterLog:    -> @request.filterLog || []
    handledBy:          -> !@failed && peek @request.filterLog

    # I'd like to just call this 'filterLog', but there appears to be a conflict somewhere' (SBD 1/2018)
    rawRequestLog: -> compactFlatten [@beforeFilterLog, @afterFilterLog]
    requestLog:          ->
      {startTime, endTime} = @

      firstTime = lastTime = startTime
      lastProps = null
      out = for {name, time} in @rawRequestLog
        firstTime = lastTime = time unless firstTime?

        lastProps?.deltaMs = (time - lastTime) * 1000 | 0

        lastProps =
          name: name
          timeMs: 0
          wallMs:  (time - firstTime) * 1000 | 0
        lastTime = time
        lastProps

      log {startTime, lastTime, @_endTime}
      lastProps?.deltaMs = (endTime - lastTime) * 1000 | 0

      out

    afterFilterLog:     -> @_filterLog || []
    isSuccessful:       -> @_status == success
    isMissing:          -> @_status == missing
    notSuccessful:      -> @_status != success
    description: -> "#{@requestString}: #{@status}"
    propsForClone: ->
      {
        @request
        @status
        @props
        session:   @_session
        filterLog:  @_filterLog
        @remoteRequest
        @remoteResponse
        @errorProps
      }
    propsForResponse: -> @propsForClone

    summary: -> response: merge {@status, @props, @errorProps}

    plainObjectsResponse: (fields) ->
      object fields || {@status, @props, @beforeFilterLog, @afterFilterLog, session: @_session},
        when: (v) ->
          switch
            when isPlainObject v then objectKeyCount(v) > 0
            when isPlainArray  v then v.length > 0
            else v != undefined

    responseForRemoteRequest: ->
      @getPlainObjectsResponse unless config.returnProcessingInfoToClient then {
        @status
        @props
        session: @_session
      }

    # DEPRICATED
    # message:            -> @data?.message

  withMergedSession: (session) ->
    Promise.resolve(session).then (session) =>
      new @class merge @propsForClone, session: merge @session, session

  ###
  IN: options:
    returnNullIfMissing: true [default: false]
      if status == missing
        if returnNullIfMissing
          promise.resolve null
        else
          promise.reject new RequestError

    returnResponse: true [default: false]
    returnResponseObject: true (alias)
      if true, the response object is returned, otherwise, just the data field is returned.

  OUT:
    # if response.isSuccessful && returnResponse == true
    promise.then (response) ->

    # if response.isSuccessful && returnResponse == false
    promise.then (data) ->

    # if response.isMissing && returnNullIfMissing == true
    promise.then (data) -> # data == null

    # else
    promise.catch (errorWithInfo) ->
      {response} = errorWithInfo.info

  ###
  toPromise: (options) ->
    {returnNullIfMissing, returnResponse, returnResponseObject} = options if options
    {data, isSuccessful, isMissing} = @
    returnResponse ||= returnResponseObject

    if isMissing && returnNullIfMissing
      data = null
      isSuccessful = true

    if isSuccessful
      Promise.resolve if returnResponse then @ else data
    else Promise.reject @_getRejectionError()

  _getRejectionError: ->
    @_preparedRejectionError ||=
      new RequestError {
        message:
          compactFlatten([
            @responseData?.message ? @responseProps?.message ? @errorProps?.exception?.message
            ""
            "request: #{@pipeline}.#{@type}"
            formattedInspect {
              @status
              @session
              props: @requestProps
            }
          ]).join "\n"
          # + "\n"

        @type
        @status
        @requestData
        @responseData
        sourceLib:  "ArtEry"
        response:   @
        stack: compactFlatten([
          if exception = @errorProps?.exception
              "Exception stack:\n#{cleanStackTrace exception.stack, false, true}\n"

          (for {time, request, context, name, stack, filterLog}, i in @requestTrace by -1
            "#{request}: #{if filterLog? then (name for {name} in filterLog when name != "created").join " -> " else "#{context} #{name}"}
              (request-depth: #{i + 1}, start-time: #{time*1000|0}ms)
              #{if stack then "\n#{cleanStackTrace stack, null, true}\n" else ''}
              "
          ).join "\n"
          getDetailedRequestTracingExplanation()
          getCleanStackTraceWarning()
        ]).join "\n"
      }
