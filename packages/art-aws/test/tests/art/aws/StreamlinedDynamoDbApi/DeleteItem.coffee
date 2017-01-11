{log, defineModule} = Neptune.Art.Foundation
{DeleteItem} = Neptune.Art.Aws.StreamlinedDynamoDbApi

defineModule module, suite: ->
  test "key required", ->
    assert.throws -> new DeleteItem().translateParams tableName: "foobar"

  test "key: 'abc123'", ->
    assert.eq
      TableName: "foobar"
      Key:       id: S: "abc123"

      new DeleteItem().translateParams
        tableName: "foobar"
        key: "abc123"
