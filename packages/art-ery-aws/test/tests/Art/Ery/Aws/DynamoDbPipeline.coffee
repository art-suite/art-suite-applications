Foundation = require 'art-foundation'
{pipelines} = require 'art-ery'
{createDatabaseFilters} = require 'art-ery/Filters'

ArtEryAws = require 'art-ery-aws'

{CommunicationStatus, isString, log, merge, createWithPostCreate} = Foundation
{missing} = CommunicationStatus
{DynamoDbPipeline} = ArtEryAws
Neptune.Art.Aws.config.region = 'us-west-2'


Neptune.Art.Aws.config.dynamoDb.endpoint = 'http://localhost:1337/localhost:8081'

module.exports = suite: ->
  MyTable = null
  setup ->
    Neptune.Art.Ery.PipelineRegistry._reset()
    createWithPostCreate class MyTable extends DynamoDbPipeline
      @filter createDatabaseFilters()

    pipelines.myTable.createTable()

  test "create", ->
    createData = null

    pipelines.myTable.create
      data:
        userName: "John"
        email: "foo@bar.com"
        rank: 123
        attributes: ["adventurous", "charming"]
    .then (_createData) ->
      createData = _createData
      {id} = createData
      assert.ok isString id
      id
    .then (id) -> pipelines.myTable.get key: id
    .then (getData) ->
      assert.eq getData, createData

  test "update", ->

    createData = null

    pipelines.myTable.create
      data:
        userName: "John"
        email: "foo@bar.com"
        rank: 123
        attributes: ["adventurous", "charming"]
    .then (createData) ->
      pipelines.myTable.update
        key: createData.id
        data: foo: "bar"
      .then (updatedData)->
        pipelines.myTable.get key: createData.id
        .then (data)->
          assert.eq data, merge createData, updatedData

  test "delete", ->
    createData = null

    pipelines.myTable.create
      data:
        userName: "John"
        email: "foo@bar.com"
        rank: 123
        attributes: ["adventurous", "charming"]

    .then (_createData) ->
      createData = _createData
      pipelines.myTable.delete key: createData.id

    .then ->
      pipelines.myTable.get key: createData.id

    .catch (response)->
      assert.eq response.status, missing
      "triggered catch"

    .then (v)->
      assert.eq v, "triggered catch"

  test "describeTable", ->
    pipelines.myTable.dynamoDb.describeTable TableName: pipelines.myTable.tableName
    .then ({Table}) ->
      assert.eq Table.AttributeDefinitions, [
        AttributeName: "id"
        AttributeType: "S"
      ]
