Uuid = require 'uuid'

Foundation = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'
{AfterEventsFilter} = ArtEry.Filters

{
  Promise, object, isPlainObject, deepMerge, compactFlatten, inspect
  log, merge, compare, Validator, isString, arrayToTruthMap, isFunction, withSort
  formattedInspect
  mergeIntoUnless
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
  updateItem:     (params)         -> @dynamoDb.updateItem merge params, table: @tableName
  deleteItem:     (params)         -> @dynamoDb.deleteItem merge params, table: @tableName

  stripPrimaryKeyFields: (o) ->
    o && object o, when: (v, k) => not(k in @primaryKeyFields)

  getKeyFields: (data) ->
    object @primaryKeyFields, (v) ->
      unless ret = data[v]
        throw new Error "DynamoDbPipeline: must provide all primaryKeyFields (missing: #{formattedInspect v})"
      ret

  getNormalizedKeyFromRequest: ({key, data, type}) ->
    key ||= data

    if isPlainObject key
      @getKeyFields key
    else if isString key
      "#{@primaryKeyFields[0]}": key
    else
      throw new Error "DynamoDbPipeline: expected key to be an object or a string: #{formattedInspect {key, data}}"

  ###
  IN:
    request:
    requiresKey: true/false
      true:  key and data will be normalized using the primaryKey fields
      false: there willbe no key

    action: (streamlinedDynamoDbParams) -> out

  OUT:
    promise.catch (error) ->                # only internalErrors are thrown
    promise.then (clientFailureResponse) -> # if input is invalid, return clientFailure without invoking action
    promise.then (out) ->                   # otherwise, returns action's return value
  ###
  artEryToDynamoDbRequest: (request, options = {}) ->
    {requiresKey, mustExist, returnValues} = options
    requiresKey = true if mustExist

    Promise
    .then =>
      {key, data, dynamoDbParams} = request.props

      if requiresKey
        data = @stripPrimaryKeyFields data
        key  = @getNormalizedKeyFromRequest request

      out =
        table:  @tableName
        item:   data
        key:    key

      if dynamoDbParams
        request.requireServerOrigin "to use dynamoDbParams"
        mergeIntoUnless out, dynamoDbParams

      if mustExist
        out.conditionExpression = merge out.conditionExpression, key

      if returnValues
        out.returnValues = returnValues

      out

    .then options.then
    , ({message}) -> request.clientFailure message

  @handlers

    createTable: ->
      @_vivifyTable()
      .then -> message: "success"

    ################################
    # Direct DynamoDb requests
    ################################
    get: (request) ->
      @artEryToDynamoDbRequest request,
        requiresKey: true
        then: (params) =>
          @dynamoDb.getItem params
          .then (result) -> result.item || request.missing()

    # TODO: make create fail if the item already exists
    # TODO: add createOrReplace - if we need it
    # WHY? we have after-triggers that need to only trigger on a real create - not a replace
    # AND filters like ValidationFilter assume create is a real create and update is a real update...
    # NOTE: replace should be considered an update...
    create: (request) ->
      @artEryToDynamoDbRequest request, then: (params) =>
        @dynamoDb.putItem params
        .then -> request.data

    ###
    OUT:
      if record didn't exist:
        response.status == missing
      else
        data: values of updated fields
    ###
    update: (request) ->
      @artEryToDynamoDbRequest request,
        mustExist: true
        then: (dynamoDbParams)=>
          @updateItem dynamoDbParams
          .then ({item}) -> item
          .catch (error) ->
            if error.message.match /ConditionalCheckFailedException/
              request.missing "Attempted to update a non-existant record."
            else throw error

    ###
    OUT:
      if record didn't exist:
        response.status == missing
      else
        data: keyFields & values
    ###
    delete: (request) ->
      @artEryToDynamoDbRequest request,
        mustExist: true
        returnValues: "allOld"
        then: (deleteItemParams) =>
          @deleteItem deleteItemParams
          .then ({item}) -> item
          .catch (error) ->
            if error.message.match /ConditionalCheckFailedException/
              request.missing "Attempted to delete a non-existant record."
            else throw error

    ################################
    # Compound Requests
    ################################

    ###
    This calls 'get' first, then calls 'delete' if it exists. Therefor 'delete' hooks
    will only fire if the record actually exists.

    OUT: promise.then (response) -> response.data == key(s)
    ###
    deleteIfExists: (request) ->
      {key, data} = request
      request.subrequest @pipelineName, "delete", {key, data}
      .catch (error) ->
        if error?.info?.response?.isMissing
          # still a success if the record didn't exist
          request.success data: merge key, data
        else throw error

    ###
    This calls 'update' and possibly 'create', so hooks on update an create will be triggered.
    NOTE: update fails if the record doesn't exist, so after-create-hooks will not be triggered.
    ###
    createOrUpdate: (request) ->
      throw new Error "no available on tables with auto-generated-ids" if @primaryKey == 'id'
      {data} = request
      request.subrequest @pipelineName, "update",
        data: data
        # ensure we return createdAt and updatedAt; client can test if a new record was created
        # by seeing if they are == or not. Also used for testing.
        requestOptions: dynamoDbParams: returnValues: "allNew"
      .catch (error) =>
        if error?.info?.response?.isMissing
          request.subrequest @pipelineName, "create", {data}
        else throw error

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
  @_mergeUpdateItemProps: (manyUpdateItemProps) ->
    object (compactFlatten manyUpdateItemProps),
      key: ({key}) -> key
      with: (props, key, into) =>
        unless props.key
          log.error "key not found for one or more updateItem entries": {manyUpdateItemProps}
          throw new Error "#{@getName()}.updateItemAfter: key required for each updateItem param set (see log for details)"
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
    {pipelineName, requestType} = request
    updateItemPromises = for updateItemFunction in @getUpdateItemPropsFunctions()[pipelineName]?[requestType] || emptyArray
      Promise.then => updateItemFunction.call @singleton, request

    afterEventPromises = for afterEventFunction in @getAfterEventFunctions()[pipelineName]?[requestType] || emptyArray
      Promise.then => afterEventFunction.call @singleton, request

    Promise.all([
      Promise.all updateItemPromises
      Promise.all afterEventPromises
    ])
    .then ([manyUpdateItemProps]) =>
      promises = for key, props of @_mergeUpdateItemProps manyUpdateItemProps
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


