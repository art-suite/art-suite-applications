{
  lowerCamelCase
  pluralize
  each
  log
  array
  select
  isString
  isFunction
  fastBind
  decapitalize
  merge
  Promise
  eq
  upperCamelCase
  arrayWith
  arrayWithElementReplaced
  formattedInspect
  defineModule
  inspect
  compactFlatten
  object
  isPlainObject
} = require 'art-standard-lib'
{createWithPostCreate} = require 'art-class-system'
{missing, success, pending} = require "art-communication-status"
{KeyFieldsMixinCoffee, PipelineRegistry, pipelines} = require 'art-ery'

{ArtModel, models} = require '@art-suite/art-models'

{prefetchedRecordsCache} = require '../PrefetchedRecordsCache'

ArtEryQueryFluxModel = require './ArtEryQueryFluxModel'

defineModule module, class ArtEryFluxModel extends KeyFieldsMixinCoffee ArtModel
  @abstractClass()

  ###
  ALIASES
    both pipelines and models will have the same set of aliases
    This skips the aliases in pipelines and calls createModel only once
    which will in turn create all the model aliases.
    It's important that all the model aliases are the same model-instance object.

  OUT: singleton for new AnonymousArtEryArtModel class
  ###
  @createModel: (pipeline) ->
    {aliases} = pipeline
    name = pipeline.getName()
    return if models[name]
    # log "create ArtModel for pipeline: #{name}"
    hotReloadKey = "ArtEryArtModel:#{name}"
    createWithPostCreate class AnonymousArtEryArtModel extends @applyMixins pipeline, ArtEryFluxModel
      @_name: ucName = upperCamelCase name
      @keyFields pipeline.keyFields if pipeline.keyFields
      @pipeline pipeline
      @aliases aliases if aliases
      @getHotReloadKey: -> hotReloadKey

  @applyMixins: (pipeline, BaseClass) ->

    # apply mixins
    for customMixin in compactFlatten pipeline.getArtModelMixins()
      BaseClass = customMixin BaseClass

    BaseClass

  @defineModelsForAllPipelines: =>
    for name, pipeline of pipelines when name == pipeline.getName()
      @createModel pipeline

  @bindWithArtEry: =>
    PipelineRegistry.on
      register: ({name, pipeline}) =>
        @createModel pipeline

    @defineModelsForAllPipelines()


  @pipeline: (@_pipeline) -> @_pipeline
  @getter
    pipelineName: -> @_pipeline.getName()
    "pipeline"
    propsToKey: -> @_pipeline.propsToKey

  ########################
  # Constructor
  ########################
  constructor: ->
    super
    @_updateSerializers = {}
    @_pipeline = @class._pipeline
    @_defineQueryModels()
    @_bindPipelineMethods()

  ########################
  # Queries
  ########################
  _defineQueryModels: ->
    @_queryModels = array @_pipeline.queries, (pipelineQuery) => @_createQueryModel pipelineQuery

  ### _createQueryModel
    IN: {options, queryName}
    queryName can either be
      pre2020-style:
        format: pluralized pipeline name - by - fields
        e.g. postsByUserId

      2020-style-naming:
        format: by - fields
        e.g. byUserId

      Either way, the ArtModel will be named:
        format: pluralized pipeline name - by - fields
        e.g. postsByUserId

    Benefits of 2020-style query names:
      By dropping the pipeline-name as part of the queryName, we get several advantages:

        DRY:
          Pipeline definitions:
            2020 version:
              class Message extends Pipeline
                @query byUserId: (request) -> ...
                @publicRequestTypes :byUserId

            instead of pre2020:
              class Message extends Pipeline
                @query messagesByUserId: (request) -> ...
                @publicRequestTypes :messagesByUserId

          The REST api becomes:
            2020 version:       /post/byUserId/abc123
            instead of pre2020: /post/postsByUserId/abc123

        And all the DRY means an objective improvement:

          It is now possible to re-use pipeline query definitions across pipelines:

            class UserOwned extends Pipeline
              @query byUserId: (request) -> ...
              @publicRequestTypes :byUserId

            class Message extends UserOwned
            class Post extends UserOwned

          NOTE: I actually haven't tested that the inheritance part works yet...
  ###
  _createQueryModel: ({options, queryName}) ->
    {localMerge, localSort, dataToKeyString, keyFields} = options

    recordsModel = @
    pipeline = @_pipeline

    (createWithPostCreate class ArtEryQueryFluxModelChild extends @class.applyMixins @_pipeline, ArtEryQueryFluxModel
      @_name: upperCamelCase(
        if /^by/.test queryName
          "#{pluralize pipeline.name} #{queryName}"
        else
          queryName
      )

      _pipeline:      pipeline
      _recordsModel:  recordsModel
      _queryName:     queryName

      @keyFields keyFields if keyFields

      # Overrides
      @::[k] = v for k, v of merge {localMerge, localSort, dataToKeyString}
    ).singleton

  ########################
  # ArtModel Overrides
  ########################
  loadData: (key) ->
    (prefetchedRecordsCache.get @pipelineName, key) ?                       # LinkFieldsFilterV2
    @_pipeline.get {key, returnNullIfMissing: true, props: include: "auto"} # include: :auto is for LinkFieldsFilterV1

  ################################################
  # DataUpdatesFilter callbacks
  ################################################
  ###
  TODO: What if the field that changes effects @dataToKeyString???
    Basically, then TWO query results for one query-model need updated - the old version gets a "delete"
    The new version gets the normal update.

    We -could- do a ArtModelStore.get and see if we have a local copy of the single record before we
    replace it. However, we often won't. However again, we may not NEED this often.

    Basically, the question becomes how do we get the old data - if we need it and it actually matters.

    The ArtEry Pipeline knows its queries - and in theory could know the fields which effect queries.
    DataUpdatesFilter could detect all this before: update. If it detects it, it could GET the old
    record, and then set responseProps.oldData: oldData. Then, DataUpdatesFilter could pass
    oldData into dataUpdated. DONE.

    OK - I added the oldData input, and I attempt to get it from the ArtModelStore if it isn't set.
    I think the code is right for handling the case where we need to update to queries.

    TODO: We need to do the Server-Side "fetch the old data if queries-keys will change" outline above.
    TODO: DataUpdatesFilter needs change the protocol to return oldData, too, if needed - there may be more than one oldData per request.
    TODO: DataUpdatesFilter needs to pass in: response.props.oldData[key]
  ###
  dataUpdated: (key, data) ->
    oldData = @getModelRecord(key)?.data
    mergedData = merge oldData, data

    @updateModelRecord key, (oldModelRecord) -> merge oldModelRecord, data: merge oldModelRecord.data, data

    each @_queryModels, (queryModel) =>
      oldQueryKey = oldData && queryModel.dataToKeyString oldData
      queryKey    = queryModel.dataToKeyString mergedData

      queryModel.dataDeleted oldQueryKey, oldData if oldQueryKey && oldQueryKey != queryKey
      queryModel.dataUpdated queryKey, mergedData if queryKey

  dataDeleted: (key, dataOrKey) ->
    @updateModelRecord key, status: missing

    dataOrKey && each @_queryModels, (queryModel) =>
      queryKey = queryModel.toKeyString dataOrKey
      queryKey && queryModel.dataDeleted queryKey, dataOrKey

  ##########################
  # PRIVATE
  ##########################

  ###
  Bind all concrete methods defined on @_pipeline
  and set them on the model prototype
  as long as there isn't already a model-prototype method with that name.

  Specifically: create & update are already defined above
    since they need to do extra work to ensure the ArtModelStore is
    updated properly.
  ###
  _bindPipelineMethods: ->
    abstractPrototype = @_pipeline.class.getAbstractPrototype()
    for k, v of @_pipeline when !@[k] && !abstractPrototype[k] && isFunction v
      @[k] = fastBind v, @_pipeline
