
{
  each
  object
  compactFlatten
  BaseObject, reverseForEach, Promise, log, isPlainObject, inspect, isString, isClass, isFunction, inspect
  CommunicationStatus
  merge
  isPlainArray
  decapitalize
  defineModule
  mergeInto
  arrayToTruthMap
  lowerCamelCase
  peek
  inspectedObjectLiteral
  escapeRegExp
  formattedInspect
  pushIfNotPresent
  w
  currentSecond
  toDate
  plainObjectsDeepEq
  getCodeWords
  pluralize
  present
  getEnv
  success, missing
  getDetailedRequestTracingEnabled
  cleanStackTrace
} = require './StandardImport'
{normalizeFieldProps} = require 'art-validation'

{prefetchedRecordsCache} = require './PrefetchedRecordsCache'

Response = require './Response'
Request = require './Request'
Filter = require './Filter'
DatabaseFilters = require './DatabaseFilters'
Session = require './Session'
{config} = require './Config'
Filters = require './Filters'

PipelineRegistry = require './PipelineRegistry'
RequestResponseBase = require './RequestResponseBase'

###
TODO: (July2019)
  Factor out all ArtFlux-related stuff
    ArtEry should be independent of ArtFlux or any other client-side state-management-system.

    Remaining:

      fluxModelMixins -
        This lets you customize what time of Object is created
        for your models. ArtEry shouldn't know anything about creating models, though...

        However, I DO want a way to declare this info in the Pipeline declaration
        to reduce redundency.

      query:
        Another declaration passed directly to ArtFlux

      aliases:
        Another declaration passed directly to ArtFlux

    Perhaps we need a subclass: PipelineWithFluxModel?

  Namespaced-Registry

    I still don't quite know how I want to do this, but I want BOTH ArtFlux (ArtModels?)
    and ArtEry (ArtPipelines?) to have namespaced registries so you can merge as many
    packages as you want based on ArtSuite without name-conflicts in their registries.

