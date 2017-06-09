module.exports =
  params: "[pipelineName]"
  action: ({args:[table]}) ->
    Neptune.Art.Aws.DynamoDb.singleton.describeTable table: Neptune.Art.Ery.Config.getPrefixedTableName table
