Uuid = require 'uuid'

Foundation = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'

{log, merge, Validator, isString, arrayToTruthMap, isFunction} = Foundation
{Pipeline} = ArtEry
{DynamoDb} = ArtAws
{encodeDynamoData, decodeDynamoData} = DynamoDb

module.exports = class DynamoDbPipeline extends Pipeline
  @classGetter
    tablesByNameForVivification: ->
      @_tablesByNameForVivificationPromise ||=
        @getDynamoDb().listTables().then ({TableNames}) =>
          arrayToTruthMap TableNames

    dynamoDb: -> DynamoDb.singleton

  @createTablesForAllRegisteredPipelines: ->
    promises = for name, pipeline of ArtEry.pipelines when isFunction pipeline.createTable
      pipeline.createTable()
    Promise.all promises

  @globalIndexes: (globalIndexes) -> @_globalIndexes = globalIndexes

  @getter
    globalIndexes: -> @_options.globalIndexes || @class._globalIndexes

  getAutoDefinedQueries: ->
    {globalIndexes} = @
    return {} unless globalIndexes
    queries = {}

    for queryModelName, indexKey of globalIndexes when isString indexKey
      do (queryModelName, indexKey) =>
        [hashKey, sortKey] = indexKey.split "/"
        whereClause = {}
        queries[queryModelName] =
          query: (hashKeyValue, pipeline) ->
            whereClause[hashKey] = hashKeyValue
            pipeline.queryDynamoDb
              index: queryModelName
              where: whereClause
            .then ({items}) -> items
          queryKeyFromRecord: (data) ->
            log queryKeyFromRecord: data: data, hashKey: hashKey, value: data[hashKey]
            data[hashKey]
          localSort: (queryData) -> queryData.sort (a, b) -> a[sortKey] - b[sortKey]

    queries

  @getter
    dynamoDb: -> DynamoDb.singleton
    tablesByNameForVivification: -> DynamoDbPipeline.getTablesByNameForVivification()

  ###
  TODO:
  Add to ArtAws.DynamoDb:
    getKeyFromDataFunction: (createTableParams) -> (data) -> key
      IN: createTableParams
        The exact same params used to create the table.
      OUT: (data) -> key
        IN: data: plain object record data
        OUT: key: string which encodes the key
          if there is no range-key, then just returns the hashKey as a string
          else, "#{hashKey}/#{rangeKey}"

    Initially, though, I expect all tables to have a simple hashKey: 'id'
    Indexes will take care of most our rangeKey needs.
  ###

  queryDynamoDb: (params) ->
    @dynamoDb.query merge params, table: @tableName

  @handlers
    get: ({key}) ->
      @dynamoDb.getItem
        table: @tableName
        key: id: key
      .then ({item}) ->
        item

    createTable: ->
      @_vivifyTable()
      .then => message: "success"

    create: ({data}) ->
      @dynamoDb.putItem
        table: @tableName
        item: data
      .then ->
        data

    update: ({key, data}) ->
      @dynamoDb.updateItem
        table: @tableName
        key: id: key
        item: data
      .then ({item}) ->
        item

    delete: ({key}) ->
      @dynamoDb.deleteItem
        TableName: @tableName
        Key: id: S: key
      .then => message: "success"

  #########################
  # PRIVATE
  #########################

  _vivifyTable: ->
    @_vivifyTablePromise ||= Promise.resolve().then =>
      log "DynamoDbPipeline#_vivifyTable: #{@tableName}"
      @tablesByNameForVivification
      .then (tablesByName) =>
        if tablesByName[@tableName]
          log "#{@getClassName()}#_vivifyTable() dynamoDb table exists: #{@tableName}"
        else
          log "#{@getClassName()}#_vivifyTable() dynamoDb table does not exist: #{@tableName}"
          @_createTable()


  @getter
    dynamoDbCreationAttributes: ->
      out = {}
      for k, v of @normalizedFields
        if v.dataType == "string" || v.dataType == "number"
          out[k] = v.dataType
      out
    createTableParams: ->
      ArtAws.StreamlinedDynamoDbApi.CreateTable.translateParams merge
        table: @tableName
        globalIndexes: @globalIndexes
        attributes: @dynamoDbCreationAttributes
        @_options

  _createTable: ->

    @dynamoDb.createTable(merge
        table: @tableName
        globalIndexes: @globalIndexes
        attributes: @dynamoDbCreationAttributes
        @_options
      )
    .then (data) =>
      log "DynamoDbPipeline#_createTable #{@tableName} success!"
    .catch (e) =>
      log "DynamoDbPipeline#_createTable #{@tableName} FAILED", e
      throw e


