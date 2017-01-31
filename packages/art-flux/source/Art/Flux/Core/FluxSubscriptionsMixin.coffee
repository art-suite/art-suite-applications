{isString, defineModule, isPlainObject, rubyTrue, CommunicationStatus, log, isFunction, BaseObject, nextTick, mergeInfo, capitalize, globalCount, time} = require 'art-foundation'
{success} = CommunicationStatus
{fluxStore} = require './FluxStore'
ModelRegistry = require './ModelRegistry'

defineModule module, ->
  # when CafScript arrives, this line will just be:
  # mixin FluxSubscriptionsMixin
  (superClass) -> class FluxSubscriptionsMixin extends superClass
    ################################
    # constructor
    ################################
    constructor: ->
      super
      @_subscriptions = {}

    ################################
    # getters
    ################################
    @getter
      models: -> ModelRegistry.models
      subscriptions: -> @_subscriptions

    ################################
    # Subscribe
    ################################
    ###
    subscribe OR update a subscription

    IN:
      subscriptionKey: string (REQUIRED)
        Provide a unique key for each active subscription.
        To update the suscription, call @subscribe again with the same subscriptionKey.
        To unsubscribe, call @unsubscribe with the same subscriptionKey.

      modelName: lowerCamelCase string
        if modelName is null/undefined then
          - no subscription will be created.
          - @unsubscribe subscriptionKey will still happen

      key: valid input for models[modelName].toKeyString - usually it's a string
        if key is null/undefined then
          - no subscription will be created.
          - @unsubscribe subscriptionKey will still happen

      options:
        # if provided, will call @setState(stateField, ...) immediately and with every change
        stateField: string

        initialFluxRecord: fluxRecord-style object

        # get called with every change
        updatesCallback:  (fluxRecord) -> ignored

      NOTE: One of options.stateField OR options.updatesCallback is REQUIRED.

    OUT: existingFluxRecord || initialFluxRecord || status: missing fluxRecord

    EFFECT:
      Establishes a FluxStore subscription for the given model and fluxKey.
      Upon any changes to the fluxRecord, will:
        call updatesCallback, if provided
        and/or @setStateFromFluxRecord if stateField was provided

      Will also call @setStateFromFluxRecord immediately, if stateField is provided,
        with either the initialFluxRecord, or the existing fluxRecord, if any

      If there was already a subscription in this object with they same subscriptionKey,
      then @unsubscribe subscriptionKey will be called before setting up the new subscription.
    ###
    subscribe: (subscriptionKey, modelName, key, options) ->

      if isPlainObject allOptions = subscriptionKey
        {subscriptionKey, modelName, key, stateField, initialFluxRecord, updatesCallback, callback} = allOptions
        updatesCallback ||= callback
        subscriptionKey ||= stateField || modelName
      else
        {stateField, initialFluxRecord, updatesCallback} = options

      throw new Error "REQUIRED: subscriptionKey" unless isString subscriptionKey
      throw new Error "REQUIRED: updatesCallback or stateField" unless isString(stateField) || isFunction updatesCallback

      # unsubscribe, if needed
      @unsubscribe subscriptionKey

      # unless key and modelName are present, clear stateFields and return after unsubscribing
      return @setStateFromFluxRecord stateField, status: success unless rubyTrue(key) && modelName

      unless model = @models[modelName]
        throw new Error "No model registered with the name: #{modelName}. Registered models:\n  #{Object.keys(@models).join "\n  "}"

      fluxKey = model.toKeyString key

      subscriptionFunction = (fluxRecord) =>
        updatesCallback? fluxRecord
        @setStateFromFluxRecord stateField, fluxRecord

      @_subscriptions[subscriptionKey] = {modelName, fluxKey, subscriptionFunction}

      # NOTE: subscriptionFunction is the 'handle' needed later to unsubscribe from the fluxStore
      @setStateFromFluxRecord stateField,
        fluxStore.subscribe modelName, fluxKey, subscriptionFunction, initialFluxRecord

    ###
    IN: same as @subscribe
    OUT: promise.then -> # subscription has been created
    USE:
      Primarilly useful for models which want to subscribe to
      other models when they are constructed. This solves the
      loading-order problem.
    ###
    subscribeOnModelRegistered: (subscriptionKey, modelName, fluxKey, options) ->
      if isPlainObject subscriptionKey
        {modelName} = subscriptionKey

      ModelRegistry.onModelRegistered modelName
      .then => @subscribe subscriptionKey, modelName, fluxKey, options

    ################################
    # Unsubscribe
    ################################
    unsubscribe: (subscriptionKey)->
      if subscription = @_subscriptions[subscriptionKey]
        {subscriptionFunction, modelName, fluxKey} = subscription
        fluxStore.unsubscribe modelName, fluxKey, subscriptionFunction
        delete @_subscriptions[subscriptionKey]
      null

    unsubscribeAll: ->
      for subscriptionKey, __ of @_subscriptions
        @unsubscribe subscriptionKey
      null

    ################################
    # Helpers
    ################################
    setStateFromFluxRecord: (stateField, fluxRecord) ->
      if stateField && isFunction @setState
        @setState stateField, fluxRecord?.data
        @setState stateField + "Status",   fluxRecord.status   if fluxRecord.status
        @setState stateField + "Progress", fluxRecord.progress if fluxRecord.progress?
      fluxRecord
