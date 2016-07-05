{Pipeline} = require 'art-ery'
module.exports = class DynamoDb extends Pipeline
  ###
  TODO
  - before the first request, check/create table in DEV mode
  - declare table structure
  - Environment
    - INSTEAD of production vs development
    - debugInfo: true/false
    - dataSource: production/test
    - server vs client

  ###

  @attributeDefinitions: (map) ->

  @keySchema:
  @globalSecondaryIndexes:
  @localSecondaryIndexes:
  @streamSpecification:

  # AUTO
  @provisionedThroughput: ({ReadCapacityUnits, WriteCapacityUnits}) ->
    @getCreateTableParams.ProvisionedThroughput =
      ReadCapacityUnits: ReadCapacityUnits
      WriteCapacityUnits: WriteCapacityUnits

  @tableName: (name) -> @getCreateTableParams.TableName = name

  @getCreateTableParams: -> @getPrototypePropertyExtendedByInheritance "createTableParams", {}
