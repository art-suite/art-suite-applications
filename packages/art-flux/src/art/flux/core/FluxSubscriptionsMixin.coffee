{isString, defineModule, log, BaseObject, nextTick, mergeInfo, capitalize, globalCount, time} = require 'art-foundation'
{fluxStore} = require '../core/flux_store'
ModelRegistry = require '../core/model_registry'

defineModule module, -> (superClass) ->
  class FluxSubscriptionsMixin extends superClass
    constructor: ->
      super
      @_subscriptions = {}

    @getter
      models: -> ModelRegistry.models

    getSubscriptions: -> @_subscriptions

    @_combinedKey: combinedKey = (model, fluxKey, stateField) ->
      "#{model.name}/#{stateField}/#{fluxKey}"

    subscribe: (model, fluxKey, stateField, initialFluxRecord) ->
      model = @models[model] if isString model

      ckey = combinedKey model, fluxKey, stateField
      @setStateFromFluxRecord stateField, if @_subscriptions[ckey]
        console.error "already subscribed"
        fluxStore.get model.name, fluxKey
      else
        @_subscriptions[ckey] =
          fluxKey: fluxKey
          model: model
          subscriptionFunction: subscriptionFunction = (fluxRecord, subscribers) =>
            @setStateFromFluxRecord stateField, fluxRecord

        fluxStore.subscribe model.name, fluxKey, subscriptionFunction, initialFluxRecord

    unsubscribe: (model, fluxKey, stateField)->
      ckey = combinedKey model, fluxKey, stateField
      if subscription = @_subscriptions[ckey]
        fluxStore.unsubscribe model.name, fluxKey, subscription.subscriptionFunction
        delete @_subscriptions[ckey]

    setStateFromFluxRecord: (baseField, fluxRecord) ->
      @setState baseField, fluxRecord?.data
      @setState baseField + "Status", fluxRecord.status   if fluxRecord.status
      @setState baseField + "Progress", fluxRecord.progress if fluxRecord.progress?
      @setState baseField + "FluxRecord", fluxRecord

    unsubscribeAll: ->
      for ckey, {model, fluxKey, subscriptionFunction} of @_subscriptions
        fluxStore.unsubscribe model.name, fluxKey, subscriptionFunction
      @_subscriptions = {}
