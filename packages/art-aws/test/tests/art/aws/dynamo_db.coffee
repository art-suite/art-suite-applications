Foundation = require 'art-foundation'
{log} = Foundation
{DynamoDb, config} = require 'art-aws'
config.region = 'us-west-2'
config.endpoint = "http://localhost:8081"

testTableName = 'fooBarTestTable'

suite "Art.Ery.Aws.DynamoDb", ->
  @timeout 10000

  dynamoDb = null
  setup ->
    dynamoDb = new DynamoDb
    dynamoDb.listTables()
    .then ({TableNames}) ->
      list = for tableName in TableNames
        if tableName == testTableName
          log "Deleting test table: #{testTableName}"
          dynamoDb.deleteTable TableName: tableName
        else
          console.error "NOT deleting non-test-table: #{tableName}"
      Promise.all list

  test "listTables", ->
    dynamoDb.listTables()
    .then (tables) ->
      assert.eq tables.TableNames, []
      log tables

  test "createTable", ->
    dynamoDb.createTable TableName: testTableName
    .then (result) ->
      log result

  test "create complex table", ->
    dynamoDb.createTable {"TableName":testTableName,"AttributeDefinitions":[{"AttributeName":"createdAt","AttributeType":"N"},{"AttributeName":"updatedAt","AttributeType":"N"},{"AttributeName":"user","AttributeType":"S"},{"AttributeName":"message","AttributeType":"S"},{"AttributeName":"chatRoom","AttributeType":"S"}],"KeySchema":[{"AttributeName":"chatRoom","KeyType":"HASH"},{"AttributeName":"createdAt","KeyType":"RANGE"}],"ProvisionedThroughput":{"ReadCapacityUnits":1,"WriteCapacityUnits":1}}
    .then (result) ->
      log result
