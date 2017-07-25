Foundation = require "art-foundation"
{missing, success, pending, failure, validStatus, defineModule} = Foundation.CommunicationStatus
{fluxStore} = require "./FluxStore"
ModelRegistry = require './ModelRegistry'

{
  log, BaseObject, decapitalize, pluralize, pureMerge, shallowClone, isString,
  emailRegexp, urlRegexp, isNumber, nextTick, capitalize, inspect, isFunction, pureMerge
  isoDateRegexp
  time
  globalCount
  compactFlatten
  InstanceFunctionBindingMixin
  Promise
  formattedInspect
  isPlainObject
  ErrorWithInfo
, defineModule} = Foundation

defineModule module, class FluxModel extends InstanceFunctionBindingMixin BaseObject
  @abstractClass()

  # must call register to make model accessable to RestComponents
  # NOTE: @fields calls register for you, so if you use @fields, you don't need to call @register
  @register: ->
    @singletonClass()
    ModelRegistry.register @getSingleton()

  register: ->
    ModelRegistry.register @

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
    class Post extends FluxModel
      @aliases "chapterPost"

  purpose:
    - declare alternative names to access this model.
    - allows you to use the shortest form of FluxComponent subscriptions for each alias:
        @subscriptions "chapterPost"
      in addition to the model's class name:
        @subscriptions "post"
  ###
  @aliases: ->
    @_aliases = compactFlatten [arguments, @_aliases]
    null

  @_aliases: []

  onNextReady: (f) -> fluxStore.onNextReady f

  constructor: (name)->
    super
    @_name = name || decapitalize @class.getName()
    @bindFunctionsToInstance()
    @_activeLoadingRequests = {}

  @classGetter
    models: -> ModelRegistry.models
    fluxStore: -> fluxStore

  @getter
    models: -> ModelRegistry.models
    fluxStore: -> fluxStore
    singlesModel: -> @_singlesModel || @
    fluxStoreEntries: -> fluxStore.getEntriesForModel @name

  # DEPRICATED
  subscribe: (fluxKey, subscriptionFunction) ->
    log.error "DEPRICATED - use FluxSubscriptionsMixin and it's subscribe"
    fluxStore.subscribe @_name, fluxKey, subscriptionFunction

  @getter "name",
    modelName: -> @_name

  ###
  load the requested data for the given key and update the fluxStore

  required:
    Should ALWAYS call fluxStore.update immediately OR once the data is available.
    Clients will assume that a call to "load" forces a reload of the data in the fluxStore.

  optional:
    If the data is immediately available, you can return the fluxRecord instead of "null"
    If load was called because of a new Component being mounted and its subscriptions initialized,
      returning the fluxRecord immediately will guarantee the Component has valid data for its
      first render.

  Note:
    Typically called automatically by the fluxStore when a Component subscribes to
    data from this model with the given key.

  The simplest possible load function:
    load: (key) -> @updateFluxStore key, {}

  The "load" function below is:
    Simplest "load" with immediate fluxRecord return.
    Immediate return means:
     - fluxStore.subscribe() will return the fluxRecord returned from this "load"
     - FluxComponent subscriptions will update state in time for the inital render.

  inputs:
    key: string

  side effects:
    expected to call fluxStore.update @_name, key, fluxRecord
      - when fluxRecord.status is no longer pending
      - optionally as progress is made loading the fluxRecord.data

  returns: null OR fluxRecord if the value is immediately available
    NOTE: load can return null or fluxRecord as it chooses. The client shouldn't
      rely on the fact that it returned a fluxRecord with a set of inputs, it might not
      the next time.

  Optionally, you can implement one of two altenative load functions with Promise support:

    loadData:       (key) ->
                      promise.then (data) ->
                        if data is null or undefined, status will be set to missing
                        otherwise, status will be success
                      promise.catch (a validStatus or error info, status becomes failure) ->
    loadFluxRecord: (key) -> promise.then (fluxRecord) ->

    @load will take care of updating FluxStore.

  ###
  load: (key) ->
    # ensure fluxStore is updated in case this is not beind called from the fluxStore itself
    # returns {status: missing} since updateFluxStore returns the last argument,
    #   this makes the results immediately available to subscribers.

    if @loadData || @loadFluxRecord
      @loadPromise key
      null
    else
      @updateFluxStore key, status: missing

  ###
  NOTE: @loadData or @loadFluxRecord should be implemented.
  @loadPromise is an alternative to @load

  Unlike @load, @loadPromise returns a promise that resolves when the load is done.

  The down-side is @loadPromise cannot immediately update the flux-store. If you have
  a model which stores its data locally, like ApplicationState, then override @load
  for immediate fluxStore updates.

  However, if your model always has to get the data asynchronously, override @loadData
  or @loadFluxRecord and use @loadPromise anytime you need to manually trigger a load.

  EFFECTS:
  - Triggers loadData or loadFluxRecord.
  - Puts the results in the fluxStore.
  - Elegently reduces multiple in-flight requests with the same key to one Promise.
    @loadData or @loadFluxRecord will only be invoked once per key while their
    returned promises are unresolved.
    NOTE: the block actually extends all the way through to the fluxStore being updated.
    That means you can immediately call @fluxStoreGet and get the latest data - when
    the promise resolves.

  OUT: promise.then (fluxRecord) ->
    fluxRecord: the latest, just-loaded data
    ERRORS: errors are encoded into the fluxRecord. The promise should always resolve.
  ###
  loadPromise: (key) ->
    if p = @_activeLoadingRequests[key]
      log "saved 1 reload due to activeLoadingRequests! (model: #{@name}, key: #{key})"
      return p

    p = if @loadData
      Promise.then    => @loadData key
      .then (data)    => @updateFluxStore key, if data? then status: success, data: data else status: missing
      .catch (error)  =>
        status = if validStatus status = error?.info?.status || error
          status
        else failure
        info = error?.info
        error = null unless error instanceof Error
        @updateFluxStore key, {status, info, error}

    else if @loadFluxRecord
      @loadFluxRecord key
      .then (fluxRecord) => @updateFluxStore key, fluxRecord
      .catch (error)     => @updateFluxStore key, status: failure, error: error
    else
      Promise.resolve @updateFluxStore key, status: missing

    @_activeLoadingRequests[key] = p
    .then (result) => @onNextReady(); result
    .then (result) => @_activeLoadingRequests[key] = null; result

  # load is not required to updateFluxStore
  # reload guarantees fluxStore is updated
  # override reload if your load does not always updateFluxStore (eventually)
  reload: (key) ->
    @load key

  # shortcut for updating the fluxStore for the current model
  updateFluxStore: (key, fluxRecord) -> fluxStore.update @_name, key, fluxRecord

  onModelRegistered: (modelName) -> ModelRegistry.onModelRegistered modelName

  fluxStoreGet: (key) ->
    key = @toKeyString key
    fluxStore.get @_name, key

  # IN: key
  # OUT: promise.then data
  # EFFECT: if already loaded in fluxStore, just returns what's in fluxstore
  get: (key) ->
    key = @toKeyString key
    Promise.then =>
      if currentFluxRecord = @fluxStoreGet(key)
        if currentFluxRecord.status == pending
          currentFluxRecord = null
      currentFluxRecord || @loadPromise key
    .then (fluxRecord)->
      {status, data} = fluxRecord
      unless status == success
        new ErrorWithInfo "FluxModel#get: Error getting data. Status: #{status}.", {status, fluxRecord}
      data

  # Override to support non-string keys
  # return: string representation of key
  toKeyString: (key) ->
    if isPlainObject key
      @dataToKeyString key
    else if isString key
      key
    else
      throw new Error "FluxModel #{@name}: Must implement
        custom toKeyString for
        non-string keys like: #{formattedInspect key}"

  dataToKeyString: (obj) ->
    throw new Error "FluxModel #{@name}: must override dataToKeyString for converting objects to key-strings."


  # Override to respond to entries being added or removed from the flux-store

  # called when an entry is updated OR added OR if it is about to be removed
  # this is called before fluxStoreEntryAdded or fluxStoreEntryRemoved
  fluxStoreEntryUpdated: (entry) ->

  # called only when an entry is added
  fluxStoreEntryAdded: (entry) ->

  # called when an entry was moved (when subscriber count goes to 0)
  fluxStoreEntryRemoved: (entry) ->

  ###
  localStorage helper methods
  ###

  _localStoreKey: (id) ->
    "fluxModel:#{@_name}:#{id}"

  _localStoreGet: (id) ->
    if data = localStorage.getItem @_localStoreKey id
      JSON.parse data
      # Scanning and parsing through to find dates is too slow (adds about 1ms of processing per frame)
      # Most the time we don't even care, so I put it up to the consumer to check if dates are dates or strings.
      # JSON.parse data, (key, value) ->
      #   if isString(value) && value.match isoDateRegexp
      #     new Date value
      #   else
      #     value
    else
      null

  # TODO: We need a way to expire old items
  _localStoreSet: (id, data) ->
    # log "_localStoreSet: #{@_localStoreKey id}", data
    localStorage.setItem @_localStoreKey(id), JSON.stringify data
