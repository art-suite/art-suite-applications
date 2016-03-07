{log, BaseObject, decapitalize, isClass, inspect} = require "art-foundation"

module.exports = class ModelRegistry extends BaseObject
  @models: models = {}

  # returns the singleton
  @register: (modelClassOrInstance) ->

    newSingleton = if isClass modelClassOrInstance
      console.warn "ModelRegistry.register Class (not instance) is DEPRICATED"
      {_aliases} = modelClassOrInstance
      new modelClassOrInstance
    else
      {_aliases} = modelClassOrInstance.class
      modelClassOrInstance

    _aliases && for alias in _aliases
      models[alias] = newSingleton

    models[newSingleton.name] = newSingleton

  @_singletonName: (model) -> decapitalize model.name

  # used for testing
  @_reset: ->
    for k in Object.keys models
      delete models[k]
