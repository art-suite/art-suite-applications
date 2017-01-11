{Ery, Foundation} = Neptune.Art

{CommunicationStatus, isString, log, merge, createWithPostCreate} = Foundation
{clientFailure, missing} = CommunicationStatus

{pipelines} = Ery
{DynamoDbPipeline} = Ery.Aws

module.exports = suite:

  basic: ->
    myTable = MyTable = null
    setup ->
      Neptune.Art.Ery.PipelineRegistry._reset()
      {myTable} = createWithPostCreate class MyTable extends DynamoDbPipeline
        @addDatabaseFilters
          userName: "required string"
          email:    "required email"

      myTable.createTable()

    test "create then get", ->
      myTable.create
        data:
          userName: "John"
          email: "foo@bar.com"

      .then (data) ->
        log createThenGet: {data}
        assert.isString data.id
        assert.isNumber data.createdAt
        assert.isNumber data.updatedAt
        myTable.get {data}
        .then (getData) ->
          assert.eq getData, data

    test "update", ->

      createData = null

      myTable.create
        data:
          userName: "John"
          email: "foo@bar.com"
          rank: 123
          attributes: ["adventurous", "charming"]

      .then (createData) ->
        myTable.update
          key: createData.id
          data: foo: "bar"

        .then (updatedData)->
          myTable.get key: createData.id
          .then (data)->
            assert.eq data, merge createData, updatedData

    test "delete", ->
      createData = null

      myTable.create
        data:
          userName: "John"
          email: "foo@bar.com"
          rank: 123
          attributes: ["adventurous", "charming"]

      .then (_createData) ->
        createData = _createData
        myTable.delete key: createData.id

      .then ->
        assert.rejects myTable.get key: createData.id

      .then (expectedError)->
        {response} = expectedError.info
        assert.eq response.status, missing
        "triggered catch"

    test "describeTable", ->
      myTable.dynamoDb.describeTable TableName: myTable.tableName
      .then ({Table}) ->
        assert.eq Table.AttributeDefinitions, [
          AttributeName: "id"
          AttributeType: "S"
        ]

  "compound primary key": ->
    myManyToManyTable = null
    setup ->
      Neptune.Art.Ery.PipelineRegistry._reset()
      {myManyToManyTable} = createWithPostCreate class MyManyToManyTable extends DynamoDbPipeline
        @primaryKey "userId/postId"
        @addDatabaseFilters
          user: "required link"
          post: "required link"

      myManyToManyTable.createTable()

    test "create, get and update", ->

      myManyToManyTable.create
        data:
          foo: "bar"
          userId: "abc123"
          postId: "xyz123"

      .then (data) ->
        assert.doesNotExist data.id
        myManyToManyTable.get {data}
        .then ({foo}) -> assert.eq foo, "bar"
        .then         -> myManyToManyTable.update data: merge data, foo: "bar2"
        .then         -> myManyToManyTable.get {data}
        .then ({foo}) -> assert.eq foo, "bar2"

    test "create fails with missing required field", ->

      assert.rejects myManyToManyTable.create
        data:
          foo: "bar"
          userId: "abc123"

      .then (expectedError) ->
        assert.eq expectedError.info.response.status, clientFailure
