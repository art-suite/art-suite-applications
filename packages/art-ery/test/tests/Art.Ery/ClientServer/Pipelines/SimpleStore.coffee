{defineModule, randomString, merge} = require 'art-standard-lib'
{Pipeline, KeyFieldsMixin} = require 'art-ery'

defineModule module, class SimpleStore extends KeyFieldsMixin Pipeline
  @abstractClass()

  constructor: ->
    super
    @db = {}

  @publicRequestTypes "reset get create update delete"

  @handlers
    reset: ({data}) ->
      @db = data
      true

    get: ({key}) ->
      @db[key]

    create: (request) ->
      key = if request.pipeline.keyFields.length > 1
        key = request.pipeline.toKeyString request.requestData
      else
        randomString 8
      @db[key] = merge request.data, request.pipeline.toKeyObject key

    update: (request) ->
      {data, key} = request
      key ||= request.pipeline.toKeyString data
      return null unless @db[key]
      @db[key] = merge @db[key], data

    delete: (request) ->
      {key} = request
      key ||= request.pipeline.toKeyString data
      return null unless @db[key]
      out = @db[key]
      delete @db[key]
      out
