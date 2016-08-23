{log} = require 'art-foundation'
{PutItemApi} = Neptune.Art.Aws.StreamlinedDynamoDbApi

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.PutItemApi.basic", ->
  test "item required", ->
    assert.throws -> new PutItemApi()._translateItem {}

  test "item: {}", ->
    assert.eq(
      new PutItemApi()._translateItem item: {}
      Item: {}
    )

  test "item: foo: 123", ->
    assert.eq(
      new PutItemApi()._translateItem item: foo: 123
      Item: foo: N: "123"
    )

  test "item: foo: 'bar'", ->
    assert.eq(
      new PutItemApi()._translateItem item: foo: 'bar'
      Item: foo: S: "bar"
    )
