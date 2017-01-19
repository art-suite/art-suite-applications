{log, defineModule} = Neptune.Art.Foundation
{UpdateItem} = Neptune.Art.Aws.StreamlinedDynamoDbApi

defineModule module, suite: ->
  test "item required", ->
    assert.throws -> new UpdateItem()._translateItem {}

  test "no updates throws error", ->
    assert.throws -> new UpdateItem().translateParams table: "hi", key: "foo", item: {}

  test "item: foo: 123", ->
    assert.eq
      TableName: "hi"
      Key:       id: S: "foo"
      ExpressionAttributeNames:   "#attr1": "foo"
      ExpressionAttributeValues:  ":val1":  N: "123"
      UpdateExpression: "SET #attr1 = :val1"

      ReturnValues: "UPDATED_NEW"

      new UpdateItem().translateParams table: "hi", key: "foo", item: foo: 123

  test "item: foo: 123, bar: undefined", ->
    assert.eq
      TableName: "hi"
      Key:       id: S: "foo"
      ExpressionAttributeNames:   "#attr1": "foo"
      ExpressionAttributeValues:  ":val1":  N: "123"
      UpdateExpression: "SET #attr1 = :val1"

      ReturnValues: "UPDATED_NEW"

      new UpdateItem().translateParams table: "hi", key: "foo", item: foo: 123, bar: undefined

  test "add: foo: 123", ->
    assert.eq
      TableName: "hi"
      Key:       id: S: "foo"
      ExpressionAttributeNames:   "#attr1": "foo"
      ExpressionAttributeValues:  ":val1":  N: "123"
      UpdateExpression: "ADD #attr1 :val1"

      ReturnValues: "UPDATED_NEW"

      new UpdateItem().translateParams table: "hi", key: "foo", add: foo: 123

  test "defaults: foo: 123", ->
    assert.eq
      TableName: "hi"
      Key:       id: S: "foo"
      ExpressionAttributeNames:   "#attr1": "foo"
      ExpressionAttributeValues:  ":val1":  N: "123"
      UpdateExpression: "SET #attr1 = if_not_exists(#attr1, :val1)"

      ReturnValues: "UPDATED_NEW"

      new UpdateItem().translateParams table: "hi", key: "foo", defaults: foo: 123