###
defineModule module, class Pipeline extends require './RequestHandler'

  @register: ->
    @singletonClass()
    PipelineRegistry.register @

  # copy-paste this line to any sub-class that shouldn't auto-register
  @abstractClass()

  @postCreateConcreteClass: ({hotReloaded}) ->
    @_defineQueryHandlers()
    @_defineClientHandlerMethods()
    @_initFields()
    @register() unless hotReloaded
    super

  @instantiateFilter: instantiateFilter = (filter) ->
    if isClass filter                 then new filter
    else if isFunction filter         then filter @
    else if filter instanceof Filter  then filter
    else if isPlainObject filter      then new Filter filter
    else throw "invalid filter: #{inspect filter} #{filter instanceof Filter}"

  @getAliases: -> @_aliases || {}

  @addDatabaseFilters: (options) ->
    @filter DatabaseFilters.createDatabaseFilters options, @

  @addDatabaseFiltersV2: (options) ->
    @filter DatabaseFilters.createDatabaseFilters(
      merge
        linkFilterVersion: 2
        options
      @
    )

  getPrefetchedRecord: (key) ->
    prefetchedRecordsCache.get @pipelineName, key

  toKeyString: (key) ->
    return key unless key?
    if isString key
      key
    else if @dataToKeyString && isPlainObject key
      @dataToKeyString key
    else
      throw new Error "override toKeyString or dataToKeyString for non-string-keys like: #{formattedInspect key}"


  ###########################
  # Overrides
  ###########################

  ## isRecord (override as needed)
    # used by Request/Response.withTransformedRecords
  isRecord: (data) -> isPlainObject(data) && present data?.id

  ## getFieldsRequestWillModify (override as needed)
    # called by UserOwnedFilter.before.update for correct authorization validation
    # overriden by Art.Ery.Aws.DynamoDb to support "add" and "setDefault" for a correct modifications-list
  getFieldsRequestWillModify: (request) -> request.data ? {}

  ###########################
  # Declarative API
  ###########################

  @extendableProperty
    queries: {}
    filters: []
    handlers: {}
    clientApiMethodList: []
    fields: {}
    fluxModelMixins: []
    publicRequestTypes: {}

  @publicRequestTypes: (values...) ->
    publicRequestTypes = {}
    for v in compactFlatten values
      for k in w v
        publicRequestTypes[k] = true
    @extendPublicRequestTypes publicRequestTypes

  # delcare handlers and publicRequestTypes as one
  @publicHandlers: (maps...) ->
    for map in maps
      @handlers map
      @publicRequestTypes Object.keys map

  ###
  @artModelMixen adds a mixin to fluxModelMixins

  When createing FluxModels for this pipeline (via ArtEryFluxModel.createModel for example),
  both the records model and each query-model will get these mixins.

  Example:
    class MyPipeline extends Pipeline
      @artModelMixen FluxModelMixinA
      @artModelMixen FluxModelMixinB

    # this action
    ArtEryFluxModel.defineModelsForAllPipelines()

    # defines this model:
    class MyPipeline extends FluxModelMixinB FluxModelMixinA ArtEryFluxModel
  ###
  @artModelMixen: (mixin) -> @extendFluxModelMixins mixin


  ###
  define a single filter OR an array of filters to define.

  NOTE: the order of filter definitions matter:
    last-defined filters FIRST in the before-filter sequence
    last-defined filters LAST in the after-filter sequence

    Example request processing sequence:

      filterDefinedLast.beforeFilter
        filterDefinedSecond.beforeFilter
          filterDefinedFirst.beforeFilter
            handler
          filterDefinedFirst.afterFilter
        filterDefinedSecond.afterFilter
      filterDefinedLast.afterFilter

  IN:
    name: "myFilter"                    # only used for debug purposes
    location: "server"/"client"/"both"  # where the filter will be applied
    before: map:
      requestType: (request) ->
        OUT one of these (or a promise returning one of these):
          request
          - the same request if nothing was filtered
          - a new request with the new, filtered values

          response in the form of:
          - new Response
          - null        >> request.missing()
          - string      >> request.success data: message: string
          - plainObject >> request.success data: plainObject
          - plainArray  >> request.success data: plainArray
          NOTE, if a response is returned, it shortcircuits the handler and all other
            filters. The response is returned directly to the caller.

    after: map:
      requestType: (response) ->
        OUT: same or new response
           NOTE: all after-filters are applied if the handler generated the first response object
           UNLESS there is an error, in which case the error is returned directly.
  ###
  @filter:        (filter)         -> @extendFilters preprocessFilter filter

  ###
  add one or more handlers

  IN map:
    requestType: (request) ->
      IN: ArtEry.Request instance
      OUT:
        ArtEry.Response instance
      OR
        plain data which will be wrapped up in an ArtEry.Response instance

  @handler and @handlers are aliases.
  ###
  @handler:  @extendHandlers
  @handlers: @extendHandlers

  @remoteServer:    (@_remoteServer)    -> # override default (see config.remoteServer)
  @apiRoot:         (@_apiRoot)         -> # override default (see config.apiRoot)
  @tableNamePrefix: (@_tableNamePrefix) -> # override default (see config.tableNamePrefix)

  ###
  declare a query - used by ArtEryFlux

  IN: map:
    queryName: map:
      class properties for anonymous subclass of ArtEryQueryFluxModel

  queryName is used as both the ArtFlux model-name AND the ArtEry request-type:
    Example:
      # invoke query
      myPipeline.myQueryName key: queryKey

      # subscribe to Model in FluxComponent
      @subscriptions
        myQueryName: queryKey
  ###
  @query: (map) ->
    @extendQueries object map, (options, queryName) => @_normalizeQuery queryName, options

  ###
  aliases

  INPUT: zero or more strings or arrays of strings
    - arbitrary nesting of arrays is OK
    - nulls are OK, they are ignored
  OUTPUT: null

  NOTE: @aliases can only be called once

  example:
    class Post extends Pipeline
      @aliases "chapterPost"

  purpose:
    - used by ArtEryFluxComponent to make model aliases
      (see FluxModel.aliases)
  ###
  @aliases: ->
    @_aliases = each arguments, map = {}, (v, k) ->
      map[lowerCamelCase v] = true
    @

  ######################
  # constructor
  ######################
  constructor: (@_options = {}) ->
    super

  getPrefixedTableName: (tableName) => "#{@tableNamePrefix}#{tableName}"

  ### cachedGet - convenient alias altenative to request.cachedGet that matches the new subrequest patterns
    IN:
      request: - the request this will be a subrequest-of
      key: <String> (default: request.key)

    EFFECT:
      calls request.cachedGet. Note, cachedGet's cache is stored in request's context
  ###
  cachedGet: (request, key) ->
    request.cachedGet @pipelineName, key ? request.key

  @classGetter
    pipelineName: -> @_pipelineName || decapitalize @getName()
    pluralPipelineName: ->
      return @_pluralPipelineName if @_pluralPipelineName
      parts = getCodeWords @getPipelineName()
      parts.push pluralize parts.pop()
      @_pluralPipelineName = lowerCamelCase parts

  toString: -> @pipelineName
  getLogName: (requestType) -> "#{requestType}-handler"
  @getter "options",
    pipelineName: -> @class.getPipelineName()
    tableNamePrefix: -> @class._tableNamePrefix || config.tableNamePrefix
    tableName: -> @getPrefixedTableName @name
    normalizedFields: ->
      nf = {}
      for k, v of @fields
        nf[k] = normalizeFieldProps v
      nf

    name:     -> @_name     ||= @_options.name    || decapitalize @class.getName()
    session:  -> @_session  ||= @_options.session || Session.singleton
    handlerRequestTypesMap: (into = {}) ->
      mergeInto into, @handlers
      into

    filterRequestTypesMap: (into = {}) ->
      for filter in @filters
        mergeInto into, filter.beforeFilters
      into

    requestTypesMap: (into = {})->
      @getHandlerRequestTypesMap @getFilterRequestTypesMap into

    requestTypes: -> Object.keys @requestTypesMap

    aliases: -> Object.keys @class.getAliases()
    inspectedObjects: -> inspectedObjectLiteral @name
    isRemoteClient: -> !!@remoteServer
    apiRoot: -> @class._apiRoot || config._apiRoot

    remoteServer: -> @class._remoteServer || config.remoteServer

    location: ->
      if @remoteServer && config.location != "server"
        "client"
      else
        config.location

    restPath: -> @_restPath ||= "/#{config.apiRoot}/#{@name}"
    restPathRegex: -> @_restPathRegex ||= ///
      ^
      #{escapeRegExp @restPath}
      (?:-([a-z0-9_]+))?          # optional request-type (if missing, it is derived from the HTTP method)
      (?:\/([^?]+))?       # optional key
      (?=\?|$)
      ///i

    groupedFilters: ->
      @_groupedFilters ||= Pipeline.groupFilters @filters

    beforeFilters: -> @_beforeFilters ||= @groupedFilters.slice().reverse()
    afterFilters: -> @groupedFilters
    status: -> "OK"

    filterChain: -> @_filterChain ||= compactFlatten([@, @groupedFilters]).reverse()

  # use a stable sort
  @groupFilters: (filters) ->
    priorityLevels = []
    for {priority} in filters
      pushIfNotPresent priorityLevels, priority

    sortedFilters = []
    for priorityLevels in (priorityLevels.sort (a, b) -> a - b)
      for filter in filters when priorityLevels == filter.priority
        sortedFilters.push filter

    sortedFilters

  getBeforeFilters: (request) -> filter for filter in @beforeFilters when filter.getBeforeFilter request
  getAfterFilters:  (request) -> filter for filter in @afterFilters  when filter.getAfterFilter request

  createRequest: (type, options) ->
    log.warn "DEPRICATED - options must be an object now" unless isPlainObject options
    options = key: options if isString options

    if getDetailedRequestTracingEnabled()
      stack = (new Error).stack

    Promise
    .then => options.session || @session.loadedDataPromise
    .tapCatch (error) =>
      log.error Pipeline_createRequest:
        message: "Error getting session"
        info: {@pipelineName, type, options}
        error: error
    .then (sessionData) =>
      new Request merge options,
        type:     type
        pipeline: @
        session:  sessionData
        creationStack: stack
    .catch (error) =>
      if stack?
        error.stack = cleanStackTrace stack
      error.message += "\n\ninside #{@name}." + formattedInspect createRequest: {type, options}
      throw error

  ###############################
  # Development Reports
  ###############################
  getRequestProcessingReport: (location = @location) ->
    object @requestTypes, (requestType) =>
      compactFlatten([
        inspectedObjectLiteral(filter.getName()) for filter in @getBeforeFilters {requestType, location}
        inspectedObjectLiteral if location == "client" then "[remote request]" else "[local handler]"
        inspectedObjectLiteral(filter.getName()) for filter in @getAfterFilters {requestType, location}
      ]) #.join ' > '

  @getter
    pipelineReport: (processingLocation)->
      out =
        tableName: @tableName
        fields: object @fields, (fieldProps) ->
          each Object.keys(fieldProps).sort(), out = {}, (k) ->
            v = fieldProps[k]
            unless isFunction v
              out[k] = v

      if processingLocation
        out["#{processingLocation}Processing"] = @getRequestProcessingReport "client"
      else
        out.clientSideRequestProcessing = @getRequestProcessingReport "client"
        out.serverSideRequestProcessing = @getRequestProcessingReport "server"
        out.serverlessDevelopmentRequestProcessing = @getRequestProcessingReport "both"

      out

    apiReport: (options = {}) ->
      {server, publicOnly} = options
      object @requestTypes,
        when: publicOnly && (type) => @getPublicRequestTypes()[type]
        with: (type) =>
          {method, url} = Request.getRestClientParamsForArtEryRequest
            server: @remoteServer || server
            type: type
            restPath: @restPath
          "#{method.toLocaleUpperCase()}": url


  ###################
  # RequestHandler API
  ###################
  # SEE RequestHandler
  handleRequest: (request) ->
    if request.isResponse
      throw new Error "HARD DEPRICATED"

    if @location == "client" && @remoteServer
      request.sendRemoteRequest @remoteServer

    else if handler = @handlers[request.type]
      @applyHandler request, handler, "handler"
      .then (response) =>
        unless response.isResponse
          request.failure "#{@pipelineName}.#{request.type} request was not handled"
        else
          response
    else
      request.failure "#{@pipelineName}: No handler for request type: #{formattedInspect request.type}"

  ###################
  # propsToKey (primarilly used by ArtEryFluxModel)
  ###################

  @getter
    propsToKey: -> @_propsToKey ?= do =>
      recordType = @pipelineName
      (props, stateField) ->
        propsField = stateField ? recordType
        props[propsField]?.id ? props[propsField + "Id"]

  ###################
  # PRIVATE
  ###################

  preprocessFilter = (filter) ->
    if isPlainArray filter
      instantiateFilter f for f in filter when f
    else
      instantiateFilter filter

  ###
  query handler-functions: (request) -> response or any other value allowed for handlers
  ###
  @_defineQueryHandlers: ->
    handlers = @getHandlers()
    for k, pipelineQuery of @getQueries() when !handlers[k]
      handlers = @extendHandlers k, pipelineQuery.options.query

  @_normalizeQuery: (queryName, options) ->
    options = query: options if isFunction options
    unless isFunction(options.query) && options.query.length > 0
      throw new Error """
        query function must have at least one argument:

        #{formattedInspect {queryName, options}}"
      """
    {queryName, options}

  _normalizeRequest: (request) ->
    if isPlainObject request
      new Request merge request, pipeline: @
    else
      request

  _processRequest: (request) ->
    haveHandler = !!@handlers[request.type]
    isPublicRequestType = !!@getPublicRequestTypes()[request.type]

    unless haveHandler || isPublicRequestType
      Promise.then => request.clientFailure data:
        message: "'#{request.type}' is an invalid request type"
        validRequestTypes: Object.keys @handlers
    else
      request.requireServerOriginOr isPublicRequestType, "to issue non-public requests"
      .then => @filterChain[0].handleRequest request, @filterChain, 0
      .then (response) ->
        unless response.isResponse
          log.error "not response!":response

        response

  ###
  IN:
    LEGAL SIGNATURES:
      type, options?
      type, key?, options?
      type, parentRequest?, options?
      type, parentRequest?, key?, options?

    type:           request type string
    parentRequest:  if present, this becomes a subreqest
    key:            merged with options: merge {key}, options
    options:
      Passed directly to:
        Request constructor
        AND response.toPromise

  OUT: SEE: response.toPromise
  ###
  noOptions = {}
  _processClientRequest: (type, a, b, c) ->
    if !a?
      a = b
      b = c

    if a? && a instanceof RequestResponseBase
      parentRequest = a
      a = b
      b = c

    options = if isString a
      merge
        key: a
        b
    else
      a ? noOptions

    if parentRequest
      parentRequest.subrequest @, type,
        if options != noOptions then options
        else props: parentRequest.props

    else
      requestStartTime = currentSecond()

      @createRequest type, options
      .then (request)  => @_processRequest request
      .then (response) => @_processResponseSession response, requestStartTime
      .then (response) => response.toPromise options

  ###
  mostRecentSessionUpdatedAt ensures we don't update the session out of order
  RULE: the current session reflects the response from the most recently INITIATED request.
  In other words, if a request stalls, takes a long time to update, and comes back with
  a session update AFTER some other session updates from more recently-initiated requests,
  that session-update is ignored.
  keywords: update session

  ALTERNATIVES CONSIDERED
  - could use a server-side timestamp to ensure no out-of-order session updates
    SUBOPTION A: order by time server RECEIVED the request
    SUBOPTION B: order by time server COMPLETED the request
    I decided this made less sense. It's really the order the user initiated
    events that matters. If a user initiates a log-in or log-out request AFTER
    some other slow request, the log-in/log-out should take precidence.
    Extreme example: user logs in, which takes forever, then initiates a log-out,
      if the log-in returns AFTER the log-out, it should be ignored.
  ###
  mostRecentSessionUpdatedAt = 0
  _processResponseSession: (response, requestStartTime) ->
    {responseSession} = response
    if responseSession
      currentSession = @session.data
      message =
      if requestStartTime > mostRecentSessionUpdatedAt
        mostRecentSessionUpdatedAt = requestStartTime
        @session.data = responseSession
        "updated"
      else
        "out-of-order update blocked"

      # log "ArtEry.Pipeline._processResponseSession": {
      #   message
      #   pipeline: response.pipelineName
      #   type:     response.type
      #   key:      response.key
      #   currentSession
      #   responseSession
      #   changed: !plainObjectsDeepEq currentSession, responseSession
      # }

    response

  @_defineClientRequestMethod: (requestType) ->
    @extendClientApiMethodList requestType unless requestType in @getClientApiMethodList()
    @::[requestType] ||= (a, b, c) -> @_processClientRequest requestType, a, b, c

  @_defineClientHandlerMethods: ->
    for name, handler of @getHandlers()
      @_defineClientRequestMethod name
    for name, __ of @getPublicRequestTypes()
      @_defineClientRequestMethod name
    null

  @_initFields: ->
    @extendFields filter.fields for filter in @getFilters()
