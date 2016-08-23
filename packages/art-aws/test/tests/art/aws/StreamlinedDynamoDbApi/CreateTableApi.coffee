{log} = require 'art-foundation'
{CreateTableApi} = Neptune.Art.Aws.StreamlinedDynamoDbApi
# { _translateProvisioning, _translateKey, _translateAttributes
#   _translateGlobalIndexes
#   _translateLocalIndexes
#   new CreateTableApi().translateParams
#   _getKeySchemaAttributes
# } = Neptune.Art.Aws.StreamlinedDynamoDbApi.CreateTableApi

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi.translateParams", ->
  test "new CreateTableApi().translateParams() has defaults", ->
    assert.eq new CreateTableApi().translateParams(table: "foo"),
      TableName:             "foo"
      AttributeDefinitions:  [AttributeName: "id", AttributeType: "S"]
      KeySchema:             [AttributeName: "id", KeyType: "HASH"]
      ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1

  test "new CreateTableApi().translateParams() override defaults", ->
    assert.eq new CreateTableApi().translateParams(
      table:             "foo"
      attributes: myKey: 'string'
      key: 'myKey'
      provisioning: read: 10
    ),
      TableName:             "foo"
      AttributeDefinitions:  [AttributeName: "myKey", AttributeType: "S"]
      KeySchema:             [AttributeName: "myKey", KeyType: "HASH"]
      ProvisionedThroughput: ReadCapacityUnits: 10, WriteCapacityUnits: 1

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi._translateProvisioning", ->
  test "_translateProvisioning() has defaults", ->
    assert.eq new CreateTableApi()._translateProvisioning(),
      ProvisionedThroughput:
        ReadCapacityUnits: 1
        WriteCapacityUnits: 1

  test "_translateProvisioning provisioning: read: 10, write: 20", ->
    assert.eq new CreateTableApi()._translateProvisioning(provisioning: read: 10, write: 20),
      ProvisionedThroughput:
        ReadCapacityUnits: 10
        WriteCapacityUnits: 20

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi._translateKey", ->
  test "_translateKey()", ->
    assert.eq new CreateTableApi()._translateKey({}), KeySchema: [AttributeName: "id", KeyType: "HASH"]

  test "_translateKey key: foo: 'hash'", ->
    assert.eq new CreateTableApi()._translateKey(key: foo: "hash"),
      KeySchema: [AttributeName: "foo", KeyType: "HASH"]

  test "_translateKey key: 'foo'", ->
    assert.eq new CreateTableApi()._translateKey(key: 'foo'),
      KeySchema: [AttributeName: "foo", KeyType: "HASH"]

  test "_translateKey key: 'foo/bar'", ->
    assert.eq new CreateTableApi()._translateKey(key: 'foo/bar'),
      KeySchema: [
        {AttributeName: "foo", KeyType: "HASH"}
        {AttributeName: "bar", KeyType: "RANGE"}
      ]

  test "_translateKey key: 'foo-bar'", ->
    assert.eq new CreateTableApi()._translateKey(key: 'foo-bar'),
      KeySchema: [
        {AttributeName: "foo", KeyType: "HASH"}
        {AttributeName: "bar", KeyType: "RANGE"}
      ]

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi._translateAttributes", ->
  test "_translateAttributes()", ->
    assert.eq new CreateTableApi()._translateAttributes({}), AttributeDefinitions: [AttributeName: "id", AttributeType: "S"]

  test "_translateAttributes Attributes: foo: 'string'", ->
    assert.eq new CreateTableApi()._translateAttributes(attributes: foo: "string"),
      AttributeDefinitions: [AttributeName: "foo", AttributeType: "S"]

  test "_translateAttributes Attributes: all types", ->
    assert.eq new CreateTableApi()._translateAttributes(
      attributes:
        aString: "string"
        aNumber: "number"
        aBinary: "binary"
    ), AttributeDefinitions: [
      {AttributeName: "aString", AttributeType: "S"}
      {AttributeName: "aNumber", AttributeType: "N"}
      {AttributeName: "aBinary", AttributeType: "B"}
    ]

  test "_translateAttributes only includes attributes in KeySchemas", ->
    assert.eq new CreateTableApi()._translateAttributes(
      {attributes:
        aString: "string"
        aNumber: "number"
        aBinary: "binary"
      },
      ["aNumber"]
    ), AttributeDefinitions: [
      {AttributeName: "aNumber", AttributeType: "N"}
    ]

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi._getKeySchemaAttributes", ->
  test "basic", ->
    assert.eq(
      new CreateTableApi()._getKeySchemaAttributes KeySchema: [AttributeName: "aNumber", KeyType: "HASH"]
      ["aNumber"]
    )

  test "goes deep", ->
    assert.eq(
      new CreateTableApi()._getKeySchemaAttributes
        KeySchema: [AttributeName: "aNumber", KeyType: "HASH"]
        GlobalSecondaryIndexes: [
          IndexName:             "myIndexName"
          KeySchema: [
              {AttributeName: "myHashKeyName", KeyType: "HASH"}
              AttributeName: "myRangeKeyName", KeyType: "RANGE"
            ]
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        ]
      ["aNumber", "myHashKeyName", "myRangeKeyName"]
    )

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi._translateGlobalIndexes", ->
  test "_translateGlobalIndexes()", ->
    assert.eq new CreateTableApi()._translateGlobalIndexes({}), {}

  test "_translateGlobalIndexes globalIndexes: foo:'hashKey'", ->
    assert.eq new CreateTableApi()._translateGlobalIndexes(globalIndexes: foo:'hashKey'),
      GlobalSecondaryIndexes: [
        IndexName: "foo"
        KeySchema: [
          AttributeName: "hashKey"
          KeyType:       "HASH"
        ]
        Projection:            ProjectionType: "ALL"
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
      ]

  test "_translateGlobalIndexes globalIndexes: foo:'hashKey/rangeKey'", ->
    assert.eq new CreateTableApi()._translateGlobalIndexes(globalIndexes: foo:'hashKey/rangeKey'),
      GlobalSecondaryIndexes: [
        IndexName: "foo"
        KeySchema: [
          {
          AttributeName: "hashKey"
          KeyType:       "HASH"
          }
          AttributeName: "rangeKey"
          KeyType:       "RANGE"
        ]
        Projection:            ProjectionType: "ALL"
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
      ]

  test "_translateGlobalIndexes simplest", ->
    assert.eq new CreateTableApi()._translateGlobalIndexes(
      globalIndexes:
        myIndexName: {}
    ),
      GlobalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "id", KeyType: "HASH"]
        Projection:            ProjectionType: "ALL"
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
      ]

  test "_translateGlobalIndexes custom key", ->
    assert.eq new CreateTableApi()._translateGlobalIndexes(
      globalIndexes:
        myIndexName:
          key: 'myHashKeyName'
    ),
      GlobalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "myHashKeyName", KeyType: "HASH"]
        Projection:            ProjectionType: "ALL"
        ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
      ]

  test "_translateGlobalIndexes everything", ->
    assert.eq new CreateTableApi()._translateGlobalIndexes(
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
          Projection:            ProjectionType: "ALL"
          ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
        }
        IndexName:             "myIndexName"
        KeySchema: [
          {AttributeName: "myHashKeyName", KeyType: "HASH"}
          {AttributeName: "myRangeKeyName", KeyType: "RANGE"}
        ]
        Projection:            ProjectionType: "KEYS_ONLY", NonKeyAttributes: ["myNumberAttrName", "myBinaryAttrName"]
        ProvisionedThroughput: ReadCapacityUnits: 5, WriteCapacityUnits: 5
      ]

