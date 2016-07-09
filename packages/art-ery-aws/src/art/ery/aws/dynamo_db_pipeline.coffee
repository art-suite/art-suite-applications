ArtEry = require 'art-ery'
{log, merge} = require 'art-foundation'
{DynamoDb} = require 'art-aws'
{Pipeline} = ArtEry
Uuid = require 'uuid'
{encodeDynamoData, decodeDynamoData} = DynamoDb

module.exports = class DynamoDbPipeline extends Pipeline

  constructor: ->
    super
    @_dynamoDb = new DynamoDb endpoint: "http://localhost:8081"

  @getter
    uniqueId: -> Uuid.v4()
    tableName: -> @class.getName()

  @handlers
    get: ({key}) ->
      @_vivifyTable().then =>
        @_dynamoDb.getItem
          TableName: @tableName
          Key: id: S: key
      .then ({Item}) ->
        Item && decodeDynamoData M: Item

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

    delete: ({key}) ->
      @_vivifyTable().then =>
        @_dynamoDb.deleteItem
          TableName: @tableName
          Key: id: S: key
      .then => message: "success"

  #########################
  # PRIVATE
  #########################
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
