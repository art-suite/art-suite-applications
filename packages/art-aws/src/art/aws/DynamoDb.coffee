###
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

Foundation = require 'art-foundation'
{
  merge
  isPlainObject, isPlainArray, isBoolean, isString, isNumber, inspect
  capitalize
  decapitalize
  lowerCamelCase
  wordsArray
  log
} = Foundation

{config} = require "./Config"

StreamlinedDynamoDbApi = require './StreamlinedDynamoDbApi'

{QueryApi, CreateTableApi, PutItemApi, TableApiBaseClass} = StreamlinedDynamoDbApi
{decodeDynamoItem} = TableApiBaseClass

module.exports = class DynamoDb

  constructor: (options = {}) ->
    @_awsDynamoDb = new AWS.DynamoDB merge config.dynamoDb, options

  invokeAws: (name, params) ->
    # log invokeAws:
    #   name: name
    #   params: params
    new Promise (resolve, reject) =>
      @_awsDynamoDb[name] params,  (err, res) ->
        if err then  reject err
        else         resolve res

  @bindAll: (map) ->
    for name, customMethod of map
      do (name, customMethod) =>
        @::[name] = customMethod || (params) -> @invokeAws name, params

  @bindAll
    createTable: (params) ->

      @invokeAws "createTable",
        CreateTableApi.translateParams merge
          attributes: id: 'string'
          key:        id: 'hash'

          params

    ###
    IN: see QueryApi.translateQueryParams
    OUT:
      same as DynamoDb EXCEPT, lowerCamelCase:
        items: Items
        count: Count
        scannedCount: ScannedCount
        lastEvaluatedKey: LastEvaluatedKey
        consumedCapacity: ConsumedCapacity
    ###
    query: (params) ->

      @invokeAws "query",
        QueryApi.translateParams params
      .then ({Items, Count, ScannedCount, LastEvaluatedKey, ConsumedCapacity}) ->
        items: (decodeDynamoItem item for item in Items)
        count: Count
        scannedCount: ScannedCount
        lastEvaluatedKey: LastEvaluatedKey
        consumedCapacity: ConsumedCapacity

    putItem: (params) ->
      @invokeAws "putItem",
        PutItemApi.translateParams params

    listTables:       null

    batchGetItem:     null
    batchWriteItem:   null
    deleteItem:       null
    deleteTable:      null
    describeLimits:   null
    describeTable:    null
    getItem:          null
    scan:             null
    updateItem:       null
    updateTable:      null
    waitFor:          null