suite "Art.Aws.StreamlinedDynamoDbApi.CreateTableApi._translateLocalIndexes", ->
  test "_translateLocalIndexes()", ->
    assert.eq new CreateTableApi()._translateLocalIndexes({}), {}

  test "_translateLocalIndexes simplest", ->
    assert.eq new CreateTableApi()._translateLocalIndexes(
      localIndexes:
        myIndexName: {}
    ),
      LocalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "id", KeyType: "HASH"]
        Projection:            ProjectionType: "ALL"
      ]

  test "_translateLocalIndexes custom key", ->
    assert.eq new CreateTableApi()._translateLocalIndexes(
      localIndexes:
        myIndexName:
          key: 'myHashKeyName'
    ),
      LocalSecondaryIndexes: [
        IndexName:             "myIndexName"
        KeySchema:             [AttributeName: "myHashKeyName", KeyType: "HASH"]
        Projection:            ProjectionType: "ALL"
      ]

  test "_translateLocalIndexes everything", ->
    assert.eq new CreateTableApi()._translateLocalIndexes(
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
          Projection:            ProjectionType: "ALL"
        }
        IndexName:             "myIndexName"
        KeySchema: [
          {AttributeName: "myHashKeyName", KeyType: "HASH"}
          {AttributeName: "myRangeKeyName", KeyType: "RANGE"}
        ]
        Projection:            ProjectionType: "KEYS_ONLY", NonKeyAttributes: ["myNumberAttrName", "myBinaryAttrName"]
      ]
