{
  log, decapitalize, merge, isString
  compactFlatten
  Promise
  formattedInspect
  isPlainObject
  ErrorWithInfo
  defineModule
} = require "art-standard-lib"
{BaseObject} = require 'art-class-system'
{InstanceFunctionBindingMixin} = require "@art-suite/instance-function-binding-mixin"

{missing, success, pending, failure, validStatus, isFailure} = require 'art-communication-status'
{artModelStore} = require "./ArtModelStore"
ArtModelRegistry = require './ArtModelRegistry'

defineModule module, class ArtModel extends InstanceFunctionBindingMixin BaseObject
  @abstractClass()

  @declarable
    staleDataReloadSeconds:         null      # if >0, reload stale data as soon as its older than this number in seconds
    minNetworkFailureReloadSeconds: null      # if >0, and isFailure(modelRecord.status) is true, that record well get a model.reload(key) call within this number of seconds after the failure
    maxNetworkFailureReloadSeconds: Infinity  # repeated failed reloads retry with exponential fall offs; this caps the max interval for retrying
    minServerFailureReloadSeconds:  null      # if >0, and isFailure(modelRecord.status) is true, that record well get a model.reload(key) call within this number of seconds after the failure
    maxServerFailureReloadSeconds:  Infinity  # repeated failed reloads retry with exponential fall offs; this caps the max interval for retrying

  @getter
    autoReloadEnabled: ->
      @getStaleDataReloadSeconds() > 0 ||
      @getMinNetworkFailureReloadSeconds() > 0 ||
      @getMinServerFailureReloadSeconds() > 0

  # must call register to make model accessable to RestComponents
  # NOTE: @fields calls register for you, so if you use @fields, you don't need to call @register
  @register: ->
    @singletonClass()
    ArtModelRegistry.register @getSingleton()

  @postCreateConcreteClass: ({hotReloaded}) ->
    if hotReloaded
      @singleton.bindFunctionsToInstance()
    else
      @register()
    super

  ###
    INPUT: zero or more strings or arrays of strings
      - arbitrary nesting of arrays is OK
      - nulls are OK, they are ignored
    OUTPUT: null

    NOTE: @aliases can be called multiple times.

    example:
      class Post extends ArtModel
        @aliases "chapterPost"

    purpose:
      - declare alternative names to access this model.
      - allows you to use the shortest form of Components subscriptions for each alias:
          @subscriptions "chapterPost"
        in addition to the model's class name:
          @subscriptions "post"
  ###
  @aliases: (args...) ->
    @_aliases = compactFlatten [args, @_aliases]
    null

  @_aliases: []

  onNextReady: (f) -> artModelStore.onNextReady f

  constructor: (name)->
    super
    @_name = name || decapitalize @class.getName()
    @bindFunctionsToInstance()
    @_activeLoadingRequests = {}

  register: ->
    log.warn "DEPRICATED: ArtModel#register is no longer used. Instead, the class is registered automatically post-create."

  @classGetter
    models: -> ArtModelRegistry.models
    artModelStore: -> artModelStore

  @getter
    models: -> ArtModelRegistry.models
    artModelStore: -> artModelStore
    singlesModel: -> @_singlesModel || @
    modelStoreEntries: -> artModelStore.getEntriesForModel @name

  # DEPRICATED
  subscribe: (modelKey, subscriptionFunction) ->
    log.error "DEPRICATED - use ArtModelSubscriptionsMixin and it's subscribe"
    artModelStore.subscribe @_name, modelKey, subscriptionFunction

  @getter "name",
    modelName: -> @_name

  ### load:
    load the requested data for the given key and update the artModelStore

    required:
      Should ALWAYS call artModelStore.update immediately OR once the data is available.
      Clients will assume that a call to "load" forces a reload of the data in the artModelStore.

    optional:
      If the data is immediately available, you can return the modelRecord instead of "null"
      If load was called because of a new Component being mounted and its subscriptions initialized,
        returning the modelRecord immediately will guarantee the Component has valid data for its
        first render.

    Note:
      Typically called automatically by the artModelStore when a Component subscribes to
      data from this model with the given key.

    The simplest possible load function:
      load: (key) -> @updateModelRecord key, {}

    The "load" function below is:
      Simplest "load" with immediate modelRecord return.
      Immediate return means:
      - artModelStore.subscribe() will return the modelRecord returned from this "load"
      - Components subscriptions will update state in time for the inital render.

    inputs:
      key: string

    side effects:
      expected to call artModelStore.update @_name, key, modelRecord
        - when modelRecord.status is no longer pending
        - optionally as progress is made loading the modelRecord.data

    returns: null OR modelRecord if the value is immediately available
      NOTE: load can return null or modelRecord as it chooses. The client shouldn't
        rely on the fact that it returned a modelRecord with a set of inputs, it might not
        the next time.

    Optionally, you can implement one of two altenative load functions with Promise support:

      loadData:       (key) ->
                        promise.then (data) ->
                          if data is null or undefined, status will be set to missing
                          otherwise, status will be success
                        promise.catch (a validStatus or error info, status becomes failure) ->
      loadModelRecord: (key) -> promise.then (modelRecord) ->

      @load will take care of updating ArtModelStore.
  ###
  load: (key) ->
    # ensure artModelStore is updated in case this is not beind called from the artModelStore itself
    # returns {status: missing} since updateModelRecord returns the last argument,
    #   this makes the results immediately available to subscribers.

    if @loadData || @loadModelRecord
      @loadPromise key
      null
    else
      @updateModelRecord key, status: missing

  ### loadPromise:
    NOTE: @loadData or @loadModelRecord should be implemented.
    @loadPromise is an alternative to @load

    Unlike @load, @loadPromise returns a promise that resolves when the load is done.

    The down-side is @loadPromise cannot immediately update the ArtModelStore. If you have
    a model which stores its data locally, like ApplicationState, then override @load
    for immediate artModelStore updates.

    However, if your model always has to get the data asynchronously, override @loadData
    or @loadModelRecord and use @loadPromise anytime you need to manually trigger a load.

    EFFECTS:
    - Triggers loadData or loadModelRecord.
    - Puts the results in the artModelStore.
    - Elegently reduces multiple in-flight requests with the same key to one Promise.
      @loadData or @loadModelRecord will only be invoked once per key while their
      returned promises are unresolved.
      NOTE: the block actually extends all the way through to the artModelStore being updated.
      That means you can immediately call @getModelRecord and get the latest data - when
      the promise resolves.

    OUT: promise.then (modelRecord) ->
      modelRecord: the latest, just-loaded data
      ERRORS: errors are encoded into the modelRecord. The promise should always resolve.
  ###
  loadPromise: (key) ->
    if p = @_activeLoadingRequests[key]
      # log "saved 1 reload due to activeLoadingRequests! (model: #{@name}, key: #{key})"
      return p

    p = if @loadData
      Promise.then    => @loadingRecord key
      .then           => @loadData key
      .then (data)    => @updateModelRecord key, if data? then {data, status: success} else status: missing
      .catch (error)  =>
        status = if validStatus status = error?.info?.status || error
          status
        else failure
        info = error?.info
        error = null unless error instanceof Error
        @updateModelRecord key, {status, info, error}

    else if @loadModelRecord
      @loadModelRecord key
      .then (modelRecord) => @updateModelRecord key, modelRecord
      .catch (error)     => @updateModelRecord key, status: failure, error: error
    else
      Promise.resolve @updateModelRecord key, status: missing

    @_activeLoadingRequests[key] = p
    .then (result) => @onNextReady(); result
    .then (result) => @_activeLoadingRequests[key] = null; result

  # load is not required to updateModelRecord
  # reload guarantees artModelStore is updated
  # override reload if your load does not always updateModelRecord (eventually)
  reload: (key) ->
    if @loadData || @loadModelRecord
          @loadPromise key
    else  @load key

  # called before actually calling @loadData within @loadPromise
  # EFFECT: marks record status as pending if it was previously a failure
  #   If it was previously a success, subscribers should keep showing the previously
  #   successful load until the new one completes.
  loadingRecord: (key) ->
    if isFailure (modelRecord = @getModelRecord key)?.status
      @updateModelRecord key, merge modelRecord, status: pending

  getModelRecord:     (key) -> artModelStore.get @_name, @toKeyString key
  updateModelRecord:  (key, modelRecord) -> artModelStore.update @_name, key, modelRecord

  onModelRegistered: (modelName) -> ArtModelRegistry.onModelRegistered modelName

  # IN: key
  # OUT: promise.then data
  # EFFECT: if already loaded in artModelStore, just returns what's in ArtModelStore
  get: (key) ->
    key = @toKeyString key
    Promise.then =>
      if (currentModelRecord = @getModelRecord(key))?.status == pending
        currentModelRecord = null

      currentModelRecord ? @loadPromise key

    .then (modelRecord)->
      {status, data} = modelRecord
      unless status == success
        throw new ErrorWithInfo "ArtModel#get: Error getting data. Status: #{status}.", {status, modelRecord}

      data

  ###################################################
  # OVERRIDES - Non-String Keys
  ###################################################
  # Override to support non-string keys
  # return: string representation of key
  toKeyString: (key) ->
    if isPlainObject key then @dataToKeyString key
    else if isString key then key
    else
      throw new Error "ArtModel #{@name}: Must implement
        custom toKeyString for
        non-string keys like: #{formattedInspect key}"

  dataToKeyString: (obj) ->
    throw new Error "ArtModel #{@name}: must override dataToKeyString for converting objects to key-strings."

  @getRecordPropsToKeyFunction: (recordType) ->
    (props, stateField) =>
      propsField = stateField ? recordType
      props[propsField]?.id ? props[propsField + "Id"]

  @getter
    propsToKey: -> @_propsToKey ?= ArtModel.getRecordPropsToKeyFunction @modelName

  ###################################################
  # OVERRIDES - Events
  ###################################################
  # Override to respond to entries being added or removed from the ArtModelStore

  # called when an entry is updated OR added OR if it is about to be removed
  # this is called before modelStoreEntryAdded or modelStoreEntryRemoved
  modelStoreEntryUpdated: (entry) ->

  # called only when an entry is added
  modelStoreEntryAdded: (entry) ->

  # called when an entry was moved (when subscriber count goes to 0)
  modelStoreEntryRemoved: (entry) ->

  # called after the model has been registered
  modelRegistered: ->
