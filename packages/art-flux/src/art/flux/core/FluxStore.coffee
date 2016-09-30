Foundation = require 'art-foundation'
Entry = require './entry'
ModelRegistry = require './ModelRegistry'

{
  BaseObject, merge, removeFirstMatch
  pushIfNotPresent, removeFirstMatch, Epoch, log, isFunction, Unique, clone
  consistentJsonStringify
  isString
  timeout
  globalCount
  time
  inspect
, defineModule, CommunicationStatus} = Foundation

{success, pending, missing, failure} = CommunicationStatus

# FluxStore:
#   a key-fields store
#   'fields' are plain Objects with any fields with any values you want except:
#     the 'key' field is set automatically to match the Object's key in the store
#   Updates to values result in NEW Objects. A Value object is never altered.
#   Epoched
#   Supports change-notificaiton subscriptions per key.
defineModule module, class FluxStore extends Epoch
  @singletonClass()

  constructor: ->
    super
    @_reset()

  @getter "length"

  get:               (modelName, key) -> @_getEntry(modelName, key)?.fluxRecord
  getSubscribers:    (modelName, key) -> @_getEntry(modelName, key)?.subscribers
  getHasSubscribers: (modelName, key) -> !!@_getEntry(modelName, key)?.getHasSubscribers()

  ###
  subscribe to all changes to the fluxStore Entry identified by modelName and Key.

  subscribers:
    are notified on all changes to the entry's:
      @fluxRecord object
      @subscribers list
    are NOT explicitly notified of when the entry is first added or removed
      However, when an entry is added, subscribers will be notified that a change happened.
      When an entry is removed, subscribers will be again notified, and the "subscribers" param will be [].
    See subscribeToStore for notifications about entries being added or removed

  inputs:
    modelName: string
    key: string

    subscriber: (fluxRecord, previousFluxRecord) -> null
      IN:
        fluxRecord: plain object; the current value for the fluxRecord
        previousFluxRecord: plain object; the last value for the fluxRecord
      GUARANTEES:
        1. !propsEq fluxRecord, previousFluxRecord
        2. only called once per change

    initialFluxRecord: if set, and the key is not in the store, this is used
      as the initial value instead of the calling "load" on the model.

  side effects:
    vivifies a new entry with fluxRecord = {status: pending} if one isn't present
    calls ModelRegistry[modelName].load key if vivification occured
    Notifies all subscribers.

  returns: current fluxRecord for the entry
  ###
  subscribe: (modelName, key, subscriber, initialFluxRecord) ->
    @_queueChange modelName: modelName, key: key, addSubscriber: subscriber
    @_vivifyAndLoadEntry(modelName, key, initialFluxRecord).fluxRecord

  ###
  inputs:
    modelName: string
    key: string
    subscriber: the exact same function (including closure) used to subscribe

  side effects:
    Notifies all subscribers.

  returns: null
  ###
  unsubscribe: (modelName, key, subscriber) ->
    @_queueChange modelName: modelName, key: key, removeSubscriber: subscriber

  ###
  put updates or creates the record
  updateFunctionOrNewFluxRecord: can be:
    1) an arbitrary function: (oldRecord) -> newRecord
      oldRecord will be null/undefined only if the record has not been created.
      do not alter oldRecord
      must return a new Object or null/undefined (in which case an empty Object is created)
    2) a new Object to replace the existing object

  Notifies all subscribers.
  returns: updateFunctionOrNewFluxRecord
  ###
  update: (modelName, key, updateFunctionOrNewFluxRecord) ->
    throw new Error "key must be a string. got: #{inspect key}" unless isString key
    @_queueChange
      modelName: modelName
      key: key
      updateFunction:
        if isFunction updateFunctionOrNewFluxRecord
          updateFunctionOrNewFluxRecord
        else
          (oldRecord) -> updateFunctionOrNewFluxRecord
    updateFunctionOrNewFluxRecord

  @getter
    status: ->
      entrySubscribers = 0
      modelCount = 0
      for model, entries of @_entriesByModelName
        modelCount++
        for key, entry of entries
          entrySubscribers += entry.subscriberCount

      entries: @_length
      entrySubscribers: entrySubscribers
      models: modelCount

  ########################
  # PRIVATE
  ########################

  # broken out for testing
  _reset: ->
    @_length = 0
    @_entriesByModelName = {}
    @_addedEntries = []

  _getEntriesForModelName: (modelName) ->
    @_entriesByModelName[modelName] ||= {}

  _getEntry: (modelName, key) ->
    throw new Error "Expected 'modelName' to be a String. Got: #{inspect modelName}" unless isString modelName
    throw new Error "Expected 'key' to be a String. Got: #{inspect key}" unless isString key
    @_getEntriesForModelName(modelName)[key]

  _addEntry: (modelName, key) ->
    @_length++
    entry = @_getEntriesForModelName(modelName)[key] = new Entry modelName, key
    pushIfNotPresent @_addedEntries, entry
    entry

  _removeEntry: (entry) ->
    @_length--
    delete @_getEntriesForModelName(entry.fluxRecord.modelName)[entry.fluxRecord.key]

  ###
  Returns existing entry if there is one, otherwise it vivifies a "defaultFluxRecord" and starts the model.load.

  _vivifyAndLoadEntry solves the problem of two or more subscriptions starting in the same epoch
  on a new entry. Without this, we'd try to call "load" on the same model+key more than once.
  Ex: if we are loading remote images, loading the same remote image multiple times is a huge waste.

  returns: entry
  ###
  _vivifyAndLoadEntry: (modelName, key, initialFluxRecord) ->
    entry = @_getEntry modelName, key
    unless entry
      entry = @_addEntry modelName, key
      if initialFluxRecord
        entry.setFluxRecord initialFluxRecord
      else
        @_loadKeyWithRetriesWithExponentalFalloff modelName, key, entry
    entry

  _loadKeyWithRetriesWithExponentalFalloff: (modelName, key, entry) ->
    retryDelay = 250 # ms
    if model = ModelRegistry.models[modelName]
      loadRetryCallback = (loadInfo) =>
        if loadInfo.status != pending && loadInfo.status != success && loadInfo.status != missing
          if @_getEntry modelName, key
            retryDelay *= 2 if retryDelay < 60 * 1000 # max is 1 minute
            console.warn "FluxStore retry is disabled"
            # log FluxStore_get_retry:
            #   delay: retryDelay
            #   model:modelName
            #   key:key
            #   status: loadInfo.status
            # timeout retryDelay, -> model.load key, loadRetryCallback
          else
            log FluxStore_get_retry:
              model:modelName
              key:key
              status: loadInfo.status
              aborting: "no longer have subscribers"

      try
        if fluxRecord = model.load key, loadRetryCallback
          entry.setFluxRecord fluxRecord
      catch e
        message = "Error loading record from model '#{modelName}' for key '#{key}'. Error: #{e}"
        console.error message, e.stack
        entry.setFluxRecord status: failure, errorObject: e, message: message
    else
      console.warn "ArtFlux: there is no model registered with the name: #{modelName}. Entry for #{modelName}:#{key} will forever be status: pending."


  # ensures the entry exists
  # returns: entry for model+key
  _vivifyEntry: (modelName, key) ->
    @_getEntry(modelName, key) || @_addEntry modelName, key

  # this ensures we don't return the "change" Object which should not be exposed to clients
  _queueChange: (change) ->
    {modelName, key} = change
    throw new Error "Expected 'modelName' to be a String. Got: #{inspect modelName}" unless isString modelName
    throw new Error "Expected 'key' to be a String. Got: #{inspect key}" unless isString key

    @queueItem change
    null

  processEpochItems: (changes) ->
    updatedEntries = []
    removedEntries = []

    for {modelName, key, removeEntry, addSubscriber, removeSubscriber, updateFunction} in changes

      entry = @_vivifyEntry modelName, key

      if updateFunction        then entry._updateFluxRecord updateFunction
      else if addSubscriber    then entry._subscribe addSubscriber
      else if removeSubscriber then entry._unsubscribe removeSubscriber

      pushIfNotPresent updatedEntries, entry

    {models} = ModelRegistry
    for entry in updatedEntries
      models[entry.getModelName()].fluxStoreEntryUpdated entry
      entry._notifySubscribers()
      if entry.subscribers.length == 0
        pushIfNotPresent removedEntries, entry
        @_removeEntry entry

    models[entry.getModelName()].fluxStoreEntryAdded entry for entry in @_addedEntries
    models[entry.getModelName()].fluxStoreEntryRemoved entry for entry in removedEntries

    @_addedEntries = []
    null

# bind to GlobalEpochCycle if not web-worker
if GlobalEpochCycle = Neptune.Art.Engine?.Core?.GlobalEpochCycle
  GlobalEpochCycle.singleton.includeFlux FluxStore.singleton
