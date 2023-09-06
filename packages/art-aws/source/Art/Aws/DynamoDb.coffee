###
Local Web Console / Shell: http://localhost:8081/shell/

The AWS DynamoDb API is redundent and uses UpperCamelCase names all over.

Goals:
  create a wrapper API which:

  - elliminates redundencies
  - uses lowerCamelCase key names for JavaScript naming convention compatibility.

Strategy:
  Incremental. Not all commands will be updated to the "new" api.
  Instead, the API will always accept the unfiltered DynamoDb API with UpperCamelCase names.
  As I can, I'll create a lowerCamelCase API for each commant.

lowerCamelCase API:

METHODS
  createTable
    attributes:     # see translateAttributes
    key:            # see translateKey
    provisioning:   # see translateProvisioning
    globalIndexes:  # see
    localIndexes:

HELPERS
  translateAttributes
    attributes:
      myHashKeyName:    'string'
      myRangeKeyName:   'string'
      myNumberAttrName: 'number'
      myBinaryAttrName: 'binary'

  translateKey
    key:
      myHashKeyName:  'hash'
      myRangeKeyName: 'range'

      OR: "hashKeyField"
      OR: "hashKeyField/rangeKeyField"
        NOTE: you can use any string format that matches /[_a-zA-Z0-9]+/g

  translateProvisioning
    provisioning:
      read: 5
      write: 5

  translateGlobalIndexes
    globalIndexes:
      myIndexName:
        "hashKey"           # see translateKey
        "hashKey/rangeKey"  # see translateKey

        OR

        key:          # see translateKey
        projection:   # see translateProjection
        provisioning: # see translateProvisioning

  translateLocalIndexes
    localIndexes:
      myIndexName:
        "hashKey"           # see translateKey
        "hashKey/rangeKey"  # see translateKey

        OR

        key:          # see translateKey
        projection:   # see translateProjection
###

{
  merge
  isPlainObject, isPlainArray, isBoolean, isString, isNumber, inspect
  capitalize
  decapitalize
  lowerCamelCase
  wordsArray
  array
  log
  eq
  formattedInspect
  objectHasKeys
  Promise
  objectDiff
  objectDiffReport
  object
  diff
  objectKeyCount
  each
} = require 'art-standard-lib'
{BaseClass} = require 'art-class-system'

{config} = Config = require "./Config"

StreamlinedDynamoDbApi = require './StreamlinedDynamoDbApi'

{
  Scan, Query, CreateTable, PutItem, UpdateItem, DeleteItem, GetItem, TableApiBaseClass
  BatchGetItem
} = StreamlinedDynamoDbApi
{decodeDynamoItem} = TableApiBaseClass

