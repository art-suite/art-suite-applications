{Promise, log, BaseObject, decapitalize, isClass, inspect, defineModule} = require "art-foundation"

defineModule module, class ModelRegistry extends BaseObject
  @models: models = {}
  @_modelRegistrationPromiseResolvers: {}

  # returns the singleton
  @register: (modelClassOrInstance) ->

    model = if isClass modelClassOrInstance
      log.warn "ModelRegistry.register Class (not instance) is DEPRICATED"
      {_aliases} = modelClassOrInstance
      new modelClassOrInstance
    else
      {_aliases} = modelClassOrInstance.class
      modelClassOrInstance

    _aliases && for alias in _aliases
      models[alias] = model

    models[modelName = model.name] = model

    if resolvers = @_modelRegistrationPromiseResolvers[modelName]
      resolve model for resolve in resolvers

    model

  # OUT: promise.then (model) -> model has been registered
  # GUARANTEE: Will fire exactly once, unless the model is never registered.
  # NOTE: This means it will fire, once, even if the model was already registered.
  @onModelRegistered: (modelName) ->
    new Promise (resolve, reject) =>
      if model = @models[modelName]
        resolve model
      else
        (@_modelRegistrationPromiseResolvers[modelName] ||= []).push resolve

  @_singletonName: (model) -> decapitalize model.name

  # used for testing
  @_reset: ->
    for k in Object.keys models
      delete models[k]
