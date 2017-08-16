
module.exports =
  params: "[pipelineName]"
  help: "invoke 'initialize' on every pipeline (creates tables)"
  action: (options) ->
    {array, log, wordsArray, lowerCamelCase, isPlainObject, merge, isString} = require 'art-standard-lib'
    {args:[pipelineName]} = options
    pipelineName = null unless isString pipelineName
    {pipelines} = require 'art-ery'
    ArtAws = require 'art-aws'

    errors = []
    promises = array pipelines,
      when: (pipe, name) -> pipe.initialize && (!pipelineName || pipelineName == name)
      with: (pipe, name) ->
        pipe.initialize()
        .then => pipe
        .catch (response) =>
          console.error response
          errors.push ["error creating table: #{pipe.tableName}",
            pipe: pipe
            response: response
          ]
    Promise.all promises
    .then (pipelines)->
      if errors.length > 0
        errors
      else
        ArtAws.DynamoDb.singleton.listTables()
        .then (tables) ->
          dynamoDbTables: tables
          pipelinesInitialized: pipelines
