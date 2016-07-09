ArtEry = require 'art-ery'
{log, merge, isPlainObject, isPlainArray, isBoolean, isString, isNumber, inspect} = require 'art-foundation'
{DynamoDb} = require 'art-aws'
{Pipeline} = ArtEry
Uuid = require 'uuid'

module.exports = class DynamoDbPipeline extends Pipeline

  constructor: ->
    super
    @_dynamoDb = new DynamoDb endpoint: "http://localhost:8081"

  @getter
    uniqueId: -> Uuid.v4()
    tableName: -> @class.getName()

  encodeDynamoData = (data) ->
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

  decodeDynamoData = (data) ->
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



  @handlers
    get: ({key}) ->
      @_vivifyTable().then =>
        @_dynamoDb.getItem
          TableName: @tableName
          Key: id: S: key
      .then ({Item}) ->
        decodeDynamoData M: Item

    create: ({data}) ->
      {uniqueId} = @
      @_vivifyTable().then =>
        @_dynamoDb.putItem
          TableName: @tableName
          Item: encodeDynamoData(record = merge data, id: uniqueId).M
        .then ->
          record

    update: ({key, data}) ->
      @_vivifyTable().then =>
        attributeUpdates = {}
        for k, v of data
          attributeUpdates[k] =
            Action: "PUT"
            Value: encodeDynamoData v

        @_dynamoDb.updateItem
          TableName: @tableName
          Key: id: S: key
          AttributeUpdates: attributeUpdates
          ReturnValues: 'ALL_NEW'
      .then ({Attributes}) ->
        decodeDynamoData M: Attributes

    # delete: ({key}) ->

  _vivifyTable: ->
    return Promise.resolve true if @_tableExists
    @_dynamoDb.listTables()
    .then ({TableNames}) =>
      if 0 <= TableNames.indexOf @tableName
        @_tableExists = true
      else
        @_createTable()

  _createTable: ->
    @_dynamoDb.createTable TableName: @tableName
    .then -> @_tableExists = true
