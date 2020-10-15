module.exports =
  params: "[pipeline] [request] [options]"
  help: "Send an ArtEry request. options should be a JavaScript object-literal."
  action: (pipelineName, requestType, optionsString) ->
    {log, wordsArray, lowerCamelCase, isPlainObject, merge, isString, inspect, inspectLean} = require 'art-foundation'
    {pipelines} = require 'art-ery'

    throw new Error "pipelineName required" unless isString pipelineName
    throw new Error "requestType required" unless isString requestType

    throw new Error "pipeline #{inspect pipelineName} not found" unless pipeline = pipelines[pipelineName]
    throw new Error "requestType #{inspect requestType} not valid" unless pipeline[requestType]

    log optionsString:optionsString
    requestOptions = if optionsString
      eval optionsString
    else
      {}

    log "> #{pipelineName}.#{requestType} #{inspectLean requestOptions, forArgs: true}"
    pipeline[requestType] requestOptions
