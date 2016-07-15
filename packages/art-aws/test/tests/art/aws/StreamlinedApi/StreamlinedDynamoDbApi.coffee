{log} = require 'art-foundation'
{ translateProvisioning, translateKey, translateAttributes
  translateGlobalIndexes
  translateLocalIndexes
  translateCreateTableParams
} = Neptune.Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateCreateTableParams", ->
  test "translateCreateTableParams() has defaults", ->
    assert.eq translateCreateTableParams(tableName: "foo"),
      tableName:             "foo"
      attributeDefinitions:  [attributeName: "id", attributeType: "S"]
      keySchema:             [attributeName: "id", keyType: "HASH"]
      provisionedThroughput: readCapacityUnits: 1, writeCapacityUnits: 1

  test "translateCreateTableParams() override defaults", ->
    assert.eq translateCreateTableParams(
      tableName:             "foo"
      attributes: myKey: 'string'
      key: 'myKey'
      provisioning: read: 10
    ),
      tableName:             "foo"
      attributeDefinitions:  [attributeName: "myKey", attributeType: "S"]
      keySchema:             [attributeName: "myKey", keyType: "HASH"]
      provisionedThroughput: readCapacityUnits: 10, writeCapacityUnits: 1

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateProvisioning", ->
  test "translateProvisioning() has defaults", ->
    assert.eq translateProvisioning(),
      provisionedThroughput:
        readCapacityUnits: 1
        writeCapacityUnits: 1

  test "translateProvisioning provisioning: read: 10, write: 20", ->
    assert.eq translateProvisioning(provisioning: read: 10, write: 20),
      provisionedThroughput:
        readCapacityUnits: 10
        writeCapacityUnits: 20

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateKey", ->
  test "translateKey()", ->
    assert.eq translateKey({}), keySchema: [attributeName: "id", keyType: "HASH"]

  test "translateKey key: foo: 'hash'", ->
    assert.eq translateKey(key: foo: "hash"),
      keySchema: [attributeName: "foo", keyType: "HASH"]

  test "translateKey key: 'foo'", ->
    assert.eq translateKey(key: 'foo'),
      keySchema: [attributeName: "foo", keyType: "HASH"]

  test "translateKey key: 'foo/bar'", ->
    assert.eq translateKey(key: 'foo/bar'),
      keySchema: [
        {attributeName: "foo", keyType: "HASH"}
        {attributeName: "bar", keyType: "RANGE"}
      ]

  test "translateKey key: 'foo-bar'", ->
    assert.eq translateKey(key: 'foo-bar'),
      keySchema: [
        {attributeName: "foo", keyType: "HASH"}
        {attributeName: "bar", keyType: "RANGE"}
      ]

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateAttributes", ->
  test "translateAttributes()", ->
    assert.eq translateAttributes({}), attributeDefinitions: [attributeName: "id", attributeType: "S"]

  test "translateAttributes attributes: foo: 'string'", ->
    assert.eq translateAttributes(attributes: foo: "string"),
      attributeDefinitions: [attributeName: "foo", attributeType: "S"]

  test "translateAttributes attributes: all types", ->
    assert.eq translateAttributes(
      attributes:
        aString: "string"
        aNumber: "number"
        aBinary: "binary"
    ), attributeDefinitions: [
      {attributeName: "aString", attributeType: "S"}
      {attributeName: "aNumber", attributeType: "N"}
      {attributeName: "aBinary", attributeType: "B"}
    ]

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateGlobalIndexes", ->
  test "translateGlobalIndexes()", ->
    assert.eq translateGlobalIndexes({}), {}

  test "translateGlobalIndexes simplest", ->
    assert.eq translateGlobalIndexes(
      globalIndexes:
        myIndexName: {}
    ),
      globalSecondaryIndexes: [
        indexName:             "myIndexName"
        keySchema:             [attributeName: "id", keyType: "HASH"]
        projection:            type: "ALL", attributes: []
        provisionedThroughput: readCapacityUnits: 1, writeCapacityUnits: 1
      ]

  test "translateGlobalIndexes custom key", ->
    assert.eq translateGlobalIndexes(
      globalIndexes:
        myIndexName:
          key: 'myHashKeyName'
    ),
      globalSecondaryIndexes: [
        indexName:             "myIndexName"
        keySchema:             [attributeName: "myHashKeyName", keyType: "HASH"]
        projection:            type: "ALL", attributes: []
        provisionedThroughput: readCapacityUnits: 1, writeCapacityUnits: 1
      ]

  test "translateGlobalIndexes everything", ->
    assert.eq translateGlobalIndexes(
      globalIndexes:
        myFirstIndexName: {}
        myIndexName:
          key: 'myHashKeyName, myRangeKeyName'

          projection:
            attributes: ["myNumberAttrName", "myBinaryAttrName"]
            type: 'keysOnly'

          provisioning:
            read: 5
            write: 5
    ),
      globalSecondaryIndexes: [
        {
          indexName:             "myFirstIndexName"
          keySchema:             [attributeName: "id", keyType: "HASH"]
          projection:            type: "ALL", attributes: []
          provisionedThroughput: readCapacityUnits: 1, writeCapacityUnits: 1
        }
        indexName:             "myIndexName"
        keySchema: [
          {attributeName: "myHashKeyName", keyType: "HASH"}
          {attributeName: "myRangeKeyName", keyType: "RANGE"}
        ]
        projection:            type: "KEYS_ONLY", attributes: ["myNumberAttrName", "myBinaryAttrName"]
        provisionedThroughput: readCapacityUnits: 5, writeCapacityUnits: 5
      ]

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateLocalIndexes", ->
  test "translateLocalIndexes()", ->
    assert.eq translateLocalIndexes({}), {}

  test "translateLocalIndexes simplest", ->
    assert.eq translateLocalIndexes(
      localIndexes:
        myIndexName: {}
    ),
      localSecondaryIndexes: [
        indexName:             "myIndexName"
        keySchema:             [attributeName: "id", keyType: "HASH"]
        projection:            type: "ALL", attributes: []
      ]

  test "translateLocalIndexes custom key", ->
    assert.eq translateLocalIndexes(
      localIndexes:
        myIndexName:
          key: 'myHashKeyName'
    ),
      localSecondaryIndexes: [
        indexName:             "myIndexName"
        keySchema:             [attributeName: "myHashKeyName", keyType: "HASH"]
        projection:            type: "ALL", attributes: []
      ]

  test "translateLocalIndexes everything", ->
    assert.eq translateLocalIndexes(
      localIndexes:
        myFirstIndexName: {}
        myIndexName:
          key: "myHashKeyName myRangeKeyName"

          projection:
            attributes: ["myNumberAttrName", "myBinaryAttrName"]
            type: 'keysOnly'

          provisioning:
            read: 5
            write: 5
    ),
      localSecondaryIndexes: [
        {
          indexName:             "myFirstIndexName"
          keySchema:             [attributeName: "id", keyType: "HASH"]
          projection:            type: "ALL", attributes: []
        }
        indexName:             "myIndexName"
        keySchema: [
          {attributeName: "myHashKeyName", keyType: "HASH"}
          {attributeName: "myRangeKeyName", keyType: "RANGE"}
        ]
        projection:            type: "KEYS_ONLY", attributes: ["myNumberAttrName", "myBinaryAttrName"]
      ]
