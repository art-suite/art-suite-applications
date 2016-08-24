{log, formattedInspect} = require 'art-foundation'
{TableApiBaseClass} = Neptune.Art.Aws.StreamlinedDynamoDbApi

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.TableApiBaseClass._translateConditionExpression", ->
  translateConditionExpressionTest = (expression, expectedExpressionString, expectedTarget) ->
    test formattedInspect(expression), ->
      expressionString = ({_target} = new TableApiBaseClass())._translateConditionExpression expression
      assert.eq expectedExpressionString, expressionString, "expressionString"
      assert.eq expectedTarget, _target, "target"

  translateConditionExpressionTest
    foo: 123
    "(#attr1 = :val1)"
    ExpressionAttributeNames:  "#attr1": "foo"
    ExpressionAttributeValues: ":val1": N: "123"

  translateConditionExpressionTest
    foo: gt: 0
    "(#attr1 > :val1)"
    ExpressionAttributeNames:  "#attr1": "foo"
    ExpressionAttributeValues: ":val1": N: "0"

  translateConditionExpressionTest
    foo: 123
    bar: lte: "hi"
    "(#attr1 = :val1 AND #attr2 <= :val2)"
    ExpressionAttributeNames:
      "#attr1": "foo"
      "#attr2": "bar"
    ExpressionAttributeValues:
      ":val1": N: "123"
      ":val2": S: "hi"

  translateConditionExpressionTest [
      foo: 123
      "OR"
      bar: lte: "hi"
    ],
    "((#attr1 = :val1) OR (#attr2 <= :val2))"
    ExpressionAttributeNames:
      "#attr1": "foo"
      "#attr2": "bar"
    ExpressionAttributeValues:
      ":val1": N: "123"
      ":val2": S: "hi"

  translateConditionExpressionTest [
      "NOT"
      foo: 123
      "OR"
      bar: lte: "hi"
    ],
    "(NOT (#attr1 = :val1) OR (#attr2 <= :val2))"
    ExpressionAttributeNames:
      "#attr1": "foo"
      "#attr2": "bar"
    ExpressionAttributeValues:
      ":val1": N: "123"
      ":val2": S: "hi"

  translateConditionExpressionTest [
      "NOT"
      foo: 123
      baz: "zzz"
      "OR"
      bar: lte: "hi"
    ],
    "(NOT (#attr1 = :val1 AND #attr2 = :val2) OR (#attr3 <= :val3))"
    ExpressionAttributeNames:
      "#attr1": "foo"
      "#attr2": "baz"
      "#attr3": "bar"
    ExpressionAttributeValues:
      ":val1": N: "123"
      ":val2": S: "zzz"
      ":val3": S: "hi"
