{Promise, timeout, log, formattedInspect, BaseObject, decapitalize, isClass, inspect, defineModule} = require "art-foundation"

defineModule module, class ModelRegistry extends BaseObject
  @models: global.artFluxModels = models = {}
  @_modelRegistrationPromiseResolvers: {}

  _registerModel = (name, model) ->
    if models[name]
      throw new Error "
        ArtFlux.ModelRegistry: model already registered for name: '#{name}'.
        #{formattedInspect alreadyRegisteredModel: models[name], attemptingToRegisterModel: model, name: name}
        "
    # timeout().then -> log "ArtFlux model registered: #{name}, (#{formattedInspect model})"
    models[name] = model

  # returns the singleton
  @register: (model) =>

    {modelName} = model

    for alias in model.class._aliases
      _registerModel alias, model

    _registerModel modelName, model

    @_modelRegistered model

  @_modelRegistered: (model) ->
    {modelName} = model
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
