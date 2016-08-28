Foundation = require 'art-foundation'
Flux = require 'art-flux'
ArtEry = require 'art-ery'

{
  log
  CommunicationStatus
  select
  isString
  isFunction
  decapitalize
  merge
  Promise
  eq
  upperCamelCase
  arrayWith
  arrayWithElementReplaced
  formattedInspect
} = Foundation

{missing, failure, success, pending} = CommunicationStatus

{FluxModel} = Flux

class ArtEryQueryFluxModel extends FluxModel
  ###
  This class is designed to be extended with overrides:

  ###
  constructor: ->
    super null
    @register()

  loadData: (key) ->
    Promise.resolve @query key, @pipeline

  @setter "recordsModel pipeline"
  @getter "recordsModel pipeline"

  ###
  OVERRIDE
  IN: will be the key (returned from fromFluxKey)
  OUT: array of singleModel records
    OR promise.then (arrayOfRecords) ->
  TODO:
    In the future we may wish to return other things beyond the array of records.
    Example:
      DynamoDb returns data for "getting the next page of records" in addition to the records.
      DynamoDb also returns other interesting stats about the query.

    If an array is returned, it will always be records. However, if an object is
    returned, then one of the fields will be records - and will go through the return
    pipeline, but the rest will be left untouched and placed in the FluxRecord's data field.
    Or should they be put in an auxiliary field???
  ###
  query: (key) -> []

  ###
  OVERRIDE
  IN: single record
  OUT: string key for the query results that should contain this record
  ###
  queryKeyFromRecord: (record) -> ""

  ###
  OVERRIDE
  override for to sort records when updating local query data in response to local record changes
  ###
  localSort: (queryKey, queryData) -> queryData

  ###
  OVERRIDE
  override for custom merge
  This implementation is a streight-up merge using @recordsModel.keysEqual

  IN:
    previousQueryData: array of records or null
    updatedRecordData: single record or null
  OUT: return preciousQueryData if nothing changed, else return a new array
  ###
  localMerge: (previousQueryData, updatedRecordData) ->
    return previousQueryData unless updatedRecordData
    return [updatedRecordData] unless previousQueryData?.length > 0

    for el, i in previousQueryData
      if @recordsModel.keysEqual el, updatedRecordData
        return arrayWithElementReplaced previousQueryData, updatedRecordData, i

    arrayWith previousQueryData, updatedRecordData

  ###
  OVERRIDE
  localUpdate gets called whenever whenever a fluxStore entry is created or updated for the recordsModel.

  Can override for custom behavior!

  This implementation assumes there is only one possible query any particular record will belong to,
  and it assumes the queryKey can be computed via @queryKeyFromRecord.

  NOTE: @queryKeyFromRecord must be implemented!
  ###
  localUpdate: (updatedRecordData) ->
    return unless updatedRecordData
    queryKey = @queryKeyFromRecord? updatedRecordData
    throw new Error "invalid queryKey from #{formattedInspect updatedRecordData}" unless isString queryKey
    return unless fluxRecord = @fluxStoreGet queryKey
    @updateFluxStore queryKey, data: @localSort @localMerge fluxRecord.data, updatedRecordData

