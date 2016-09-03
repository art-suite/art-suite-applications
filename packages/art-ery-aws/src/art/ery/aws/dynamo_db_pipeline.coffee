Uuid = require 'uuid'

Foundation = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'

{log, merge, Validator, isString, arrayToTruthMap} = Foundation
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

  constructor: (options = {}) ->
    super

    @_createTableParams = options
    @_vivifyTablePromise = Promise.resolve()
    @_vivifyTable()

  getAutoDefinedQueries: ->
    {globalIndexes} = @_createTableParams
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
    @_vivifyTablePromise.then =>
      @dynamoDb.query merge params, table: @tableName

  @handlers
    get: ({key}) ->
      @_vivifyTablePromise.then =>
        @dynamoDb.getItem
          table: @tableName
          key: id: key
      .then ({item}) ->
        item

    create: ({data}) ->
      @_vivifyTablePromise.then =>
        @dynamoDb.putItem
          table: @tableName
          item: data
      .then ->
        data

    update: ({key, data}) ->
      @_vivifyTablePromise.then =>
        @dynamoDb.updateItem
          table: @tableName
          key: id: key
          item: data
      .then ({item}) ->
        item

    delete: ({key}) ->
      @_vivifyTablePromise.then =>
        @dynamoDb.deleteItem
          TableName: @tableName
          Key: id: S: key
      .then => message: "success"

  #########################
  # PRIVATE
  #########################

  _vivifyTable: ->
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
      for k, v of @fields
        if isString v
          unless v = Validator.fieldTypes[v]
            throw new Error "invalid field type: #{v}"
        if v.type == "string" || v.type == "number"
          out[k] = v.type
      out


  _createTable: ->
    log "_createTable #{@tableName} 1"
    @dynamoDb.createTable(merge
        table: @tableName
        attributes: @dynamoDbCreationAttributes
        @_createTableParams
      )
    .then =>
      log "_createTable #{@tableName} done"

