{Ery, Foundation} = Neptune.Art

{Promise, CommunicationStatus, isString, log, merge, createWithPostCreate, randomString} = Foundation
{success, clientFailure, missing} = CommunicationStatus

{session, pipelines} = Ery
{AfterEventsFilter} = Ery.Filters
{DynamoDbPipeline} = Ery.Aws


sharedAfterEventTests = (setupUserWith) ->

  setup ->
    AfterEventsFilter._reset()
    Neptune.Art.Ery.PipelineRegistry._reset()

    User = null
    createWithPostCreate class User extends DynamoDbPipeline
      @addDatabaseFilters
        name:               "required trimmedstring"
        postCount:          "number"
        lastPostCreatedAt:  "timestamp"

    setupUserWith User

    createWithPostCreate class Post extends DynamoDbPipeline
      @addDatabaseFilters
        userOwned: true
        text:       "trimmedstring"
        createdAt:  "timestamp"

    pipelines.user.createTable()
    pipelines.post.createTable()

    # User and AfterEventsFilter properly setup
    assert.eq AfterEventsFilter.handlers.post.create.length, 1
    assert.eq AfterEventsFilter.handlers.post.create[0], User


  test "User and AfterEventsFilter properly setup", ->
    # tests are in setup, since we want to run them EACH TIME - the second time can fail
    # LEAVE THIS 'empty' TEST HERE - so we can JUST run the setup-tests

  test "create user and two posts", ->
    userId = post = null
    pipelines.user.create
      data: name: "Bill"
    .then (user) ->
      {name, postCount, lastPostCreatedAt, id: userId} = user
      session.data = {userId}
      assert.doesNotExist lastPostCreatedAt
      assert.doesNotExist postCount
      assert.eq name, "Bill"
      assert.eq name, "Bill"
      assert.isString userId
    .then -> pipelines.post.create data: userId: userId, text: "hi"
    .then (_post) -> post = _post; pipelines.user.get key: userId
    .then (user) ->
      {postCount, lastPostCreatedAt} = user
      assert.eq lastPostCreatedAt, post.createdAt
      assert.eq postCount, 1

    .then -> pipelines.post.create data: userId: userId, text: "hi"
    .then (_post) -> post = _post; pipelines.user.get key: userId
    .then (user) ->
      {postCount, lastPostCreatedAt} = user
      assert.eq lastPostCreatedAt, post.createdAt
      assert.eq postCount, 2

myTable = MyTable = null
setupWithMyTable = ->
  Neptune.Art.Ery.PipelineRegistry._reset()
  {myTable} = createWithPostCreate class MyTable extends DynamoDbPipeline
    @addDatabaseFilters
      name:   "required string"
      email:  "required email"

  {myCompoundKeyTable} = createWithPostCreate class MyCompoundKeyTable extends DynamoDbPipeline
    @keyFields "userId/postId"
    @addDatabaseFilters
      user:   "link"
      post:   "link"

  Promise.all([
    myCompoundKeyTable._vivifyTable()
    myTable._vivifyTable()
  ])

module.exports = suite:

  basic: ->
    setup setupWithMyTable

    test "create then get", ->
      myTable.create
        data:
          name: "John"
          email: "foo@bar.com"

      .then (data) ->
        assert.isString data.id
        assert.isNumber data.createdAt
        assert.isNumber data.updatedAt
        myTable.get key: data
        .then (getData) ->
          assert.eq getData, data


    test "delete", ->
      createData = null

      myTable.create
        data:
          name: "John"
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

  update: ->
    setup setupWithMyTable

    test "update using keys", ->

      createData = null

      myTable.create
        data:
          name: "John"
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

    test "update non-existant record fails with status: missing", ->
      assert.rejects myTable.update
        key: randomString()
        data: foo: "bar"
      .then (rejectsWith) ->
        assert.eq rejectsWith.info.response.status, missing

    test "update with createOk rejected without originatedOnServer", ->
      assert.rejects myTable.update
        props:
          createOk: true
          key: randomString()
          data: foo: "bar"
      .then (rejectsWith) ->
        assert.eq rejectsWith.info.response.status, clientFailure

    test "update non-existant record works with createOk and originatedOnServer", ->
      pipelines.myCompoundKeyTable.update
        returnResponseObject: true
        originatedOnServer: true
        props:
          createOk: true
          key: userId: "123", postId: "abc"
      .then (response) ->
        assert.eq response.status, success

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
        myManyToManyTable.get key: data
        .then ({foo}) -> assert.eq foo, "bar"
        .then         -> myManyToManyTable.update key: data, data: merge data, foo: "bar2"
        .then         -> myManyToManyTable.get key: data
        .then ({foo}) -> assert.eq foo, "bar2"

    test "create fails with missing required field", ->

      assert.rejects myManyToManyTable.create
        data:
          foo: "bar"
          userId: "abc123"

      .then (expectedError) ->
        assert.eq expectedError.info.response.status, clientFailure

  crossPipelineEvents:
    afterEvent: ->

      sharedAfterEventTests (User) ->
        User.afterEvent
          create: post: afterEventFunction = (response) ->
            Promise.then ->
              {userId, createdAt} = response.data
              assert.eq "post", response.pipelineName
              response.subrequest "user", "update", props:
                key:  userId
                data: lastPostCreatedAt: createdAt
                add:  postCount: 1

        assert.eq User.getAfterEventFunctions(), post: create: [afterEventFunction]

    updateAfter:
      full: ->
        sharedAfterEventTests (User) ->
          User.updateAfter
            create: post: postCreateUpdateFunction = (response) ->
              Promise.then ->
                {userId, createdAt} = response.data
                assert.eq "post", response.pipelineName
                key: userId
                data: lastPostCreatedAt: createdAt
                add: postCount: 1

          # User and AfterEventsFilter properly setup
          assert.eq User.getUpdatePropsFunctions(), post: create: [postCreateUpdateFunction]

      _mergeUpdateProps: ->
        test "basic", ->
          assert.eq
            foo: key: "foo", set: bar: 123
          , DynamoDbPipeline._mergeUpdateProps [
            {key: "foo", set: bar: 123}
          ]

        test "distinct actions for same key", ->
          assert.eq
            foo:
              key:        "foo"
              set:        bar: 123
              setDefault: baz: 456
          , DynamoDbPipeline._mergeUpdateProps [
            {key: "foo", set: bar: 123}
            {key: "foo", setDefault: baz: 456}
          ]

        test "two keys with overlapping actions", ->
          assert.eq
            foo: key: "foo", set: name: "alice"
            bar: key: "bar", set: name: "bill"
          , DynamoDbPipeline._mergeUpdateProps [
            {key: "foo", set: name: "alice"}
            {key: "bar", set: name: "bill"}
          ]

        test "array of updates", ->
          assert.eq
            foo: key: "foo", set: name: "alice", address: "123 Street"
            bar: key: "bar", set: name: "bill"
          , DynamoDbPipeline._mergeUpdateProps [
            [{key: "foo", set: name: "alice"}
            {key: "bar", set: name: "bill"}]
            {key: "foo", set: address: "123 Street"}
          ]
