{
  log, merge, removeFirstMatch, pushIfNotPresent
  Epoch, shallowClone, inspect, Unique, clone
  isPlainObject, propsEq
  defineModule
  timeoutAt
  min
  toSeconds
  floatEq
} = require 'art-standard-lib'
{BaseObject} = require 'art-class-system'

{
  pending, success, failure, isSuccess, isFailure
  networkFailure
  serverFailure
} = require 'art-communication-status'

_fluxStore = null
getFluxStore = -> _fluxStore ?= Neptune.Art.Flux.fluxStore

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
    @_model = Neptune.Art.Flux.models[modelName]
    @_autoReload = @_model.autoReloadEnabled

    @_updatedAt = @_createdAt = toSeconds()
    @_reloadAt = @_lastSuccessfulLoadAt = null
    @_tryCount = 0

    @_fluxRecord =
      key:        key
      modelName:  modelName
      status:     pending
      updateAt:   new Date

    @_subscribers = []
    @_previousFluxRecord = null

  @property "createdAt updatedAt reloadAt lastSuccessfulLoadAt tryCount"
  @getter "previousFluxRecord fluxRecord subscribers model autoReload",
    dataChanged: -> !propsEq @_fluxRecord?.data, @_previousFluxRecord?.data
    fluxRecordChanged: -> !propsEq @_fluxRecord, @_previousFluxRecord
    subscriberCount:  -> @_subscribers.length
    key:              -> @_fluxRecord.key
    modelName:        -> @_fluxRecord.modelName
    status:           -> @_fluxRecord.status
    reloadAt:         -> @_fluxRecord.reloadAt

  @setter
    fluxRecord: (newFluxRecord)->
      throw new Error "fluxRecord must be an object" unless isPlainObject newFluxRecord
      warnUnsettableFields newFluxRecord, oldFluxRecord = @_fluxRecord

      {key, modelName}  = @_fluxRecord
      @_fluxRecord = newFluxRecord
      newFluxRecord.key           = key
      newFluxRecord.modelName     = modelName
      newFluxRecord.status        ?= pending
      newFluxRecord.createdAt     = @_createdAt
      newFluxRecord.updatedAt     = @_updatedAt = now = toSeconds()

      @_updateAutoReloadFields() if @_autoReload

  _updateAutoReloadFields: ->
    reloadDelta = if isSuccess @status
      @lastSuccessfulLoadAt = @_updatedAt
      @tryCount = 1
      @model.getStaleDataReloadSeconds()

    else if isFailure @status
      @tryCount += 1
      switch @status
        when networkFailure         then @nextNetworkFailureRetryDelay
        when serverFailure, failure then @nextServerFailureRetryDelay

    @_fluxRecord.lastSuccessfulLoadAt = @lastSuccessfulLoadAt
    @_fluxRecord.tryCount = @tryCount
    @reloadAt = if reloadDelta > 0 then @_updatedAt + reloadDelta else null

  reload: -> @model.reload @key

  @setter
    reloadAt: (reloadAt) ->
      if 0 < reloadAt
        delta = reloadAt - now = toSeconds()
        rangePerterbation = if delta < 65 then 0 else .05
        minRange = delta * (1 - rangePerterbation)
        maxRange = delta * (1 + rangePerterbation)

        # queue reload if there isn't one already queued within [minRange, maxRange]
        unless @_reloadAt && (oldDelta = @_reloadAt - now) > minRange && oldDelta < maxRange

          # +/- 10% random pertubation so reloads are distributed
          @_reloadAt = reloadAt = now + minRange + (maxRange - minRange) * Math.random()

          {modelName, key} = @
          memoryLeakFreeReloader modelName, key, reloadAt

        @_fluxRecord.reloadAt = @_reloadAt

  # WHY memoryLeakFreeReloader?
  #   If this entry is gone by the time the reload comes around, we shouldn't
  #   hold on to this entry the whole time.
  memoryLeakFreeReloader = (modelName, key, reloadAt) ->
    timeoutAt reloadAt, ->
      if entry = getFluxStore()._getEntry modelName, key
        if floatEq reloadAt, entry.reloadAt
          entry.reload()

  retryExponent = 2
  @getter
    age: ->
      now = toSeconds()
      reload:             now - @reloadAt | 0
      created:            now - @createdAt | 0
      updated:            now - @updatedAt | 0
      lastSuccessfulLoad: now - @lastSuccessfulLoadAt | 0

    nextNetworkFailureRetryDelay: ->
      if 0 < m = @model.getMinNetworkFailureReloadSeconds()
        min(
          m * Math.pow @tryCount ? 1, retryExponent
          @model.getMaxNetworkFailureReloadSeconds()
        )

    nextServerFailureRetryDelay: ->
      if 0 < m = @model.getMinServerFailureReloadSeconds()
        min(
          m * Math.pow @tryCount ? 1, retryExponent
          @model.getMaxServerFailureReloadSeconds()
        )

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
