{merge, compactFlatten} = require 'art-standard-lib'
{
  createWithPostCreate
  missing
  Pipeline
  Filter
  merge
  log
} = merge compactFlatten require '../../../StandardImport'

log {Pipeline}
module.exports = createWithPostCreate class SimplePipeline extends Pipeline

  constructor: ->
    super
    @_store = {}
    @_nextUniqueKey = 0

  @getter "store",
    nextUniqueKey: ->
      @_nextUniqueKey++ while @_store[@_nextUniqueKey]
      (@_nextUniqueKey++).toString()

  @publicRequestTypes "reset get getAll create update delete"

  @handlers
    reset: ({data}) ->
      @_store = data || {}
      {}

    get: ({key}) ->
      @_store[key]

    getAll: ->
      for k in (Object.keys(@_store).sort())
        @store[k]

    create: (request) ->
      {data} = request
      data = if data.id
        data
      else
        merge data, id: @nextUniqueKey

      if @_store[data.id]
        request.clientFailure "Record already exists with id: #{data.id}"
      else
        @_store[data.id] = data

    update: ({key, data}) ->
      if previousData = @_store[key]
        @_store[key] = merge previousData, data

    delete: ({key}) ->
      if previousData = @_store[key]
        @_store[key] = null
        previousData
