{log} = require 'art-foundation'
{QueryApi} = Neptune.Art.Aws.StreamlinedDynamoDbApi

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.QueryApi.optional params", ->
  test "translateParams", ->
    assert.eq new QueryApi().translateParams(table: "foo", where: foo: 123),
      TableName:                 "foo"
      ExpressionAttributeNames:  "#attr1": "foo"
      ExpressionAttributeValues: ":val1": N: "123"
      KeyConditionExpression:    "(#attr1 = :val1)"

  test "index", ->
    assert.eq(
      new QueryApi()._translateOptionalParams index: "bar"
      IndexName: "bar"
    )

  test "limit", ->
    assert.eq(
      new QueryApi()._translateOptionalParams limit: 10
      Limit: 10
    )

  test "exclusiveStartKey", ->
    assert.eq(
      new QueryApi()._translateOptionalParams exclusiveStartKey: esk = what: ever: ["I", "want"]
      ExclusiveStartKey: esk
    )

  test "consistentRead", ->
    assert.eq(
      new QueryApi()._translateOptionalParams consistentRead: true
      ConsistentRead: true
    )

  test "descending", ->
    assert.eq(
      new QueryApi()._translateOptionalParams descending: true
      ScanIndexForward: true
    )

  test "returnConsumedCapacity", ->
    assert.eq(
      new QueryApi()._translateOptionalParams returnConsumedCapacity: "total"
      ReturnConsumedCapacity: "TOTAL"
    )

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.QueryApi.where", ->
  hashTestValue = "123"
  rangeTestValue = "xyz"
  rangeTestValue2 = "zzz"

  test "hash key equal", ->
    assert.eq(
      new QueryApi()._translateWhere where: bar: hashTestValue
      KeyConditionExpression:       "(#attr1 = :val1)"
      ExpressionAttributeNames:     "#attr1": "bar"
      ExpressionAttributeValues:    ":val1": S: hashTestValue
    )

  for name, sym of {
        eq: "="
        lt: "<"
        gt: ">"
        lte: "<="
        gte: ">="
      }
    test "sort key #{name}", ->
      test = {}
      hashTestValue = "123"
      test[name] = rangeTestValue = "xyz"
      assert.eq(
        new QueryApi()._translateWhere where: bar: hashTestValue, baz: test
        ExpressionAttributeNames:    "#attr1": "bar", "#attr2": "baz"
        ExpressionAttributeValues:
          ":val1": S: hashTestValue
          ":val2": S: rangeTestValue
        KeyConditionExpression:      "(#attr1 = :val1 AND #attr2 #{sym} :val2)"
      )

  test "sort key lte AND gte", ->
    assert.eq(
      new QueryApi()._translateWhere where: bar: hashTestValue, baz: gte: rangeTestValue, lte: rangeTestValue2
      ExpressionAttributeNames:    "#attr1": "bar", "#attr2": "baz"
      ExpressionAttributeValues:
        ":val1": S: hashTestValue
        ":val2Gte": S: rangeTestValue
        ":val2Lte": S: rangeTestValue2
      KeyConditionExpression:      "(#attr1 = :val1 AND #attr2 BETWEEN :val2Gte AND :val2Lte)"
    )

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.QueryApi.select", ->
  test "*", ->
    assert.eq(
      new QueryApi()._translateSelect select: "*"
      Select: "ALL_ATTRIBUTES"
    )

  test "count(*)", ->
    assert.eq(
      new QueryApi()._translateSelect select: "count(*)"
      Select: "COUNT"
    )

  test "foo bar", ->
    assert.eq(
      new QueryApi()._translateSelect select: "foo bar"
      Select: "foo, bar"
    )

  test "['foo', 'bar']", ->
    assert.eq(
      new QueryApi()._translateSelect select: ['foo', 'bar']
      Select: "foo, bar"
    )
