Foundation = require 'art-foundation'
FluxCore = require '../core'
VolatileStore = require './volatile_store'
VolatileQueryModel = require './volatile_query_model'
FluxDb = require '../db'

{defineModule, log, BaseObject, decapitalize, pluralize} = Foundation
{FluxStore, FluxModel, ModelRegistry} = FluxCore
{volatileStore} = VolatileStore
{fluxStore} = FluxStore
{FluxDbModel} = FluxDb

defineModule module, class VolatileModel extends FluxDbModel
  @queryModel: VolatileQueryModel

  constructor: ->
    super
    @_queriesToUpdate = [
      (fields) => @_updateQuery @, "" # all query
    ]

    volatileStore.init @name

  _storeGet:  (id, callback)         -> volatileStore.get  @name, id, callback
  _storePut:  (id, fields, callback) -> volatileStore.put  @name, id, fields, callback
  _storePost: (fields, callback)     -> volatileStore.post @name, fields,     callback

  #######################
  # PRIVATE
  #######################
  _updateQueries: (fields) ->
    fluxStore.onNextReady =>
      f fields for f in @_queriesToUpdate

  # only update the query if its results are in the fluxStore
  _updateQuery: (model, id) ->
    if fluxStore.get model.name, id
      model.load id
