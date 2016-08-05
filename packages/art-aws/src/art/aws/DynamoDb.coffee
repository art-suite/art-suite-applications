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

  createTable
    attributes:
      myHashKeyName:    'string'
      myRangeKeyName:   'string'
      myNumberAttrName: 'number'
      myBinaryAttrName: 'binary'

    key:
      myHashKeyName:  'hash'
      myRangeKeyName: 'range'

      OR: "hashKeyField"
      OR: "hashKeyField/rangeKeyField"
        NOTE: you can use any string format that matches /[_a-zA-Z0-9]+/g

    provisioning:
      read: 5
      write: 5

    globalIndexes:
      myIndexName:
        key:
          myHashKeyName:  'hash'
          myRangeKeyName: 'range'

        projection:
          attributes: ["myNumberAttrName", "myBinaryAttrName"]
          type: 'all' || 'keysOnly' || 'include'

        provisioning:
          read: 5
          write: 5

    localIndexes:
      myIndexName:
        key:
          myHashKeyName:  'hash'  # localIndexes must have the same hash-key as the table
          myRangeKeyName: 'range'

        projection:
          attributes: ["myNumberAttrName", "myBinaryAttrName"]
          type: 'all' || 'keysOnly' || 'include'
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

StreamlinedApi = require './StreamlinedApi'

{Tools, StreamlinedDynamoDbApi} = StreamlinedApi
# {deepDecapitalizeAllKeys, deepCapitalizeAllKeys} = Tools
{translateCreateTableParams} = StreamlinedDynamoDbApi

module.exports = class DynamoDb

  @encodeDynamoData: encodeDynamoData = (data) ->
    ret = if isPlainObject data
      values = {}
      values[k] = encodeDynamoData v for k, v of data when v != undefined
      M: values
    else if isPlainArray data
      L: (encodeDynamoData v for v in data when v != undefined)
    else if isBoolean data
      BOOL: data
    else if isString data
      S: data
    else if isNumber data
      N: data.toString()
    else if data == null
      NULL: true
    else
      throw new Error "invalid data type: #{inspect data}"

  @decodeDynamoData: decodeDynamoData = (data) ->
    if map = data.M
      out = {}
      for k, v of map
        out[k] = decodeDynamoData v
      out
    else if array = data.L
      decodeDynamoData v for v in array
    else if string = data.S
      string
    else if (number = data.N)?
      parseFloat number
    else if bool = data.BOOL
      !!bool
    else if data.NULL
      null
    else
      throw new Error "unknown dynamo data type: #{inspect data}"

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
        translateCreateTableParams merge
          attributes: id: 'string'
          key:        id: 'hash'

          params

    listTables:       null

    batchGetItem:     null
    batchWriteItem:   null
    deleteItem:       null
    deleteTable:      null
    describeLimits:   null
    describeTable:    null
    getItem:          null
    listTables:       null
    putItem:          null
    query:            null
    scan:             null
    updateItem:       null
    updateTable:      null
    waitFor:          null

