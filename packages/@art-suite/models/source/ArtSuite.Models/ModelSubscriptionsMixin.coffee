{
  isString
  defineModule
  isPlainObject
  rubyTrue
  log
  isFunction
} = require 'art-standard-lib'
{success, isFailure} = require 'art-communication-status'
{store} = require './Store'
ModelRegistry = require './ModelRegistry'

defineModule module, ->
  # when CafScript arrives, this line will just be:
  # mixin ModelSubscriptionsMixin
  (superClass) -> class ModelSubscriptionsMixin extends superClass
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
      subscriptionKey: string (REQUIRED - if no stateField OR modelName)
        Provide a unique key for each active subscription.
        To update the suscription, call @subscribe again with the same subscriptionKey.
        To unsubscribe, call @unsubscribe with the same subscriptionKey.
        DEFAULT: stateField || modelName

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

        initialModelRecord: modelRecord-style object

        # get called with every change
        callback / updatesCallback:  (modelRecord) -> ignored

      NOTE: One of options.stateField OR options.updatesCallback is REQUIRED.

    OUT: existingModelRecord || initialModelRecord || status: missing modelRecord

    EFFECT:
      Establishes a Store subscription for the given model and modelKey.
      Upon any changes to the modelRecord, will:
        call updatesCallback, if provided
        and/or @setStateFromModelRecord if stateField was provided

      Will also call @setStateFromModelRecord immediately, if stateField is provided,
        with either the initialModelRecord, or the existing modelRecord, if any

      If there was already a subscription in this object with they same subscriptionKey,
      then @unsubscribe subscriptionKey will be called before setting up the new subscription.

      NOTE:
        updateCallback only gets called when modelRecord changes. It will not be called with the
        current value. HOWEVER, the current modelRecord is returned from the subscribe call.

        If you need to update anything based on the current value, use the return result.
    ###
    subscribe: (subscriptionKey, modelName, key, options) ->
      if isPlainObject allOptions = subscriptionKey
        {subscriptionKey, modelName, key, stateField, initialModelRecord, updatesCallback, callback} = allOptions
        updatesCallback ?= callback
        subscriptionKey ?= stateField || "#{modelName} #{key}"
      else
        {stateField, initialModelRecord, updatesCallback} = options

      throw new Error "REQUIRED: subscriptionKey" unless isString subscriptionKey
      throw new Error "REQUIRED: updatesCallback or stateField" unless isString(stateField) || isFunction updatesCallback

      # unsubscribe, if needed
      @unsubscribe subscriptionKey

      # unless key and modelName are present, clear stateFields and return after unsubscribing
      unless rubyTrue(key) && modelName
        return @setStateFromModelRecord stateField, initialModelRecord || status: success, null, key

      unless model = @models[modelName]
        throw new Error "No model registered with the name: #{modelName}. Registered models:\n  #{Object.keys(@models).join "\n  "}"

      modelKey = model.toKeyString key

      subscriptionFunction = (modelRecord) =>
        updatesCallback? modelRecord
        @setStateFromModelRecord stateField, modelRecord, null, key

      @_subscriptions[subscriptionKey] = {modelName, modelKey, subscriptionFunction}

      # NOTE: subscriptionFunction is the 'handle' needed later to unsubscribe from the store
      @setStateFromModelRecord stateField,
        store.subscribe modelName, modelKey, subscriptionFunction, initialModelRecord
        initialModelRecord
        key

    ###
      IN: same as @subscribe
      OUT: promise.then -> # subscription has been created
      USE:
        Primarilly useful for models which want to subscribe to
        other models when they are constructed. This solves the
        loading-order problem.
    ###
    subscribeOnModelRegistered: (subscriptionKeyOrOptions, modelName, modelKey, options) ->
      if isPlainObject subscriptionKeyOrOptions
        {modelName} = subscriptionKeyOrOptions

      ModelRegistry.onModelRegistered modelName
      .then => @subscribe subscriptionKeyOrOptions, modelName, modelKey, options

    ################################
    # Unsubscribe
    ################################
    unsubscribe: (subscriptionKey)->
      if subscription = @_subscriptions[subscriptionKey]
        {subscriptionFunction, modelName, modelKey} = subscription
        store.unsubscribe modelName, modelKey, subscriptionFunction
        delete @_subscriptions[subscriptionKey]
      null

    unsubscribeAll: ->
      for subscriptionKey, __ of @_subscriptions
        @unsubscribe subscriptionKey
      null

    ################################
    # Helpers
    ################################
    getRetryNow = (modelName, key) ->
      ->
        store._getEntry modelName, key
        .reload()

    setStateFromModelRecord: (stateField, modelRecord, initialModelRecord, key) ->
      if modelRecord?.status != success && initialModelRecord?.status == success
        modelRecord = initialModelRecord

      if stateField && isFunction @setState
        {status = null, progress = null, data = null} = modelRecord if modelRecord
        @setState stateField, data
        @setState stateField + "Key",       key ? modelRecord.key
        @setState stateField + "Status",    status
        @setState stateField + "Progress",  progress
        @setState stateField + "FailureInfo",
          if modelRecord && isFailure status
            {reloadAt, tryCount, modelName, key} = modelRecord
            {reloadAt, tryCount, status, retryNow: getRetryNow modelName, key}
          else null

      modelRecord
