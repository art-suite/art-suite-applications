Foundation = require 'art-foundation'
FluxCore = require '../core'
{FluxStore, FluxStatus} = FluxCore
{success, missing} = FluxStatus

{BaseObject, mergeInfo, log, clone, slice, merge, arrayWithOne} = Foundation
{fluxStore} = FluxStore

simulateAsyncRequest = (asyncCallback) ->
  fluxStore.onNextReady asyncCallback
  null

module.exports = class VolatileStore extends BaseObject
  @singletonClass()

  constructor: ->
    super
    @_reset()

  _reset: ->
    @_nextId = 0
    @_db = {}

  init: (listUri) ->
    @_list listUri

  get: (modelPrefix, id, requestStatusCallback) ->
    simulateAsyncRequest =>
      dbKey = getDbKey modelPrefix, id

      requestStatusCallback if res = clone @_db[dbKey]
        status: success
        data: res
      else
        status: missing

  put: (modelPrefix, id, fields, requestStatusCallback) ->
    simulateAsyncRequest =>
      dbKey = getDbKey modelPrefix, id

      requestStatusCallback
        status: success
        data: clone @_setSingle modelPrefix, id, dbKey, merge @_db[dbKey], fields

  post: (modelPrefix, fields, requestStatusCallback) ->
    simulateAsyncRequest =>
      id = (@_nextId++).toString()
      dbKey = getDbKey modelPrefix, id

      requestStatusCallback
        status: success
        data: clone @_setSingle modelPrefix, id, dbKey, fields

  #######################################
  # PRIVATE
  #######################################
  @_getDbKey: getDbKey = (modelPrefix, id) ->
    if id && id.length > 0
      modelPrefix + "/" + id
    else
      modelPrefix

  _setSingle: (modelPrefix, id, dbKey, fields) ->
    # if modelPrefix == "__volatileStore/feed"
      # log volatileStore: _setSingle:
      #   modelPrefix: modelPrefix
      #   id: id
      #   dbKey: dbKey
      #   fields: fields
      #   list: @_list(modelPrefix)
    @_list(modelPrefix)[id] = @_db[dbKey] = merge fields, id: id

  _list: (modelPrefix) ->
    @_db[modelPrefix] ||= {}
