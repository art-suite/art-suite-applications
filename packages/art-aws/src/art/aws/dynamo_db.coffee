AWS = require 'aws-sdk'
Foundation = require 'art-foundation'
{wordsArray} = Foundation

module.exports = class DynamoDb
  constructor: (options) ->
    endpoint = new AWS.Endpoint options.endpoint if options.endpoint
    @_awsDynamoDb = new AWS.DynamoDB endpoint: endpoint

  @bindAwsFunc: (name) ->
    (params) ->
      new Promise (resolve, reject) =>
        @_awsDynamoDb[name] params,  (err, res) ->
          if err then  reject err
          else         resolve res

  @bindAll: (list) ->
    for name in list
      @::[name] = @bindAwsFunc name

  @bindAll wordsArray "
    listTables
    batchGetItem
    batchWriteItem
    createTable
    deleteItem
    deleteTable
    describeLimits
    describeTable
    getItem
    listTables
    putItem
    query
    scan
    updateItem
    updateTable
    waitFor
  "
