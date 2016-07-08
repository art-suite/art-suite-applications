AWS = require 'aws-sdk'
Foundation = require 'art-foundation'
{merge} = Foundation

module.exports = class DynamoDb
  constructor: (options) ->
    endpoint = new AWS.Endpoint options.endpoint if options.endpoint
    @_awsDynamoDb = new AWS.DynamoDB endpoint: endpoint

  invokeAws: (name, params) ->
    new Promise (resolve, reject) =>
      @_awsDynamoDb[name] params,  (err, res) ->
        if err then  reject err
        else         resolve res

  @bindAll: (map) ->
    for name, customMethod of map
      do (name, customMethod) =>
        @::[name] = customMethod || (params) -> @invokeAws name, params

  @bindAll
    createTable: (params) ->
      @invokeAws "createTable",
        merge
          AttributeDefinitions: [AttributeName: 'id', AttributeType: 'S']
          ProvisionedThroughput:
            ReadCapacityUnits: 5
            WriteCapacityUnits: 5
          KeySchema: [AttributeName: 'id', KeyType: 'HASH']
          params

    listTables:       null

    batchGetItem:     null
    batchWriteItem:   null
    deleteItem:       null
    deleteTable:      null
    describeLimits:   null
    describeTable:    null
    getItem:          null
    listTables:       null
    putItem:          null
    query:            null
    scan:             null
    updateItem:       null
    updateTable:      null
    waitFor:          null

