module.exports =
  params: "[pipelineName]"
  action: (options) ->
    {log, wordsArray, lowerCamelCase, isPlainObject, merge, isString} = require 'art-foundation'
    {args:[pipelineName]} = options
    {pipelines} = require 'art-ery'
    ArtAws = require 'art-aws'

    errors = []
    promises = for name, pipe of pipelines when pipe.createTable && (!pipelineName || pipelineName == name)
      do (pipe) ->
        pipe.createTable()
        .then => success: pipe
        .catch (response) =>
          console.error response
          errors.push ["error creating table: #{pipe.tableName}",
            pipe: pipe
            response: response
          ]
    Promise.all promises
    .then ->
      if errors.length > 0
        errors
      else
        ArtAws.DynamoDb.singleton.listTables()
