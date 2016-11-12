Uuid = require 'uuid'

Foundation = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'

{isPlainObject, inspect, log, merge, compare, Validator, isString, arrayToTruthMap, isFunction, withSort} = Foundation
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

  @firstAbstractAncestor: @

  @createTablesForAllRegisteredPipelines: ->
    promises = for name, pipeline of ArtEry.pipelines when isFunction pipeline.createTable
      pipeline.createTable()
    Promise.all promises

  @globalIndexes: (globalIndexes) ->
    @_globalIndexes = globalIndexes
    @query @_getAutoDefinedQueries globalIndexes

  @getter
    globalIndexes: -> @_options.globalIndexes || @class._globalIndexes
    status: ->
      @_vivifyTable()
      .then -> "OK: table exists and is reachable"
      .catch -> "ERROR: could not connect to the table"



  @_getAutoDefinedQueries: (globalIndexes) ->
    return {} unless globalIndexes
    queries = {}

    for queryModelName, indexKey of globalIndexes when isString indexKey
      do (queryModelName, indexKey) =>
        [hashKey, sortKey] = indexKey.split "/"
        whereClause = {}
        queries[queryModelName] =
          query: (request) ->
            whereClause[hashKey] = request.key
            request.pipeline.queryDynamoDb
              index: queryModelName
              where: whereClause
            .then ({items}) -> items

          queryKeyFromRecord: (data) ->
            # log queryKeyFromRecord: data: data, hashKey: hashKey, value: data[hashKey]
            data[hashKey]

          localSort: (queryData) -> withSort queryData, (a, b) ->
            if 0 == ret = compare a[sortKey], b[sortKey]
              compare a.id, b.id
            else
              ret


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

  scanDynamoDb: (params) ->
    @dynamoDb.scan merge params, table: @tableName

  @handlers
    get: (request) ->
      {key} = request
      throw new Error "DynamoDbPipeline#get: key must be a string. key = #{inspect key}" unless isString key
      @dynamoDb.getItem
        table: @tableName
        key: id: key
      .then (result) ->
        if result.item
          result.item
        else
          request.missing()

    createTable: ->
      @_vivifyTable()
      .then => message: "success"

    create: ({data}) ->
      throw new Error "DynamoDbPipeline#create: data must be an object. data = #{inspect data}" unless isPlainObject data
      @dynamoDb.putItem
        table: @tableName
        item: data
      .then ->
        data

    update: ({key, data}) ->
      throw new Error "DynamoDbPipeline#update: key must be a string. key = #{inspect key}" unless isString key
      throw new Error "DynamoDbPipeline#update: data must be an object. data = #{inspect data}" unless isPlainObject data
      @dynamoDb.updateItem
        table: @tableName
        key: id: key
        item: data
      .then ({item}) ->
        item

    delete: ({key}) ->
      throw new Error "DynamoDbPipeline#delete: key must be a string. key = #{inspect key}" unless isString key
      @dynamoDb.deleteItem
        TableName: @tableName
        Key: id: S: key
      .then => message: "success"

  #########################
  # PRIVATE
  #########################

  _vivifyTable: ->
    @_vivifyTablePromise ||= Promise.resolve().then =>
      @tablesByNameForVivification
      .then (tablesByName) =>
        unless tablesByName[@tableName]
          log "#{@getClassName()}#_vivifyTable() dynamoDb table does not exist: #{@tableName}, creating..."
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
    .catch (e) =>
      log "DynamoDbPipeline#_createTable #{@tableName} FAILED", e
      throw e


