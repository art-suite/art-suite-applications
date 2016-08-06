Uuid = require 'uuid'

Foundation = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'

{log, merge, Validator, isString} = Foundation
{Pipeline} = ArtEry
{DynamoDb} = ArtAws
{encodeDynamoData, decodeDynamoData} = DynamoDb

module.exports = class DynamoDbPipeline extends Pipeline

  constructor: (options = {}) ->
    super
    @_dynamoDb = new DynamoDb
    @_createTableParams = options

  @getter "dynamoDb"

  keyFromData: (data) -> data.id

  @handlers
    get: ({key}) ->
      @_vivifyTable().then =>
        @_dynamoDb.getItem
          TableName: @tableName
          Key: id: S: key
      .then ({Item}) ->
        Item && decodeDynamoData M: Item

    create: ({data}) ->
      @_vivifyTable().then =>
        @_dynamoDb.putItem
          TableName: @tableName
          Item: encodeDynamoData(data).M
      .then ->
        data

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
    @_dynamoDb.createTable(merge
        tableName: @tableName
        attributes: @dynamoDbCreationAttributes
        @_createTableParams
      )
    .then -> @_tableExists = true