module.exports = class ArtEryFluxModel extends FluxModel

  @pipeline: (@_pipeline) ->
    @register()
    @_pipeline.tableName = @getName()
    @_pipeline

  @getter "pipeline"

  constructor: ->
    super
    @_updateSerializers = {}
    @_pipeline = @class._pipeline
    @queries @_pipeline.queries
    @actions @_pipeline.actions

  keyFromData: (data) -> @_pipeline.keyFromData data
  keysEqual: (a, b) -> eq @keyFromData(a), @keyFromData(b)

  ###
  TODO:
  queries need to go through an ArtEry pipeline.
  queries should be invoked with that ArtEry pipeline as @
  every record returned should get sent through the after-pipeline
  as-if it were a "get" request
  ###
  queries: (map) ->
    @_queryModels = for modelName, options of map
      if isFunction options
        options = query: options
      {_pipeline} = @
      recordsModel = @
      throw new Error "query required" unless isFunction options.query

      new class ArtEryQueryFluxModelChild extends ArtEryQueryFluxModel
        @_name: upperCamelCase modelName

        @::[k] = v for k, v of options
        _pipeline: _pipeline
        _recordsModel: recordsModel

  ###
  TODO:
  actions need to go through an ArtEry pipeline.
  actions should be invoked with that ArtEry pipeline as @
  ###
  actions: (map) ->
    for actionName, action of map
      @[actionName] = action

  ###
  IN: key: string
  OUT:
    promise.then (data) ->
    promise.catch (response with .status and .error) ->
  ###
  load: (key) ->
    throw new Error "invalid key: #{inspect key}" unless isString key
    @_getUpdateSerializer key
    .updateFluxStore =>
      @_pipeline.get key
    false

  create: (data) ->
    @_pipeline.create data
    .then (data) =>
      @updateFluxStore @keyFromData(data),
        status: success
        data: data

  ###
  Purpose:
    Allows multiple in-flight updates to update the flux-store with every success or failure
    to the current-best-known state of the remote record.
  Usage:
    updateSerializer = @_getUpdateSerializer key
    updateSerializer.updateFluxStore (accumulatedSuccessfulUpdatesToData) =>
      return updated data
    Effects:
      - after the returned, updated data is resolved, @updateFluxStore is called
      - calls to updateFluxStore are serialized:
        - each is executed and fluxStore is updated before the next

  Internal Notes:
    - auto vivifies
    When allDone:
    - removed from @_updateSerializers
  ###
  _getUpdateSerializer: (key) ->
    unless updateSerializer = @_updateSerializers[key]
      updateSerializer = new Promise.Serializer
       #prime the serializer with the current fluxRecord.data
      updateSerializer.then => @fluxStoreGet(key)?.data || {}
      updateSerializer.updateFluxStore = (updateFunction) =>
        updateSerializer.then (data) =>
          Promise.resolve updateFunction data
          .catch -> data # on error, roll back flux-Store to the last known-good data
          .then (data) =>
            @updateFluxStore key, status: success, data: data
            data
        updateSerializer

    updateSerializer.allDonePromise().then (accumulatedSuccessfulUpdatesToData) =>
      delete @_updateSerializers[key]
    updateSerializer

  _updateQueries: (updatedRecord) ->
    queryModel.localUpdate updatedRecord for queryModel in @_queryModels
    null

  fluxStoreEntryUpdated: ({key, fluxRecord}) ->
    @_updateQueries fluxRecord.data

  _optimisticallyUpdateFluxStore: (key, fieldsToUpdate) ->
    # apply local update immediately
    # This optimistically updates the local copy assuming all updates will succeed
    @updateFluxStore key,
      (oldFluxRecord) => merge oldFluxRecord, data: merge oldFluxRecord?.data, fieldsToUpdate

  update: (key, data) ->
    throw new Error "invalid key: #{inspect key}" unless isString key

    @_optimisticallyUpdateFluxStore key, data

    ###
    creating a Promise here because we have two promise paths
    path 1: the caller of this update wants to know when this specific update
      succeeds or fails.
    path 2: the updateSerializer must continue whether or not
    ###
    new Promise (resolve, reject) =>
      @_getUpdateSerializer key
      .updateFluxStore (accumulatedSuccessfulUpdatesToData) =>
        ###
        NOTE if this update fails:

          The FluxStore record gets rolled back to the version just before this
          update was called. All pending updates after this one will be 'lost'
          in the fluxStore UNTIL, and if, those pending updates succeed. As they
          succeed, the fluxStore will be updated.

          So, technically, it isn't the MOST accurate representation if a
          previous update failed, but it will be resolved to the most accurate
          representation once all updates have completed or failed.
        ###
        ret = @_pipeline.update key, data
        .then -> merge accumulatedSuccessfulUpdatesToData, data
        ret.then resolve, reject
        ret

        ###
        NOTE: this could be done more cleanly with tapThen (see Art.Foundation.Promise)

        @_pipeline.update key, data
        .then -> merge accumulatedSuccessfulUpdatesToData, data
        .tapThen resolve, reject

        ###
