{
  log
  select
  isString
  isArray
  isFunction
  decapitalize
  merge
  Promise
  eq
  upperCamelCase
  arrayWith
  arrayWithElementReplaced
  formattedInspect
  propsEq
  arrayWithout
  defineModule
} = require 'art-standard-lib'
{missing, success, pending} = require "art-communication-status"
{KeyFieldsMixin} = require "art-ery"
{FluxModel} = require '@art-suite/art-flux'

defineModule module, class ArtEryQueryFluxModel extends KeyFieldsMixin FluxModel
  @abstractClass()

  loadData: (key) ->
    Promise.resolve @query key, @pipeline
    .then (data) => @localSort data

  @getter "recordsModel pipeline queryName"

  #########################
  # OVERRIDEABLES
  #########################
  ###
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
  query: (key) -> @_pipeline[@_queryName] key: key, props: include: "auto"

  ###
    override for to sort records when updating local query data in response to local record changes
  ###
  localSort: (queryData) -> queryData

  ###
    override for custom merge
    This implementation is a streight-up merge using @recordsModel.dataHasEqualKeys

    IN:
      previousQueryData: array of records or null
      updatedRecordData: single record or null
    OUT: return null if nothing changed, else return a new array
  ###
  localMerge: (previousQueryData, updatedRecordData, wasDeleted) ->
    previousQueryData ?= []
    return previousQueryData unless updatedRecordData || wasDeleted
    return previousQueryData unless !previousQueryData? || isArray previousQueryData

    unless previousQueryData?.length > 0
      return if wasDeleted then [] else [updatedRecordData]

    updatedRecordDataKey = @recordsModel.toKeyString updatedRecordData

    for currentRecordData, i in previousQueryData
      if updatedRecordDataKey == @recordsModel.toKeyString currentRecordData
        return if wasDeleted
          # deleted >> remove from query
          arrayWithout previousQueryData, i
        else if propsEq currentRecordData, updatedRecordData
          # no change >> no update
          log "saved 1 fluxStore update due to no-change check! (model: #{@name}, record-key: #{updatedRecordDataKey})"
          null
        else
          # change >> replace with newest version
          arrayWithElementReplaced previousQueryData, updatedRecordData, i

    # updatedRecordData wasn't in previousQueryData
    if wasDeleted
      previousQueryData
    else
      arrayWith previousQueryData, updatedRecordData

  ###############################
  # FluxModel overrides
  ###############################
  ###
    ArtEryFluxModel calls dataUpdated and dataDeleted from its
    dataUpdated and dataDeleted functions, respectively.
  ###
  dataUpdated: (queryKey, singleRecordData) ->
    @_updateFluxStoreIfExists queryKey, singleRecordData

  dataDeleted: (queryKey, singleRecordData) ->
    @_updateFluxStoreIfExists queryKey, singleRecordData, true

  ###############################
  # Private
  ###############################
  _updateFluxStoreIfExists: (queryKey, singleRecordData, wasDeleted) ->
    if @getModelRecord queryKey
      @updateModelRecord queryKey, (oldFluxRecord) =>
        if merged = @localMerge oldFluxRecord.data, singleRecordData, wasDeleted
          merge oldFluxRecord, data: @localSort merged

        else
          oldFluxRecord
