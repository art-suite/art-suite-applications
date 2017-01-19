Uuid = require 'uuid'

Foundation = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'
{AfterEventsFilter} = ArtEry.Filters

{
  Promise, object, isPlainObject, deepMerge, compactFlatten, inspect
  log, merge, compare, Validator, isString, arrayToTruthMap, isFunction, withSort
} = Foundation
{Pipeline} = ArtEry
{DynamoDb} = ArtAws
{encodeDynamoData, decodeDynamoData} = DynamoDb

module.exports = class DynamoDbPipeline extends Pipeline
  @classGetter
    tablesByNameForVivification: ->
      @_tablesByNameForVivificationPromise ||=
        @getDynamoDb().listTables().then ({TableNames}) =>
          arrayToTruthMap TableNames

    dynamoDb: -> DynamoDb.singleton

  @firstAbstractAncestor: @

  ###########################################
  ###########################################
  #
  # AfterEventsFilter and @updateItemsAfter
  #
  ###########################################
  ###########################################
  ###
  IN: eventMap looks like:
    requestType: pipelineName: updateItemPropsFunction

    updateItemPropsFunction: (response) -> updateItemProps
    IN: response is the ArtEry request-response for the request-in-progress on
      the specified pipelineName.
      (response.pipelineName should always == pipelineName)

    OUT: plainObject OR an array (with arbitrary array-nesting) of plainObjects
      The plainObjects are all merged to form one or more AWS updateItem calls.
      They should follow the art-aws streamlined UpdateItem API.
      In general, they should be of the form:
        key: string or object # the DynamoDb item's primary key
        # and one or more of:
        set/item:             (field -> value map)
        add:                  (field -> value to add map)
        setDefault/defaults:  (field -> value to set if no value present)

      SEE: art-aws/.../UpdateItem for more

  EXAMPLE:
    class User extends DynamoDbPipeline
      @updateItemAfter
        create: post: ({data:{userId, createdAt}}) ->
          key: userId
          set: lastPostCreatedAt: createdAt
          add: postCount: 1

  ###
  @updateItemAfter: (eventMap) ->
    throw new Error "primaryKey must be 'id'" unless @_primaryKey == "id"
    for requestType, requestTypeMap of eventMap
      for pipelineName, updateItemPropsFunction of requestTypeMap
        AfterEventsFilter.registerPipelineListener @, pipelineName, requestType
        @_addUpdateItemAfterFunction pipelineName, requestType, updateItemPropsFunction

  @extendableProperty
    updateItemPropsFunctions: {}
    afterEventFunctions: {}

  ###
  IN: eventMap looks like:
    requestType: pipelineName: (response) -> (ignored)
  ###
  @afterEvent: (eventMap) ->
    for requestType, requestTypeMap of eventMap
      for pipelineName, afterEventFunction of requestTypeMap
        AfterEventsFilter.registerPipelineListener @, pipelineName, requestType
        @_addAfterEventFunction pipelineName, requestType, afterEventFunction

  ###########################################
  ###########################################
  @createTablesForAllRegisteredPipelines: ->
    promises = for name, pipeline of ArtEry.pipelines when isFunction pipeline.createTable
      pipeline.createTable()
    Promise.all promises

  @_primaryKey: "id"
  @primaryKey: (@_primaryKey) ->

  @globalIndexes: (globalIndexes) ->
    @_globalIndexes = globalIndexes
    @query @_getAutoDefinedQueries globalIndexes

  @localIndexes: (localIndexes) ->
    @_localIndexes = localIndexes
    @query @_getAutoDefinedQueries localIndexes

  @getter
    globalIndexes: -> @_options.globalIndexes || @class._globalIndexes
    localIndexes: -> @_options.localIndexes || @class._localIndexes
    primaryKey:    -> @class._primaryKey
    status: ->
      @_vivifyTable()
      .then -> "OK: table exists and is reachable"
      .catch -> "ERROR: could not connect to the table"

  constructor: ->
    super
    @primaryKeyFields = @primaryKey.split "/"

  @getter
    dynamoDb: -> DynamoDb.singleton
    tablesByNameForVivification: -> DynamoDbPipeline.getTablesByNameForVivification()

  ###
  TODO:
  Add to ArtAws.DynamoDb:
    getKeyFromDataFunction: (createTableParams) -> (data) -> key
      IN: createTableParams
        The exact same params used to create the table.
      OUT: (data) -> key
        IN: data: plain object record data
        OUT: key: string which encodes the key
          if there is no range-key, then just returns the hashKey as a string
          else, "#{hashKey}/#{rangeKey}"

    Initially, though, I expect all tables to have a simple hashKey: 'id'
    Indexes will take care of most our rangeKey needs.
  ###

  queryDynamoDb:  (params)         -> @dynamoDb.query      merge params, table: @tableName
  scanDynamoDb:   (params)         -> @dynamoDb.scan       merge params, table: @tableName
  withDynamoDb:   (action, params) -> @dynamoDb[action]    merge params, table: @tableName
  updateItem:     (params) ->
    @dynamoDb.updateItem merge params,
      table: @tableName
      # ensure we are updating an existing record only - updated to work with any primaryKey
      conditionExpression: object @primaryKeyFields, (field) -> params.key[field] || params.key

  stripPrimaryKeyFieldsFromData: (data) ->
    data && object data, when: (v, k) => not(k in @primaryKeyFields)

  dynamoDbParamsFromRequest: (request, isCreate = false) ->
    {key, data} = request
    if data
      throw new Error "DynamoDbPipeline##{request.type}: data must be an object. data = #{inspect data}" unless isPlainObject data

    table: @tableName
    key: !isCreate && if isPlainObject key
        key
      else if isString key
        id: key
      else
        data = @stripPrimaryKeyFieldsFromData data
        object @primaryKeyFields, (v) -> request.data[v]
    item: data

  @handlers
    get: (request) ->
      @dynamoDb.getItem @dynamoDbParamsFromRequest request
      .then (result) -> result.item || request.missing()

    createTable: ->
      @_vivifyTable()
      .then -> message: "success"

    create: (request) ->
      @dynamoDb.putItem @dynamoDbParamsFromRequest request, true
      .then -> request.data

    update: (request) ->
      @updateItem @dynamoDbParamsFromRequest request
      .then ({item}) -> item
      .catch (error) ->
        if error.message.match /ConditionalCheckFailedException/
          request.missing "Attempted to update a non-existant record."
        else throw error

    delete: (request) ->
      @dynamoDb.deleteItem @dynamoDbParamsFromRequest request
      .then -> message: "success"

  #########################
  # PRIVATE
  #########################
  @_getAutoDefinedQueries: (indexes) ->
    return {} unless indexes
    queries = {}

    for queryModelName, indexKey of indexes when isString indexKey
      do (queryModelName, indexKey) =>
        [hashKey, sortKey] = indexKey.split "/"
        whereClause = {}
        queries[queryModelName] =
          query: (request) ->
            whereClause[hashKey] = request.key
            request.pipeline.queryDynamoDb
              index: queryModelName
              where: whereClause
            .then ({items}) -> items

          queryKeyFromRecord: (data) ->
            # log queryKeyFromRecord: data: data, hashKey: hashKey, value: data[hashKey]
            data[hashKey]

          localSort: (queryData) -> withSort queryData, (a, b) ->
            if 0 == ret = compare a[sortKey], b[sortKey]
              compare a.id, b.id
            else
              ret

    queries


  @_addUpdateItemAfterFunction: (pipelineName, requestType, updateItemPropsFunction) ->
    ((@extendUpdateItemPropsFunctions()[pipelineName]||={})[requestType]||=[])
    .push updateItemPropsFunction

  @_addAfterEventFunction: (pipelineName, requestType, afterEventFunction) ->
    ((@extendAfterEventFunctions()[pipelineName]||={})[requestType]||=[])
    .push afterEventFunction

  # OUT: updateItemPropsBykey
  @_mergeUpdateItemProps: _mergeUpdateItemProps = (manyUpdateItemProps) ->
    object (compactFlatten manyUpdateItemProps),
      key: ({key}) -> key
      with: (props, key, into) ->
        if into[props.key]
          deepMerge into[props.key], props
        else
          props

  ###
  Executes all @updateItemPropsFunctions appropriate for the current request.
  Then merge them together so we only have one update per unique record-id.
  ###
  emptyArray = []
  @handleRequestAfterEvent: (request) ->
    {pipelineName, type} = request
    updateItemPromises = for updateItemFunction in @getUpdateItemPropsFunctions()[pipelineName]?[type] || emptyArray
      Promise.then -> updateItemFunction request

    afterEventPromises = for afterEventFunction in @getAfterEventFunctions()[pipelineName]?[type] || emptyArray
      Promise.then -> afterEventFunction request

    Promise.all([
      Promise.all updateItemPromises
      Promise.all afterEventPromises
    ])
    .then ([manyUpdateItemProps]) =>
      promises = for key, props of _mergeUpdateItemProps manyUpdateItemProps
        @singleton.updateItem props
      Promise.all promises

  _vivifyTable: ->
    @_vivifyTablePromise ||= Promise.resolve().then =>
      @tablesByNameForVivification
      .then (tablesByName) =>
        unless tablesByName[@tableName]
          log "#{@getClassName()}#_vivifyTable() dynamoDb table does not exist: #{@tableName}, creating..."
          @_createTable()


  @getter
    dynamoDbCreationAttributes: ->
      out = {}
      for k, v of @normalizedFields
        if v.dataType == "string" || v.dataType == "number"
          out[k] = v.dataType
      out

    streamlinedCreateTableParams: ->
      merge
        table: @tableName
        globalIndexes: @globalIndexes
        localIndexes: @localIndexes
        attributes: @dynamoDbCreationAttributes
        (key: @primaryKey if @primaryKey)
        @_options

    createTableParams: ->
      ArtAws.StreamlinedDynamoDbApi.CreateTable.translateParams @streamlinedCreateTableParams

  _createTable: ->

    @dynamoDb.createTable @streamlinedCreateTableParams
    .catch (e) =>
      log "DynamoDbPipeline#_createTable #{@tableName} FAILED", e
      throw e


