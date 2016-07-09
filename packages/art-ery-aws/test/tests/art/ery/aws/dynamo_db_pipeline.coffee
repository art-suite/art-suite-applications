Foundation = require 'art-foundation'
ArtEryAws = require 'art-ery-aws'

{isString, log, merge} = Foundation
{DynamoDbPipeline, config} = ArtEryAws
config.region = 'us-west-2'

suite "Art.Ery.Aws.DynamoDbPipeline", ->
  # test "works", ->
  test "create", ->
    {myTable} = class MyTable extends DynamoDbPipeline
      @singletonClass()

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
    {myTable} = class MyTable extends DynamoDbPipeline
      @singletonClass()

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
