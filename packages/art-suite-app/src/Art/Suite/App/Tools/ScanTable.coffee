module.exports =
  params: "[pipelineName]"
  action: ({args:[table]}) ->
    Neptune.Art.Aws.DynamoDb.singleton.scan table: Neptune.Art.Ery.Config.getPrefixedTableName table
