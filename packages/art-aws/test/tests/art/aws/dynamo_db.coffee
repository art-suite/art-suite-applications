Foundation = require 'art-foundation'
{log, isPlainArray} = Foundation
{DynamoDb, config, encodeDynamoData} = require 'art-aws'
config.region = 'us-west-2'
config.endpoint = "http://localhost:8081"

testTableName = 'fooBarTestTable'

suite "Art.Ery.Aws.DynamoDb", ->
  @timeout 10000

  dynamoDb = null
  setup ->
    dynamoDb = new DynamoDb
      accessKeyId:    'thisIsSomeInvalidKey'
      secretAccessKey:'anEquallyInvalidSecret!'
      region:         'us-east-1'
      endpoint:       'http://localhost:8081'
      maxRetries:     5

    dynamoDb.listTables()
    .then ({TableNames}) ->
      list = for tableName in TableNames
        if tableName == testTableName
          log "Deleting test table: #{testTableName}"
          dynamoDb.deleteTable TableName: tableName
        else
          log "NOT deleting non-test-table: #{tableName}"
      Promise.all list

  test "listTables", ->
    dynamoDb.listTables()
    .then (tables) ->
      assert.eq true, isPlainArray tables.TableNames
      # log tables

  test "createTable", ->
    dynamoDb.createTable tableName: testTableName
    # .then (result) ->
    #   log result

  test "create complex table", ->
    dynamoDb.createTable
      tableName: testTableName
      attributes:
        createdAt: "number"
        chatRoom:  "string"
      key: "chatRoom/createdAt"
    .then (result) ->
      # log createResult: result
      data =
        createdAt: Date.now()
        updatedAt: Date.now()
        user: "abc123"
        chatRoom: "xyz456"
        message: "Hi!"
        id: "lmnop123123"
      dynamoDb.putItem
        TableName: testTableName
        Item: encodeDynamoData(data).M
    # .then (result) ->
    #   log putResult: result
