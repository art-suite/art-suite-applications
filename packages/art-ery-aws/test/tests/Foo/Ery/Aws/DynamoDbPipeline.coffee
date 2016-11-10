Foundation = require 'art-foundation'
{missing} = require 'art-ery'
ArtEryAws = require 'art-ery-aws'

{isString, log, merge} = Foundation
{DynamoDbPipeline, config} = ArtEryAws
config.region = 'us-west-2'

suite "Art.Ery.Aws.DynamoDbPipeline", ->
  # test "works", ->
  myTable = null
  setup ->
    {myTable} = class MyTable extends DynamoDbPipeline
      @singletonClass()

  test "create", ->
    createData = null

    myTable.create
      userName: "John"
      email: "foo@bar.com"
      rank: 123
      attributes: ["adventurous", "charming"]
    .then (_createData) ->
      createData = _createData
      {id} = createData
      assert.ok isString id
      id
    .then (id) -> myTable.get id
    .then (getData) ->
      assert.eq getData, createData

  test "update", ->

    createData = null

    myTable.create
      userName: "John"
      email: "foo@bar.com"
      rank: 123
      attributes: ["adventurous", "charming"]
    .then (_createData) ->
      createData = _createData
      myTable.update createData.id,
        foo: "bar"
    .then (updateData) ->
      assert.eq updateData, merge createData, foo: "bar"

  test "delete", ->
    createData = null

    myTable.create
      userName: "John"
      email: "foo@bar.com"
      rank: 123
      attributes: ["adventurous", "charming"]
    .then (_createData) ->
      createData = _createData
      myTable.delete createData.id,
    .then ->
      myTable.get createData.id
    .catch (response)->
      assert.eq response.status, missing
      "triggered catch"
    .then (v)->
      assert.eq v, "triggered catch"

  test "describeTable", ->
    myTable.dynamoDb.describeTable TableName: myTable.tableName
    .then (result) ->
      log result
