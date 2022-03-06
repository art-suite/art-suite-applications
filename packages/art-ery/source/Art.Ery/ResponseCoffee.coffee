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
  request:  w "required", instanceof: Request
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
