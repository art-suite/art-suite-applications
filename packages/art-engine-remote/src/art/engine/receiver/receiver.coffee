Foundation = require 'art-foundation'
Engine = require 'art-engine'
Namespace = require './namespace'

{
  inspect, log, BaseObject, isString, isPlainArray, merge, WorkerRpc, select, toPlainStructure
} = Foundation

{
  ElementBase: {getElementByInstanceId}
  ElementFactory: {elementFactory}
  GlobalEpochCycle: {globalEpochCycle}
} = Engine.Core

module.exports = class Receiver extends BaseObject
  @singletonClass()

  applyUpdates: (workerRpc, updates) ->
    if globalEpochCycle # loaded
      globalEpochCycle.timePerformance "aimRR", => @_applyUpdates workerRpc, updates
    else
      @_applyUpdates workerRpc, updates

  _applyUpdates: (workerRpc, updates) ->
    transitoryRegistry = {}
    for update in updates
      [command] = update
      if command == "update"
        @_applyUpdateCommand workerRpc, update, transitoryRegistry
      else if command == "new"
        @_applyNewCommand workerRpc, update, transitoryRegistry
    null

  startWorker: (workerUrl, delegates, remoteDelegates) ->
    new WorkerRpc workerUrl,
      register: merge delegates,
        ArtEngineRemoteReceiver:
          applyUpdates: (updates) => @applyUpdates WorkerRpc.lastMessageReceivedFrom, updates
      bind: merge remoteDelegates,
        ArtEngineRemote: ["event", "unregistered"]

  @startWorker: (workerUrl) -> Receiver.singleton.startWorker workerUrl

  # attachToWorker: (worker) ->
  #   worker.onmessage (m) => @_onmessage m

  ########################
  # PRIVATE
  ########################
  # _onmessage: ({data}) ->
  #   if !isPlainArray data
  #     return @_reportUpdateErrorBasic "expected data to be an array", data:data
  #   else if isPlainArray data[0]
  #     @applyUpdates data
  #   else
  #     @_reportUpdateErrorBasic "expected first element of the data-array to be a string or array", data:data

  ###
  OK to alter props - they were created as part of the postMessage process and are clones of the
  web-worker copies. We may need to be careful when simulating Art.EngineRemote locally, but I think
  that only effects tests - which we could just stop using and do full webworker tests only.
  ###
  defaultPreprocessor = (e) ->
    target: e.target && toPlainStructure select e.target, "key", "remoteId"
    timeStamp: e.timeStamp

  defaultPointerPreprocessor = (e) ->
    merge(
      defaultPreprocessor e
      toPlainStructure select e, "location", "delta"
      pointer: stayedWithinDeadzone: e.pointer.stayedWithinDeadzone

    )

  standardPreprocessors =
    ready: ({target}) ->
      target: toPlainStructure select target, "currentSize", "currentLocation", "key", "remoteId"
    pointerCancel:  defaultPointerPreprocessor
    pointerMove:    defaultPointerPreprocessor
    pointerUp:      defaultPointerPreprocessor
    pointerDown:    defaultPointerPreprocessor
    mouseMove:      defaultPointerPreprocessor
    mouseIn:        defaultPointerPreprocessor
    mouseOut:       defaultPointerPreprocessor
    focus:          defaultPointerPreprocessor
    blur:           defaultPointerPreprocessor

  _preprocessProps: (workerRpc, elementRemoteId, props) ->
    return null unless props
    if isString props
      try
        props = eval props
      catch e
        console.error "Error evaluating props. Make sure all functions passed as props are pure-functional and don't rely on any closure state.", e
        console.log inspect props

    if handlers = props.on
      # handlers is an array of strings at this point
      props.on = mainHandlers = {}

      preprocess = (handlers.preprocess ||= {})
      for handler, v of handlers
        do (handler, v) ->
          if v == true
            preprocess[handler] ||= standardPreprocessors[handler] || defaultPreprocessor
            mainHandlers[handler] = (e) =>
              workerRpc.ArtEngineRemote.event elementRemoteId, handler, e
          else
            mainHandlers[handler] = v

      {unregistered} = mainHandlers
      mainHandlers.unregistered = (e) =>
        try unregistered? e
        workerRpc.ArtEngineRemote.unregistered e.target?.remoteId

    props

  _applyUpdateCommand: (workerRpc, updateCommand, transitoryRegistry) ->
    [_, elementRemoteId, setProps, resetProps] = updateCommand

    unless element = getElementByInstanceId(elementRemoteId) || transitoryRegistry[elementRemoteId]
      return @_reportUpdateError updateCommand, "No element matches the elementRemoteId provided."

    setProps = @_preprocessProps workerRpc, elementRemoteId, setProps

    @_updateElement element, setProps, resetProps, transitoryRegistry
    null

  _applyNewCommand: (workerRpc, newCommand, transitoryRegistry) ->
    [_, elementRemoteId, elementClassName, props] = newCommand
    # console.log "ArtEngineRemoteReceiver: new Element #{elementRemoteId}"

    return @_reportUpdateError newCommand, "elementRemoteId required" unless elementRemoteId
    return @_reportUpdateError newCommand, "elementClassName required" unless isString elementClassName
    element = getElementByInstanceId(elementRemoteId) || transitoryRegistry[elementRemoteId]
    return @_reportUpdateError newCommand, "Element already exists for the given elementRemoteId." if element

    props = @_preprocessProps workerRpc, elementRemoteId, props

    @_newElement elementRemoteId, elementClassName, props, transitoryRegistry
    null

  _newElement: (elementRemoteId, elementClassName, props, transitoryRegistry) ->

    # log RemoteReceiver_newElement:
    #     elementRemoteId:elementRemoteId
    #     elementClassName:elementClassName
    #     props: props

    if (children = props?.children) && children.length > 0
      props = merge props, children: @_getElementInstances children, transitoryRegistry

    element = elementFactory.newElement elementClassName, props
    element.remoteId = elementRemoteId

    transitoryRegistry[elementRemoteId] = element
    element

  _getElementInstances: (remoteIds, transitoryRegistry) ->
    for remoteId in remoteIds
      if element = getElementByInstanceId(remoteId) || transitoryRegistry[remoteId]
        element
      else
        @_reportUpdateErrorBasic "Could not find element for remoteId.",
          in: "_getElementInstances"
          remoteId: remoteId
          remoteIds: remoteIds

  _updateElement: (element, props, resetProps, transitoryRegistry) ->
    # log RemoteReceiver_updateElement:
    #     instanceId: element.instanceId
    #     props: props
    #     resetProps: resetProps
    if props
      for k, v of props
        if k == "children"
          element.setChildren @_getElementInstances v, transitoryRegistry
        else
          element.setProperty k, v

    if resetProps
      element.resetProperty k for k in resetProps

    null

  _reportUpdateErrorBasic: (message, info) ->
    console.warn "Art.EngineRemote.Remote Update error: #{message}. Info: #{inspect info}"

  _reportUpdateError: ([command, elementRemoteId, elementClassName, setProps, resetProps], message) =>
    element = getElementByInstanceId elementRemoteId
    info =
      command: command
      elementRemoteId: elementRemoteId
      elementClassName: elementClassName
      setProps: setProps
      resetProps: resetProps
      element:
        remoteId: elementRemoteId
        element: if element
          className: element.className
          objectId: element.objectId

    @_reportUpdateErrorBasic message, info

Namespace.receiver = Receiver.receiver

