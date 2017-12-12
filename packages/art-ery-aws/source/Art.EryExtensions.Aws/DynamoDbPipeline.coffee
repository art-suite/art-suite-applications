{
  defineModule
  mergeInto
  Promise, object, isPlainObject, deepMerge, compactFlatten, inspect
  log, merge, compare, Validator, isString, isFunction, withSort
  formattedInspect
  mergeIntoUnless
  objectWithExistingValues
  present
  isString
} = require 'art-standard-lib'

{Pipeline, KeyFieldsMixin, pipelines, UpdateAfterMixin} = require 'art-ery'
{DynamoDb} = ArtAws = require 'art-aws'

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

    # to-depricate??? use initialize
    createTable: ->
      @_vivifyTable()
      .then -> message: "success"

    initialize: (request)->
      @_vivifyTable()
      .then -> message: "success"

    getInitializeParams: -> @createTableParams

    ################################
    # Direct DynamoDb requests
    ################################
    get: (request) ->
      @_artEryToDynamoDbRequest request,
        requiresKey: true
        then: (params) =>
          @dynamoDb.getItem params
          .then (result) -> result.item || request.missing()

    # inefficient; only use in dev
    getAll: (request) ->
      @scanDynamoDb()
      .then ({items}) ->
        log getAll: items: items?.length
        items

    ###
    TODO: make create fail if the item already exists
      WHY? we have after-triggers that need to only trigger on a real create - not a replace
      AND filters like ValidationFilter assume create is a real create and update is a real update...
      NOTE: replace should be considered an update...
      NOTE: We have createOrUpdate if you really want both.

      ADD "replaceOk" prop
        Only replace existing items if explicitly requested:
        {replaceOk} = request.props
        This will mostly be used internally. Use createOrUpdate for
        that behavior externally.

    HOW to do 'replaceOk':

      http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html
      To prevent a new item from replacing an existing item, use a conditional
      expression that contains the attribute_not_exists function with the name of
      the attribute being used as the partition key for the table. Since every
      record must contain that attribute, the attribute_not_exists function will
      only succeed if no matching item exists.

    ###
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
      support request.props.add and request.props.setDefault
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
                request.success
                  props:
                    oldData: item
                    data: request.requestDataWithKey
              else
                modifiedFields = merge request.data, request.props.add, request.props.setDefault
                request.success
                  props:
                    data: data = mergeInto request.requestDataWithKey, item
                    updatedData: object data,
                      when: (v, k) -> modifiedFields[k]?

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
      request.subrequest @pipelineName, "delete", {key, data, returnNullIfMissing: true}
      .then (result) ->
        result ? request.success data: request.requestDataWithKey

    ###
    This calls 'update' and possibly 'create', so hooks on update OR create will be correctly triggered.
    NOTE: Only after-update OR after-create filters/events will be processed - NOT BOTH!
      Which is the whole reason this exists, really - so the correct after-filters-events fire.

    TODO:
      The new version should do this:
      get {key, returnNullIfMissing: true}
      .then (exists) ->
        if exists
          update {key, data}
          .catch (doesntExists???) ->
            Promise.reject raceConditionOccured: true if doesntExists
          # NOTE - ignoring the race-condition with 'delete'
        else
          create {key, data}
          .catch (exists???) ->
            Promise.reject raceConditionOccured: true if exists
      .catch ({raceConditionOccured}) ->
        if raceConditionOccured && 3 > retryCount = 1 + props.retryCount ? 0
          createOrUpdate {
            key
            props: merge props, {retryCount}
          }
        else
          throw original-error
    ###
    createOrUpdate: (request) ->
      request.requireServerOrigin()
      .then =>
        request.rejectIf @getKeyFieldsString() == 'id', "createOk not available on tables with auto-generated-ids"
      .then =>
        {data, key} = request
        request.subrequest @pipelineName, "update", {key, data, returnNullIfMissing: true}
        .then (result) =>
          result ? request.subrequest @pipelineName, "create", {key, data}

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

          dataToKeyString: (data) ->
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
      requestProps:
        key
        data: {key: value}
          NOTE: null values are moved for CREATE and converted to REMOVE (attribute)
            actions for UPDATE.

        add: {key: value to add} -> dynamodb ADD action
        setDefault: {key: value} -> set attribute if not present
        conditionExpresssion: dynamodb update-of condition expressiong
        returnValues:         art.aws.dynamodb return value selector type

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
        key  = @toKeyObject request.key

      if requestType == "update"
        remove = (k for k, v of data when v == null)
      data = objectWithExistingValues data


      # higher priority
      returnValues = options.returnValues if options.returnValues

      # DEFAULTS
      # NOTE: Art-Ery-Elasicsearch often needs additional fields beyond the ID and updated fields
      # in order to do its update. That means 'allNew' is often the most efficient option for updates.
      returnValues ||= "allNew" if requestType == "update"
      conditionExpression ||= mustExist && key

      objectWithExistingValues {
        @tableName
        data
        key

        # requireServerOrigin
        remove                  # remove attributes
        add
        setDefault
        returnValues
        conditionExpression
      }

    .then options.then
    , ({message}) -> request.clientFailure message
