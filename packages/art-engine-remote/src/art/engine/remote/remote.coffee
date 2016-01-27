Foundation = require 'art-foundation'
Namespace = require './namespace'

{
  log, BaseObject, isWebWorker, isPlainArray, isPlainObject, isFunction, isString, inspect,
  WorkerRpc: {workerRpc}
  merge
  deepMap
} = Foundation

module.exports = class Remote extends BaseObject
  @singletonClass()
  @remoteIdCounter: 0
  @remoteIdPrefix: if isWebWorker then "worker" else "simulatedLocal"
  nextRemoteId: (props) ->
    "#{Remote.remoteIdPrefix}RemoteId_#{Remote.remoteIdCounter++}" #+
    # if props && key = props.name || props.key then "_#{key}" else ""

  constructor: ->
    self.remote = @ if isWebWorker
    @_remoteQueue = []
    @_handlersByRemoteId = {}
    if isWebWorker
      workerRpc.register
        ArtEngineRemote:
          event: (remoteId, eventName, processedEvent) =>
            # console.log "Remote: worker.remote.event", remoteId, eventName, processedEvent
            handlersForElement = @_handlersByRemoteId[remoteId]
            return console.warn "no handlers found for element with remoteId: #{remoteId}" unless handlersForElement
            handler = handlersForElement[eventName]
            return console.warn "no handler found for event '#{eventName}' for element with remoteId: #{remoteId}" unless handler
            handler processedEvent
          unregistered: (remoteId) =>
            # console.log "Remote unregistered: #{remoteId} before", @_handlersByRemoteId
            delete @_handlersByRemoteId[remoteId]
            # console.log "Remote unregistered: #{remoteId} after", @_handlersByRemoteId

      workerRpc.bind
        ArtEngineRemoteReceiver: ["applyUpdates"]

  getHandlersForRemoteId: (remoteId) -> @_handlersByRemoteId[remoteId]

  ###
  To create a root Element (that isn't immediatly released because it has no parent)
    newElement "CanvasElement", children: [
      # add your element's remoteId here
    ]

  Auto-Releasing Notes
    The returned remoteId for is only valid as long as the created Element has a parent.

    This is checked at the end of each Art.Engine.Epoch.

    To be sure this new element has a parent before it is released, call queueUpdateElement
    to attach it to its parent before the next call to sendRemoteQueue.
  ###
  newElement: (elementClassName, props)->
    remoteId = @nextRemoteId props
    props = @_preprocessProps remoteId, props
    # log Remote:newElement:remoteId:remoteId, elementClassName:elementClassName, props:props
    @_remoteQueue.push ["new", remoteId, elementClassName, props]
    remoteId

  ###
  Most props can be the same as working in the main thread. Exceptions:

  Exceptions by prop-type:
    children:
      This should be an array of remoteIds since it can't be an array of Elements.

    on:
      The event handler functions provided are kept in the worker thread. Instead,
      the main thread and worker thread set up handler proxies which send the event
      from the main thread back to the worker were the provided handler is triggered.

      TODO: how do we convert event objects into plain objects?

  Exceptions by value-type:
    functions:
      NOTE: functions passed as event handlers to the "on" property are handled specially. See above.
      All other functions:
        Must be pure functional. They cannot depend on any closer variables or globals.
        This is because they are serialized as a string and then evaluated in the main thread.

    Art.Atomic.*:
      TODO: Props which are Art.Atomics should be automatically converted into arrays
        which will get converted back into their correct objects on the main thread.
  ###
  updateElement: (remoteId, setProps, resetProps)->
    setProps = @_preprocessProps remoteId, setProps
    # log Remote:updateElement:remoteId:remoteId, setProps:setProps, resetProps: resetProps
    @_remoteQueue.push ["update", remoteId, setProps, resetProps] if setProps || resetProps
    remoteId

  sendRemoteQueue: ->
    return if @_remoteQueue.length == 0
    # log "worker: remote"
    workerRpc.ArtEngineRemoteReceiver.applyUpdates @_remoteQueue

    @_remoteQueue = []
    null

  #######################
  # PRIVATE
  #######################
  ###
  TODO:

    If there are any on: handlers, make a special mapping so they can callback.
    If any other properties have functions, possibly deeply nested, convert the whole
    properties set into a string to eval that returns the props specified.
  ###
  _hasFunctionsArray: (o) ->
    for v in o when @_hasFunctions v
      return true
    false

  _hasFunctionsObject: (o) ->
    for k, v of o when @_hasFunctions v
      return true
    false

  _hasFunctions: (o) ->
    res = false
    if isPlainArray o       then @_hasFunctionsArray o
    else if isPlainObject o then @_hasFunctionsObject o
    else if isFunction o    then true
    else false

  _toEvalString: (o) ->
    if isPlainArray o       then "[#{(@_toEvalString v for v in o).join ', '}]"
    else if isPlainObject o then "({#{("#{inspect k}:#{@_toEvalString v}" for k, v of o).join ', '}})"
    else if isString o      then inspect o
    else if o?.toPlainEvalString then o.toPlainEvalString()
    else "(#{o})"

  ###
  registers the handlers locally
  returns a list of the handlers by name

  TODO: We may need a way to provide custom main-thread-side event preprocessors.
  Two options:
    1) it is a special value in the on: object:
      on:
        preprocess:
          pointerClick: (e) -> {location: e.location}
        pointerClick: ({location}) -> ...
        pointerMove: -> # no preprocessor
    2) it is a special value for the handler:
      on:
        pointerClick:
          preprocess: (e) -> {location: e.location}
          respond:    ({location}) -> ...
        pointerMove: -> # no preprocessor

  I think I like the latter. It is one extra object per handler with a preprocessor,
  but it places related concerns closer together and is visually easier to parse.

  WINNER: #2

  We also have to decide how to pass the preprocessors to the main thread. Options:
    1) ["pointerMove", ["pointerClick", (e) -> {location: e.location}]]
    2) ["pointerMove", {pointerClick: (e) -> {location: e.location}}]
    3) {pointerMove:true, pointerClick: (e) -> {location: e.location}}
  Props/Cons
    1: lowest overhead when no preprocessors or mixed preprocessors.
      relatively easy to parse
    3: looks nicest, but this isn't something the user will ever code.

  WINNER: #1

  ###
  _prepareHandlers: (remoteId, handlers) ->
    @_handlersByRemoteId[remoteId] = handlers
    handlersDataForMainThread = {}
    for k, v of handlers
      handlersDataForMainThread[k] = if isFunction v then true else v
    handlersDataForMainThread

  # triggered from main thread when the element is unregistered
  _releaseHandlers: (remoteId) ->
    delete @_handlersByRemoteId[remoteId]

  _preprocessProps: (remoteId, props) ->
    return null unless props
    if handlers = props.on
      props = merge props, on:@_prepareHandlers remoteId, handlers

    if @_hasFunctions props
      @_toEvalString props
    else
      deepMap props, (v) ->
        if v?.toPlainStructure
          v.toPlainStructure()
        else
          v

Namespace.remote = Remote.remote
