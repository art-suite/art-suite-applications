{
  defineModule
  mergeInto
  Promise, object, isPlainObject, deepMerge, compactFlatten, inspect
  log, merge, compare, Validator, isString, isFunction, withSort
  formattedInspect
  mergeIntoUnless
  objectWithExistingValues
  present
} = require 'art-foundation'

{Pipeline, KeyFieldsMixin, pipelines} = require 'art-ery'
{DynamoDb} = require 'art-aws'

UpdateAfterMixin = require './UpdateAfterMixin'

defineModule module, class DynamoDbPipeline extends KeyFieldsMixin UpdateAfterMixin Pipeline
  @abstractClass()

  ###########################################
  # Class API
  ###########################################

  @createTablesForAllRegisteredPipelines: ->
    promises = for name, pipeline of pipelines when isFunction pipeline.createTable
      pipeline.createTable()
    Promise.all promises

  @classGetter
    dynamoDb: -> DynamoDb.singleton

  ###########################################
  # Indexes
  ###########################################
  @globalIndexes: (globalIndexes) ->
    @_globalIndexes = globalIndexes
    @query @_getAutoDefinedQueries globalIndexes

  @localIndexes: (localIndexes) ->
    @_localIndexes = localIndexes
    @query @_getAutoDefinedQueries localIndexes

  @getter
    globalIndexes: -> @_options.globalIndexes || @class._globalIndexes
    localIndexes:  -> @_options.localIndexes  || @class._localIndexes

  ###########################################
  # Instance Getters
  ###########################################

  @getter
    status: ->
      @_vivifyTable()
      .then -> "OK: table exists and is reachable"
      .catch -> "ERROR: could not connect to the table"
    dynamoDb: -> DynamoDb.singleton

  ###########################################
  # Helpers - not sure these should be public at all
  ###########################################
  queryDynamoDb:  (params)         -> @dynamoDb.query      merge params, table: @tableName
  scanDynamoDb:   (params)         -> @dynamoDb.scan       merge params, table: @tableName
  withDynamoDb:   (action, params) -> @dynamoDb[action]    merge params, table: @tableName

  ###########################################
  # Handlers
  ###########################################
  @handlers

    createTable: ->
      @_vivifyTable()
      .then -> message: "success"

    ################################
    # Direct DynamoDb requests
    ################################
    get: (request) ->
      @_artEryToDynamoDbRequest request,
        requiresKey: true
        then: (params) =>
          @dynamoDb.getItem params
          .then (result) -> result.item || request.missing()

    # TODO: make create fail if the item already exists
    # WHY? we have after-triggers that need to only trigger on a real create - not a replace
    # AND filters like ValidationFilter assume create is a real create and update is a real update...
    # NOTE: replace should be considered an update...
    create: (request) ->
      @_artEryToDynamoDbRequest request, then: (params) =>
        @dynamoDb.putItem params
        .then -> request.data

    ###
    IN: response.props:
      createOk: true/falsish
        NOTE:
          A) can only use on tables which don't auto-generate-ids

    OUT:
      if record didn't exist:
        if createOk
          record was created
        response.status == missing
      else
        data: all fields with their current values (returnValues: 'allNew')

    TODO:
      support request.props.add and request.props.setDefaults
        for both: requireOriginatedOnServer
    ###
    update: (request) ->
      {createOk} = request.props
      request.requireServerOriginIf createOk, "to use createOk"
      .then =>
        request.rejectIf createOk && @getKeyFieldsString() == 'id', "createOk not available on tables with auto-generated-ids"
      .then =>
        @_artEryToDynamoDbRequest request,
          mustExist: !createOk
          requiresKey: true
          then: (dynamoDbParams)=>
            @dynamoDb.updateItem dynamoDbParams
            .then ({item}) ->
              if dynamoDbParams.returnValues?.match /old/i
                item
              else
                mergeInto item, dynamoDbParams.key
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
      @_artEryToDynamoDbRequest request,
        mustExist: true
        returnValues: "allOld"
        then: (deleteItemParams) =>
          @dynamoDb.deleteItem deleteItemParams
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
    NOTE: Only after-update OR after-create filters/events will be processed - NOT BOTH!
      Which is the whole reason this exists, really - you the correct after-filters-events fire.
    ###
    createOrUpdate: (request) ->
      request.requireServerOrigin()
      .then =>
        request.rejectIf @getKeyFieldsString() == 'id', "createOk not available on tables with auto-generated-ids"
      .then =>
        {data} = request
        request.subrequest @pipelineName, "update", {data}
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

          toKeyString: (data) ->
            data[hashKey]

          localSort: (queryData) -> withSort queryData, (a, b) ->
            if 0 == ret = compare a[sortKey], b[sortKey]
              compare a.id, b.id
            else
              ret

    queries

  _vivifyTable: ->
    @_vivifyTablePromise ||= Promise.resolve().then =>
      @tablesByNameForVivification
      .then (tablesByName) =>
        unless tablesByName[@tableName]
          log.warn "#{@getClassName()}#_vivifyTable() dynamoDb table does not exist: #{@tableName}, creating..."
          @_createTable()

  @classGetter
    tablesByNameForVivification: ->
      @_tablesByNameForVivificationPromise ||=
        @getDynamoDb().listTables().then ({TableNames}) =>
          object TableNames, -> true

  @getter
    tablesByNameForVivification: -> DynamoDbPipeline.getTablesByNameForVivification()

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
        key: @keyFieldsString
        @_options

    createTableParams: ->
      ArtAws.StreamlinedDynamoDbApi.CreateTable.translateParams @streamlinedCreateTableParams

  _createTable: ->

    @dynamoDb.createTable @streamlinedCreateTableParams
    .catch (e) =>
      log.error "DynamoDbPipeline#_createTable #{@tableName} FAILED", e
      throw e


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
  _artEryToDynamoDbRequest: (request, options = {}) ->
    {requiresKey, mustExist} = options
    requiresKey = true if mustExist

    {key, data, add, setDefault, conditionExpression, returnValues} = request.props
    {requestType} = request

    Promise
    .then => request.requireServerOriginOr !(add || setDefault || conditionExpression || returnValues), "to use add, setDefault, returnValues, or conditionExpression props"
    .then => request.require !(add || setDefault) || requestType == "update", "add and setDefault only valid for update requests"
    .then =>
      if requiresKey
        data = @dataWithoutKeyFields data
        key  = @_getNormalizedKeyFromRequest request

      # higher priority
      returnValues = options.returnValues if options.returnValues

      # defaults
      returnValues ||= "allNew" if requestType == "update" && add || setDefault
      conditionExpression ||= mustExist && key

      objectWithExistingValues {
        @tableName
        data
        key

        # requireServerOrigin
        add
        setDefault
        returnValues
        conditionExpression
      }

    .then options.then
    , ({message}) -> request.clientFailure message

  _getNormalizedKeyFromRequest: (request) ->
    {key, data, type} = request
    key ||= data

    if isPlainObject key
      @toKeyObject key
    else if isString key
      "#{@keyFields[0]}": key
    else
      # log.error {request, key, data, type}
      throw new Error "DynamoDbPipeline: expected key to be an object or a string: #{formattedInspect {key, data}}"
