{log} = require 'art-foundation'
{ translateProvisioning, translateKey, translateAttributes
  translateGlobalIndexes
  translateLocalIndexes
  translateCreateTableParams
} = Neptune.Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateCreateTableParams", ->
  test "translateCreateTableParams() has defaults", ->
    assert.eq translateCreateTableParams(tableName: "foo"),
      TableName:             "foo"
      AttributeDefinitions:  [AttributeName: "id", AttributeType: "S"]
      KeySchema:             [AttributeName: "id", KeyType: "HASH"]
      ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1

  test "translateCreateTableParams() override defaults", ->
    assert.eq translateCreateTableParams(
      tableName:             "foo"
      attributes: myKey: 'string'
      key: 'myKey'
      provisioning: read: 10
    ),
      TableName:             "foo"
      AttributeDefinitions:  [AttributeName: "myKey", AttributeType: "S"]
      KeySchema:             [AttributeName: "myKey", KeyType: "HASH"]
      ProvisionedThroughput: ReadCapacityUnits: 10, WriteCapacityUnits: 1

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateProvisioning", ->
  test "translateProvisioning() has defaults", ->
    assert.eq translateProvisioning(),
      ProvisionedThroughput:
        ReadCapacityUnits: 1
        WriteCapacityUnits: 1

  test "translateProvisioning provisioning: read: 10, write: 20", ->
    assert.eq translateProvisioning(provisioning: read: 10, write: 20),
      ProvisionedThroughput:
        ReadCapacityUnits: 10
        WriteCapacityUnits: 20

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateKey", ->
  test "translateKey()", ->
    assert.eq translateKey({}), KeySchema: [AttributeName: "id", KeyType: "HASH"]

  test "translateKey key: foo: 'hash'", ->
    assert.eq translateKey(key: foo: "hash"),
      KeySchema: [AttributeName: "foo", KeyType: "HASH"]

  test "translateKey key: 'foo'", ->
    assert.eq translateKey(key: 'foo'),
      KeySchema: [AttributeName: "foo", KeyType: "HASH"]

  test "translateKey key: 'foo/bar'", ->
    assert.eq translateKey(key: 'foo/bar'),
      KeySchema: [
        {AttributeName: "foo", KeyType: "HASH"}
        {AttributeName: "bar", KeyType: "RANGE"}
      ]

  test "translateKey key: 'foo-bar'", ->
    assert.eq translateKey(key: 'foo-bar'),
      KeySchema: [
        {AttributeName: "foo", KeyType: "HASH"}
        {AttributeName: "bar", KeyType: "RANGE"}
      ]

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateAttributes", ->
  test "translateAttributes()", ->
    assert.eq translateAttributes({}), AttributeDefinitions: [AttributeName: "id", AttributeType: "S"]

  test "translateAttributes Attributes: foo: 'string'", ->
    assert.eq translateAttributes(attributes: foo: "string"),
      AttributeDefinitions: [AttributeName: "foo", AttributeType: "S"]

  test "translateAttributes Attributes: all types", ->
    assert.eq translateAttributes(
      attributes:
        aString: "string"
        aNumber: "number"
        aBinary: "binary"
    ), AttributeDefinitions: [
      {AttributeName: "aString", AttributeType: "S"}
      {AttributeName: "aNumber", AttributeType: "N"}
      {AttributeName: "aBinary", AttributeType: "B"}
    ]

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateGlobalIndexes", ->
  test "translateGlobalIndexes()", ->
    assert.eq translateGlobalIndexes({}), {}

  test "translateGlobalIndexes simplest", ->
    assert.eq translateGlobalIndexes(
      globalIndexes:
        myIndexName: {}
    ),
      GlobalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "id", KeyType: "HASH"]
        Projection:            Type: "ALL", Attributes: []
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
      ]

  test "translateGlobalIndexes custom key", ->
    assert.eq translateGlobalIndexes(
      globalIndexes:
        myIndexName:
          key: 'myHashKeyName'
    ),
      GlobalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "myHashKeyName", KeyType: "HASH"]
        Projection:            Type: "ALL", Attributes: []
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
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
      GlobalSecondaryIndexes: [
        {
          IndexName:             "myFirstIndexName"
          KeySchema:             [AttributeName: "id", KeyType: "HASH"]
          Projection:            Type: "ALL", Attributes: []
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        }
        IndexName:             "myIndexName"
        KeySchema: [
          {AttributeName: "myHashKeyName", KeyType: "HASH"}
          {AttributeName: "myRangeKeyName", KeyType: "RANGE"}
        ]
        Projection:            Type: "KEYS_ONLY", Attributes: ["myNumberAttrName", "myBinaryAttrName"]
        ProvisionedThroughput: ReadCapacityUnits: 5, WriteCapacityUnits: 5
      ]

suite "Art.Aws.StreamlinedApi.StreamlinedDynamoDbApi.translateLocalIndexes", ->
  test "translateLocalIndexes()", ->
    assert.eq translateLocalIndexes({}), {}

  test "translateLocalIndexes simplest", ->
    assert.eq translateLocalIndexes(
      localIndexes:
        myIndexName: {}
    ),
      LocalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "id", KeyType: "HASH"]
        Projection:            Type: "ALL", Attributes: []
      ]

  test "translateLocalIndexes custom key", ->
    assert.eq translateLocalIndexes(
      localIndexes:
        myIndexName:
          key: 'myHashKeyName'
    ),
      LocalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "myHashKeyName", KeyType: "HASH"]
        Projection:            Type: "ALL", Attributes: []
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
      LocalSecondaryIndexes: [
        {
          IndexName:             "myFirstIndexName"
          KeySchema:             [AttributeName: "id", KeyType: "HASH"]
          Projection:            Type: "ALL", Attributes: []
        }
        IndexName:             "myIndexName"
        KeySchema: [
          {AttributeName: "myHashKeyName", KeyType: "HASH"}
          {AttributeName: "myRangeKeyName", KeyType: "RANGE"}
        ]
        Projection:            Type: "KEYS_ONLY", Attributes: ["myNumberAttrName", "myBinaryAttrName"]
      ]
