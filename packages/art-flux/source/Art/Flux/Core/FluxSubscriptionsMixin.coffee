{isString, defineModule, log, BaseObject, nextTick, mergeInfo, capitalize, globalCount, time} = require 'art-foundation'
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
    IN:
      model: lowerCamelCase model name
      fluxKey: the flux key
      stateField: string or null. If set, will call @setStateFromFluxRecord stateField, fluxRecord with changes
      options:
        # a) initialize fluxStore with initialFluxRecord, if there isn't already a fluxRecord with fluxKey
        # b) immediate @setStateFromFluxRecord stateField, initialFluxRecord
        initialFluxRecord:

        # get callbacks with every change
        updatesCallback:  (fluxRecord) -> ignored
    ###
    subscribe: (model, fluxKey, stateField, {initialFluxRecord, updatesCallback} = {}) ->
      if isString modelName = model
        unless model = @models[modelName]
          throw new Error "No model registered with the name: #{modelName}. Registered models:\n  #{Object.keys(@models).join "\n  "}"

      combinedKey = getCombinedKey model, fluxKey, stateField
      @setStateFromFluxRecord stateField, if @_subscriptions[combinedKey]
        # already subscribed
        fluxStore.get model.name, fluxKey
      else
        # new subscription
        @_subscriptions[combinedKey] =
          fluxKey: fluxKey
          model: model
          subscriptionFunction: subscriptionFunction = (fluxRecord, subscribers) =>
            updatesCallback? fluxRecord
            @setStateFromFluxRecord stateField, fluxRecord

        fluxStore.subscribe model.name, fluxKey, subscriptionFunction, initialFluxRecord

      null

    ###
    OUT: promise.then -> # subscription has been created
    USE:
      Primarilly useful for models which want to subscribe to
      other models when they are constructed. This solves the
      loading-order problem.
    ###
    subscribeOnModelRegistered: (modelName, fluxKey, stateField, options) ->
      ModelRegistry.onModelRegistered modelName
      .then (model)=> @subscribe model, fluxKey, stateField, options

    ################################
    # Unsubscribe
    ################################
    unsubscribe: (model, fluxKey, stateField)->
      combinedKey = getCombinedKey model, fluxKey, stateField
      if subscription = @_subscriptions[combinedKey]
        fluxStore.unsubscribe model.name, fluxKey, subscription.subscriptionFunction
        delete @_subscriptions[combinedKey]

    unsubscribeAll: ->
      for combinedKey, {model, fluxKey, subscriptionFunction} of @_subscriptions
        fluxStore.unsubscribe model.name, fluxKey, subscriptionFunction
      @_subscriptions = {}

    ################################
    # Helpers
    ################################
    setStateFromFluxRecord: (baseField, fluxRecord) ->
      return unless baseField
      @setState baseField, fluxRecord?.data
      @setState baseField + "Status",   fluxRecord.status   if fluxRecord.status
      @setState baseField + "Progress", fluxRecord.progress if fluxRecord.progress?

    ################################
    # PRIVATE
    ################################
    @_getCombinedKey: getCombinedKey = (model, fluxKey, stateField) ->
      "#{model.name}/#{stateField}/#{fluxKey}"
