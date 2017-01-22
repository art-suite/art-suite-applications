{isString, defineModule, log, BaseObject, nextTick, mergeInfo, capitalize, globalCount, time} = require 'art-foundation'
{fluxStore} = require './FluxStore'
ModelRegistry = require './ModelRegistry'

defineModule module, -> (superClass) ->
  class FluxSubscriptionsMixin extends superClass
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
    subscribe: (model, fluxKey, stateField, {initialFluxRecord, updatesCallback} = {}) ->
      if isString modelName = model
        unless model = @models[modelName]
          throw new Error "No model registered with the name: #{modelName}. Registered models:\n  #{Object.keys(@models).join "\n  "}"

      combinedKey = getCombinedKey model, fluxKey, stateField
      @setStateFromFluxRecord stateField, if @_subscriptions[combinedKey]
        console.error "already subscribed"
        fluxStore.get model.name, fluxKey
      else
        @_subscriptions[combinedKey] =
          fluxKey: fluxKey
          model: model
          subscriptionFunction: subscriptionFunction = (fluxRecord, subscribers) =>
            updatesCallback? fluxRecord
            @setStateFromFluxRecord stateField, fluxRecord

        fluxStore.subscribe model.name, fluxKey, subscriptionFunction, initialFluxRecord

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
    # Update State
    ################################
    setStateFromFluxRecord: (baseField, fluxRecord) ->
      @setState baseField, fluxRecord?.data
      @setState baseField + "Status",   fluxRecord.status   if fluxRecord.status
      @setState baseField + "Progress", fluxRecord.progress if fluxRecord.progress?

    ################################
    # PRIVATE
    ################################
    @_getCombinedKey: getCombinedKey = (model, fluxKey, stateField) ->
      "#{model.name}/#{stateField}/#{fluxKey}"