module.exports = class DynamoDb extends BaseClass
  @singletonClass()

  constructor: (options = {}) ->
    @_awsDynamoDb = new AWS.DynamoDB merge Config.getNormalizedConfig "dynamoDb", options

  nonInternalErrorsRegex = /ConditionalCheckFailedException|ResourceNotFoundException/
  invokeAws: (name, params) ->
    Promise.withCallback (callback) => @_awsDynamoDb[name] params, callback
    .catch (error) =>
      if config.verbose || !nonInternalErrorsRegex.test error.message
        log.error "Art.Aws.DynamoDb": {
          method: name
          status: "request was rejected"
          message: error.message
          verbose: config.verbose
          params
          error
        }
      throw error

  @bindAll: (map) ->
    for name, customMethod of map
      do (name, customMethod) =>
        @::[name] = customMethod || (params) -> @invokeAws name, params

  @bindAll
    createTable: (params) ->
      try
        @invokeAws "createTable",
          CreateTable.translateParams merge
            attributes: id: 'string'
            key:        id: 'hash'

            params
      catch e
        log createTableInputParams: params
        throw e

    createNewGlobalSecondaryIndexes: (createTableParams) ->
      {TableName} = TableApiBaseClass.translateParams createTableParams

      Promise.all([
        @getTableChanges createTableParams
        @getTableStatus createTableParams
      ]).then ([{GlobalSecondaryIndexes}, {TableStatus}]) =>
        {added} = GlobalSecondaryIndexes if GlobalSecondaryIndexes
        return info: "no new GlobalSecondaryIndexes" unless 0 < objectKeyCount added
        return info: "Can't modify indexes until TableStatus is ACTIVE" if TableStatus != "ACTIVE"
        {GlobalSecondaryIndexes, TableName, AttributeDefinitions} = CreateTable.translateParams createTableParams
        normalizedGsisByName = object GlobalSecondaryIndexes, key: (index) -> index.IndexName
        requiredAttributes = {}
        AttributeDefinitionsByName = object AttributeDefinitions,
          key: ({AttributeName}) -> AttributeName

        GlobalSecondaryIndexUpdates = array added, ({KeySchema, IndexName}) ->
          each KeySchema, ({AttributeName}) -> requiredAttributes[AttributeName] = true
          Create: normalizedGsisByName[IndexName]

        AttributeDefinitions = array requiredAttributes, (truth, key) ->
          AttributeDefinitionsByName[key]

        @invokeAws "updateTable", {TableName, GlobalSecondaryIndexUpdates, AttributeDefinitions}
        .then (info) ->
          creating: added
          info: info
      .then (out) =>
        @getTableStatus createTableParams
        .then (status) ->
          merge out, {status}

    deleteOldGlobalSecondaryIndexes: (createTableParams) ->
      {TableName} = TableApiBaseClass.translateParams createTableParams
      Promise.all([
        @getTableChanges createTableParams
        @getTableStatus createTableParams
      ]).then ([{GlobalSecondaryIndexes}, {TableStatus}]) =>
        {removed} = GlobalSecondaryIndexes if GlobalSecondaryIndexes
        return info: "no old GlobalSecondaryIndexes" unless 0 < objectKeyCount removed
        return info: "Can't modify indexes until TableStatus is ACTIVE" if TableStatus != "ACTIVE"

        GlobalSecondaryIndexUpdates = array removed, ({IndexName}) ->
          Delete: {IndexName}

        @invokeAws "updateTable", {TableName, GlobalSecondaryIndexUpdates}
        .then (info) ->
          deleting: removed
          info: info
      .then (out) =>
        @getTableStatus createTableParams
        .then (status) ->
          merge out, {status}

    ###
    IN: see Query.translateQueryParams
    OUT:
      DynamoDb standard output AND
      Same output with lowerCamelCase names:
        items: Items
        count: Count
        scannedCount: ScannedCount
        lastEvaluatedKey: LastEvaluatedKey
        consumedCapacity: ConsumedCapacity
    ###
    query: (params) ->

      @invokeAws "query",
        Query.translateParams params
      .then (res) ->
        {Items, Count, ScannedCount, LastEvaluatedKey, ConsumedCapacity} = res
        merge res,
          items: (decodeDynamoItem item for item in Items)
          count: Count
          scannedCount: ScannedCount
          lastEvaluatedKey: LastEvaluatedKey
          consumedCapacity: ConsumedCapacity

    putItem: (params) ->
      @invokeAws "putItem",
        PutItem.translateParams params
      .then (res) ->
        merge res, item: decodeDynamoItem res.Attributes

    deleteItem: (params) ->
      @invokeAws "deleteItem",
        params = DeleteItem.translateParams params
      .then (res) ->
        merge res, item: decodeDynamoItem res.Attributes

    getItem: (params) ->
      @invokeAws "getItem",
        GetItem.translateParams params
      .then (res) ->
        item: res.Item && decodeDynamoItem res.Item

    batchGetItem: (params) ->
      @invokeAws "batchGetItem",
        BatchGetItem.translateParams params
      .then (result) ->
        {table, tableName} = params
        items: (decodeDynamoItem v for v in result.Responses[table ? tableName])

    updateItem: (params) ->
      @invokeAws "updateItem",
        UpdateItem.translateParams params
      .then (res) ->
        merge res, item: decodeDynamoItem res.Attributes

    describeTable: (params) -> @invokeAws "describeTable", TableApiBaseClass.translateParams params
    deleteTable:   (params) -> @invokeAws "deleteTable",   TableApiBaseClass.translateParams params
    waitFor:       (params) -> @invokeAws "waitFor",       TableApiBaseClass.translateParams params

    getTableChanges: (newCreateTableParams) ->
      {TableName} = TableApiBaseClass.translateParams newCreateTableParams
      compareIndexes = (newIndexes, currentIndexes) ->
        toByName = (indexes) ->
          object indexes,
            key: (index) -> index.IndexName
            with: (index) ->
              {IndexName, KeySchema, Projection} = index
              {IndexName, KeySchema, Projection}

        objectDiffReport(
          toByName newIndexes
          toByName currentIndexes
          eq
        )

      compareAttribues = (newAttrs, currentAttrs) ->
        toByName = (indexes) ->
          object indexes,
            key: (index) -> index.AttributeName

        objectDiffReport(
          toByName newAttrs
          toByName currentAttrs
          eq
        )

      @describeTable {TableName}
      .then (currentTableDescription) ->
        {KeySchema, GlobalSecondaryIndexes, LocalSecondaryIndexes, TableStatus} = currentTableDescription.Table
        out =
          KeySchema:              compareAttribues  newCreateTableParams.KeySchema,               KeySchema
          GlobalSecondaryIndexes: compareIndexes    newCreateTableParams.GlobalSecondaryIndexes,  GlobalSecondaryIndexes
          LocalSecondaryIndexes:  compareIndexes    newCreateTableParams.LocalSecondaryIndexes,   LocalSecondaryIndexes
        count = 0
        out = object out, when: (value) -> value? && ++count
        if count > 0
          out.TableStatus = TableStatus
          out
        else if TableStatus != "ACTIVE"
          {TableStatus}
        else
          "up to date"

    getTableStatus: (params) ->
      {TableName} = TableApiBaseClass.translateParams params
      @describeTable {TableName}
      .then ({Table:currentTableDescription}) ->
        TableStatus:                currentTableDescription.TableStatus
        GlobalSecondaryIndexStatus: object currentTableDescription.GlobalSecondaryIndexes,
          key:  (index) -> index.IndexName
          with: (index) -> index.IndexStatus

    ###
    IN:
      params:
        limit: number (optional)

        exclusiveStartKey: (optional)
        lastEvaluatedKey: (alias)
          use the lastEvaluatedKey that was returned from the previous call, if it was set
    ###
    scan: (params) ->
      # log dynamoDb: scan: params: Scan.translateParams params
      @invokeAws "scan", Scan.translateParams params
      .then (res) ->
        {Items, Count, ScannedCount, LastEvaluatedKey} = res
        # log dynamoDb: scan: result:
        #   items: Items.length
        #   count: Count
        #   lastEvaluatedKey: decodeDynamoItem LastEvaluatedKey
        #   scannedCount: ScannedCount

        merge
          items:            (decodeDynamoItem item for item in Items)
          count:            Count
          lastEvaluatedKey: LastEvaluatedKey && decodeDynamoItem LastEvaluatedKey
          scannedCount:     ScannedCount

    ###
    Non-table-operations
    ###
    listTables:       null
    describeLimits:   null

    ###
    TODO: currently these only support the default DynamoDb API (with promises)
    ###

    # batchGetItem:     null
    batchWriteItem:   null

    updateTable:      null
