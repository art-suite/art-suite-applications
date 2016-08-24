# art-aws
Streamlined APIs for AWS SDK with Promises and Art.Foundation

Currently supported:
* DynamoDb (partial support)

### Benefits
* all methods are wrapped in promises
* Streamlined API
  * cleaner and dramatically reduced param size
    * reasonable defaults
    * lowerCamelCase property names for consistency with JavaScript
    * shorter property names (without sacrificing clarity)
    * method-specific params restructuring for additional clarity and reductions
  * item data read and written is always in plain JavaScript data structures (JSON-compatible data-structures)
    * currently supported: string, number, object, array
    * future: could easily add support for all DynamoDb data-types

#### Streamlined API Example: property names
```coffeeScript
# Streamlined API
provisioning:
  read: 1
  write: 1

# Standard API
ProvisionedThroughput:
  ReadCapacityUnits: 1
  WriteCapacityUnits: 1
```

#### Streamlined API Example: `createTable`
```coffeescript
# Streamlined API:
dynamoDb.createTable
  table: "fooBarTestTable"
  key: "chatRoom/id"
  attributes:
    id:         "number"
    chatRoom:   "string"
    createdAt:  "number"

  globalIndexes:
    chatsByChatRoomCreatedAt: "chatRoom/createdAt"
.then ->
  # ...

# Standard API:
dynamoDb.createTable
  TableName: "fooBarTestTable"
  GlobalSecondaryIndexes: [
    IndexName: "chatsByChatRoomCreatedAt"
    KeySchema: [
      {AttributeName: "chatRoom", KeyType: "HASH"}
      {AttributeName: "createdAt", KeyType: "RANGE"}
    ]
    Projection: ProjectionType: "ALL"
    ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
  ]
  KeySchema: [
    {AttributeName: "chatRoom", KeyType: "HASH"}
    {AttributeName: "id", KeyType: "RANGE"}
  ]
  AttributeDefinitions: [
    {AttributeName: "id", AttributeType: "N"}
    {AttributeName: "chatRoom", AttributeType: "S"}
    {AttributeName: "createdAt", AttributeType: "N"}
  ]
  ProvisionedThroughput: ReadCapacityUnits: 1, WriteCapacityUnits: 1
.then ->
  # ...
```

#### Streamlined API Example: `query`
```coffeescript
# Streamlined API
dynamoDb.query
  table: "fooBarTestTable"
  descending: true
  where:
    chatRoom: "xyz456"
    id: gt: 1
.then ({items}) ->
  # items is an array of plain javascript objects
  # Items is the standard DynamoDb-encoded Items list

# Standard API
dynamoDb.query
  TableName: "fooBarTestTable"
  ScanIndexForward: false
  KeyConditionExpression: "(#attr1 = :val1 AND #attr2 > :val2)"
  ExpressionAttributeNames:
    "#attr1": "chatRoom"
    "#attr2": "id"

  ExpressionAttributeValues:
    ":val1": S: "xyz456"
    ":val2": N: "1"
.then ({items, Items}) ->
  # items is an array of plain javascript objects
  # Items is the standard DynamoDb-encoded Items list
```
### Usage
* Input API
  * you can use the standard DynamoDb API params, OR
  * you can use the Streamlined API params
  * All table methods automatically detect which API you are using with this test:
    * if `params.TableName`
      * DynamoDb API is used
    * else
      * Streamlined API is used
      * NOTE: `params.table` is expected to specify the table-name
* Output API
  * The output object contains the standard DynamoDb response
    * note: DynamoDb uses UpperCamelCase property names
  * The output object may ALSO contain streamlined-api properties
    * example: the 'items' property returned by a 'query' is a list of the result items as plain-javascript objects
    * note: the streamelined-api uses lowerCamelCase property names
