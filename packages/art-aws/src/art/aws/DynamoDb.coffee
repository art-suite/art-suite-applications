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

Foundation = require 'art-foundation'
{
  merge
  isPlainObject, isPlainArray, isBoolean, isString, isNumber, inspect
  capitalize
  decapitalize
  lowerCamelCase
  wordsArray
  log
  eq
  BaseObject
  formattedInspect
  objectHasKeys
} = Foundation

{config} = Config = require "./Config"

StreamlinedDynamoDbApi = require './StreamlinedDynamoDbApi'

{Query, CreateTable, PutItem, UpdateItem, GetItem, TableApiBaseClass} = StreamlinedDynamoDbApi
{decodeDynamoItem} = TableApiBaseClass

module.exports = class DynamoDb extends BaseObject
  @singletonClass()

  constructor: (options = {}) ->
    config = merge Config.getNormalizedDynamoDbConfig(), options
    if config.accessKeyId == Config.getDefaults().credentials.accessKeyId && !config.endpoint
      log.error """
        Art.Aws.DynamoDb invalid configuration. Please set one of:
        - Art.Aws.credentails for connection to AWS
        - Art.Aws.dynamoDb.endpoint for connection to a local DynamoDB.

        #{
        if objectHasKeys options
          formattedInspect "Art.Aws.config":config, options: options, "merged config": config
        else
          formattedInspect "Art.Aws.config":config
        }

        """
      throw new Error "invalid config options"

    @_awsDynamoDb = new AWS.DynamoDB log "dynamodbConfig", config

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

      try
        @invokeAws "createTable",
          CreateTable.translateParams merge
            attributes: id: 'string'
            key:        id: 'hash'

            params
      catch e
        log createTableInputParams: params
        throw e

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

    getItem: (params) ->
      @invokeAws "getItem",
        GetItem.translateParams params
      .then (res) ->
        item: res.Item && decodeDynamoItem res.Item

    updateItem: (params) ->
      @invokeAws "updateItem",
        UpdateItem.translateParams params
      .then (res) ->
        merge res, item: decodeDynamoItem res.Attributes

    describeTable: (params) -> @invokeAws "describeTable", TableApiBaseClass.translateParams params
    deleteTable:   (params) -> @invokeAws "deleteTable",   TableApiBaseClass.translateParams params
    waitFor:       (params) -> @invokeAws "waitFor",       TableApiBaseClass.translateParams params

    scan: (params) ->
      @invokeAws "scan",
        log "scanParams", TableApiBaseClass.translateParams params
      .then (res) ->
        {Items, Count, ScannedCount} = res
        items: (decodeDynamoItem item for item in Items)
        count: Count
        scannedCount: ScannedCount

    ###
    Non-table-operations
    ###
    listTables:       null
    describeLimits:   null

    ###
    TODO: currently these only support the default DynamoDb API (with promises)
    ###
    deleteItem:       null

    batchGetItem:     null
    batchWriteItem:   null

    updateTable:      null
