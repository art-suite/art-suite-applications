Foundation = null
ArtAws = null

beforeActions = ->
  Foundation = require 'art-foundation'
  ArtAws = require 'art-aws/Server'

  AWS.config.region = 'us-west-2'
  ArtAws.config.dynamoDb =
    accessKeyId:    'thisIsSomeInvalidKey'
    secretAccessKey:'anEquallyInvalidSecret!'
    region:         'us-east-1'
    endpoint:       'http://localhost:8081'
    maxRetries:     5

actions =
  listTables: ->
    ArtAws.DynamoDb.singleton.listTables()
  describeTable:
    params: "<table>"
    action: (table) ->
      ArtAws.DynamoDb.singleton.describeTable table: table
  scanTable:
    params: "<table>"
    action: (table) ->
      ArtAws.DynamoDb.singleton.scan table: table

(require 'art-foundation/buildCommander')
  actions: actions
  package: require './package.json'
  beforeActions: beforeActions
