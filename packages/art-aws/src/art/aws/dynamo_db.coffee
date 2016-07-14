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

StreamlinedApi = require './StreamlinedApi'

{Tools, StreamlinedDynamoDbApi} = StreamlinedApi
{deepDecapitalizeAllKeys, deepCapitalizeAllKeys} = Tools
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

  constructor: (options) ->
    endpoint = new AWS.Endpoint options.endpoint if options.endpoint
    @_awsDynamoDb = new AWS.DynamoDB endpoint: endpoint

  invokeAws: (name, params) ->
    params = deepCapitalizeAllKeys params
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

