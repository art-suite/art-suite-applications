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
  timeout
  intRand
  isArray
  upperCamelCase
} = require 'art-standard-lib'

{networkFailure} = require 'art-communication-status'

{Pipeline, KeyFieldsMixin, pipelines, UpdateAfterMixin} = require 'art-ery'
{DynamoDb} = ArtAws = require 'art-aws'

defineModule module, class DynamoDbPipelineOldCoffee extends KeyFieldsMixin UpdateAfterMixin Pipeline
  @abstractClass()

  #########################
  # PRIVATE
  #########################
  ###
  IN:
    indexes: <Object> # a map:
      myIndexName: indexKeyOrProps

  indexKeyOrProps:
    <String> indexKey string
    <Object>
      key: <String> indexKey string
      ... other props passed to DynamoDb for index creation; ignored here

  OUT: params for Art.Ery.Pipeline's @query method
    Example:
      myQueryName:
        query: generatedQueryHandler = (request) ->
      ...

  EFFECT - after passed to @query:
    @handlers
      myQueryName:      generatedQueryHandler
      myQueryNameDesc:  generatedQueryHandlerDesc

  generatedQueryHandler Handler API:
    IN:
      REQUIRED: key: hashKeyValue <string>
      OPTIONAL:
        props: where: [sortKey]: # with exactly one of the following:
          eq:           sortValue
          lt:           sortValue
          lte:          sortValue
          gt:           sortValue
          gte:          sortValue
          between:      [sortValueA, sortValueB]  # returns values >= sortValueA and <= sortValueB
          beginsWith:   string-prefix

  ###
  @_getAutoDefinedQueries: (indexes) ->
    return {} unless indexes
    queries = {}

    for queryModelName, indexKey of indexes
      do (queryModelName, indexKey) =>
        if indexKey?.key
          indexKey = indexKey.key
        if isString indexKey
          [hashKey, sortKey] = indexKey.split "/"

          indexName = if indexKey != @getKeyFieldsString()
            queryModelName
          doDynamoQuery = (request, descending) ->
            params = where: "#{hashKey}": request.key
            params.index = indexName if indexName?
            params.descending = true if descending

            if sortKeyWhere = request.props.where?[sortKey]
              if isPlainObject sortKeyWhere
                {eq, lt, lte, gt, gte, between, beginsWith} = sortKeyWhere
                params.where[sortKey] = merge {eq, lt, lte, gt, gte, between, beginsWith}
              else
                params.where[sortKey] = eq: sortKeyWhere

            if select = request.props.select
              if isArray select
                select = compactFlatten(select).join ' '
              unless isString select
                return request.clientFailure "select must be a string or array of strings"

              params.select = select

            request.pipeline.queryDynamoDbWithRequest request, params
            .then ({items}) -> items
            .tapCatch (error) ->
              log DynamoDbPipeline_query: {error, params, request}

          queries[queryModelName] =
            query:            (request) -> doDynamoQuery request
            dataToKeyString:  (data)    -> data[hashKey]
            keyFields:        [hashKey]

            localSort: (queryData) -> withSort queryData, (a, b) ->
              if 0 == ret = compare a[sortKey], b[sortKey]
                compare a.id, b.id
              else
                ret

          queries[queryModelName+"Desc"] =
            query:            (request) -> doDynamoQuery request, true
            dataToKeyString:  (data)    -> data[hashKey]
            keyFields:        [hashKey]

            localSort: (queryData) -> withSort queryData, (b, a) ->
              if 0 == ret = compare a[sortKey], b[sortKey]
                compare a.id, b.id
              else
                ret

    queries


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

    {
      key, data, add, setDefault, conditionExpression, returnValues, consistentRead
      keys
      select
    } = request.props
    {requestType} = request

    @_retryIfServiceUnavailable request, =>
      Promise
      .then => request.requireServerOriginOr !(add || setDefault || conditionExpression || returnValues), "to use add, setDefault, returnValues, or conditionExpression props"
      .then => request.require !(add || setDefault) || requestType == "update", "add and setDefault only valid for update requests"
      .then =>
        if requiresKey
          data = @dataWithoutKeyFields data
          key  = @toKeyObject request.key

        #TODO: keys needs @toKeyObject to work with multi-part keys

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

        consistentRead = true if consistentRead

        objectWithExistingValues {
          @tableName
          data
          key
          keys # for batchGetItem
          select

          # requireServerOrigin
          remove                  # remove attributes
          add
          setDefault
          returnValues
          conditionExpression
          consistentRead
        }

      .then(
        options.then
        ({message}) -> request.clientFailure message
      )
