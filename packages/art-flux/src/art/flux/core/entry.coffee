{
  log, BaseObject, merge, removeFirstMatch, pushIfNotPresent
  Epoch, shallowClone, inspect, Unique, clone
} = require 'art-foundation'

module.exports = class Entry extends BaseObject
  @warnCantSetField: warnCantSetField = (newFluxRecord, oldFluxRecord, field) ->
    newValue = newFluxRecord[field]
    oldValue = oldFluxRecord?[field]
    if newFluxRecord.hasOwnProperty(field) && newValue != oldValue
      console.warn "#{Entry.getClassPathName()}: Do not put/post the '#{field}' field (new value == #{inspect newValue}, old value == #{inspect oldValue}). Ignored."

  @warnUnsettableFields: warnUnsettableFields = (newFluxRecord, oldFluxRecord) ->
    warnCantSetField newFluxRecord, oldFluxRecord, "key"
    warnCantSetField newFluxRecord, oldFluxRecord, "modelName"


  # assumes Entry "owns" the fluxRecord - it will alter the object by adding a "key" field
  constructor: (modelName, key)->
    super
    @_fluxRecord =
      status: "pending"
      key: key
      modelName: modelName

    @_updated = false

    @_subscribers = []

  @getter
    subscriberCount: -> @_subscribers.length
    key: -> @_fluxRecord.key
    modelName: -> @_fluxRecord.modelName

  @propGetter "fluxRecord", "subscribers"

  @setter
    fluxRecord: (newFluxRecord)->
      {key, modelName} = @_fluxRecord
      warnUnsettableFields newFluxRecord, @_fluxRecord
      newFluxRecord.key = key
      newFluxRecord.modelName = modelName
      @_fluxRecord = newFluxRecord

  @getter
    plainStructure: -> fluxRecord: @_fluxRecord, subscribers: @_subscribers
    hasSubscribers: -> @_subscribers.length > 0

  _merge: (src) ->
    @_fluxRecord = src._fluxRecord
    @_subscribers = @_subscribers.concat src._subscribers

  _notifySubscribers: ->
    return unless @_subscribers && @_updated
    for subscriber in @_subscribers
      subscriber @_fluxRecord
    @_updated = false

  _update: (updateFunction) ->
    @_updated = true
    @setFluxRecord updateFunction?(@_fluxRecord) || {}

  # subscriber is a function with the signature: (Entry) ->
  # to unsubscribe, you must provide the exact same subscription function
  _subscribe:   (subscriber) -> pushIfNotPresent @_subscribers, subscriber
  _unsubscribe: (subscriber) -> removeFirstMatch @_subscribers, subscriber
