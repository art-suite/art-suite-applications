AWS = require 'aws-sdk'
AWS.config.region = 'us-west-2'
log = (a...) -> console.log a...
{DynamoDb} = require 'art-aws'

suite "Art.Ery.Aws", ->
  @timeout 10000

  test "my DynamoDb", ->
    dynamoDb = new DynamoDb endpoint: "http://localhost:8081"
    dynamoDb.listTables()
    .then (tables) ->
      console.log tables
