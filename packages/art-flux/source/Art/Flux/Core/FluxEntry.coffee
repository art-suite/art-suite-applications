Foundation = require 'art-foundation'

{
  log, BaseObject, merge, removeFirstMatch, pushIfNotPresent
  Epoch, shallowClone, inspect, Unique, clone
  isPlainObject, propsEq
, defineModule, CommunicationStatus} = Foundation

{pending, success, failure} = CommunicationStatus

defineModule module, class FluxEntry extends BaseObject
  @warnCantSetField: warnCantSetField = (newFluxRecord, oldFluxRecord, field) ->
    newValue = newFluxRecord[field]
    oldValue = oldFluxRecord?[field]
    if newFluxRecord.hasOwnProperty(field) && newValue != oldValue
      console.warn "#{FluxEntry.namespacePath}: Do not put/post the '#{field}' field (new value == #{inspect newValue}, old value == #{inspect oldValue}). Ignored."

  @warnUnsettableFields: warnUnsettableFields = (newFluxRecord, oldFluxRecord) ->
    warnCantSetField newFluxRecord, oldFluxRecord, "key"
    warnCantSetField newFluxRecord, oldFluxRecord, "modelName"


  # assumes FluxEntry "owns" the fluxRecord - it will alter the object by adding a "key" field
  constructor: (modelName, key)->
    super
    @_fluxRecord =
      status: pending
      key: key
      modelName: modelName

    @_subscribers = []
    @_previousFluxRecord = null

  @getter "previousFluxRecord fluxRecord subscribers",
    dataChanged: -> !propsEq @_fluxRecord?.data, @_previousFluxRecord?.data
    fluxRecordChanged: -> !propsEq @_fluxRecord, @_previousFluxRecord
    subscriberCount: -> @_subscribers.length
    key: -> @_fluxRecord.key
    modelName: -> @_fluxRecord.modelName

  @setter
    fluxRecord: (newFluxRecord)->
      {key, modelName} = @_fluxRecord
      warnUnsettableFields newFluxRecord, @_fluxRecord
      newFluxRecord.key = key
      newFluxRecord.modelName = modelName
      newFluxRecord.status ||= pending
      throw new Error "fluxRecord must be an object" unless isPlainObject newFluxRecord
      @_fluxRecord = newFluxRecord

  @getter
    plainStructure: -> fluxRecord: @_fluxRecord, subscribers: @_subscribers
    hasSubscribers: -> @_subscribers.length > 0

  _merge: (src) ->
    throw new Error "fluxRecord must be an object" unless isPlainObject src
    @_fluxRecord = src._fluxRecord
    @_subscribers = @_subscribers.concat src._subscribers

  _notifySubscribers: ->
    return unless @_previousFluxRecord
    for subscriber in @_subscribers
      subscriber @_fluxRecord, @_previousFluxRecord
    @_previousFluxRecord = null

  _updateFluxRecord: (updateFunction) ->
    @_previousFluxRecord ||= @_fluxRecord
    @setFluxRecord updateFunction?(@_fluxRecord) || {}
    if propsEq @_fluxRecord, @_previousFluxRecord
      @_previousFluxRecord = null

  # subscriber is a function with the signature: (FluxEntry) ->
  # to unsubscribe, you must provide the exact same subscription function
  _subscribe:   (subscriber) -> pushIfNotPresent @_subscribers, subscriber
  _unsubscribe: (subscriber) -> removeFirstMatch @_subscribers, subscriber
