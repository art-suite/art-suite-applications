# TODO: rename to ApplicationStateModel
{
  lowerCamelCase
  timeout
  object
  each, clone, BaseObject, log, isString, isPlainObject, merge, propsEq, mergeInto, Unique, defineModule
  Promise
  formattedInspect
  eq
  neq
  getEnv
  isFunction
} = require 'art-standard-lib'

{ArtModel} = require '@art-suite/art-models'

{pending, success, failure, missing} = require "art-communication-status"
StateFieldsMixin = require 'art-react/StateFieldsMixin'

{JsonStore} = require '@art-suite/art-foundation'
{jsonStore} = JsonStore

### ApplicationState
  A state-store with the same state API as React Components:
    setState: (map) -> or (key, value) -> # => null
    getInitialState: -> # => {}
    @state: {} # the current State

  NOTE: Components should never access @state. Instead, they should subscribe to state changes:
  Example:
    createComponentFactory class Top extends FluxComponent
      @subscriptions
        showingWelcome: model: "ozAppState"

    showWelcome: ->
      @model.ozAppState.showWelcome()

  Usage:
    Inherit, register and optionally override getInitalState.
    Note: Each time you inherit creates a new model and a different collection state
    NOTE: @register immeidately instantiates the OzAppState singleton - which will
      immediately call getInitialState.
      Therefor, call @register AFTER defining getInitialState.

  Example:
    class OzAppState extends ApplicationState

      getInitialState: ->
        showingWelcome: true

      @register()

      showWelcome: -> @setState "showingWelcome", true
      hideWelcome: -> @setState "showingWelcome", false

  NEW:
    You can how subscribe to the entire state of the model by subscribing to its own name:

    Example:
      # using the model above, you can subscribe to its entire state as follows:

      class MyComponent extends FluxComponent
        @subscriptions "ozAppState.ozAppState"

        render: ->
          TextElement text: "showingWelcome: #{@ozAppState.showingWelcome}"
###
defineModule module, class ApplicationState extends StateFieldsMixin ArtModel
  @abstractClass()
  @persistant: -> @_persistant = true

  @postCreateConcreteClass: ({hotReloaded, classModuleState}) ->
    ret = super

    if hotReloaded
      {liveClass, hotUpdatedFromClass} = classModuleState

      liveInstance = liveClass.getSingleton()
      newDefaultState = (new hotUpdatedFromClass).state
      currentState = liveInstance.state
      mergedState = merge newDefaultState, currentState
      stateDelta = object mergedState, when: (v, k) -> currentState[k] != v

      log "Flux.ApplicationState: model hot-reloaded": {model: liveInstance.name, stateDelta}
      timeout 0, => liveInstance.setState stateDelta

    ret

  constructor: ->
    super
    @state = @_getInitialState()

  modelRegistered: -> @_updateAllState @state

  ###
    provided for consistency with React Components
    To use: override
    But, using @stateFields works just as well and also declares field getter / setters.
  ###
  getInitialState: -> {}

  ### setState
    IN:
      option 1:
        IN: plainObject state-map
        AFFECT: set many states
        OUT: state-map

      option 2:
        IN: key, value
        AFFECT: set one state
        OUT: key
  ###
  setState: (key, value) ->
    stateChanged = false
    if isFunction key
      stateChanged = true
      @replaceState key @state
    else
      if isPlainObject map = key
        for k, v of map when !propsEq @state[k], v
          stateChanged = true
          @state[k] = v
          @load k
      else if isString(key) && !propsEq @state[key], value
        stateChanged = true
        @state[key] = value
        @load key

      if stateChanged
        @_updateAllState()
        @_saveToLocalStorage()

      key

  @getter
    propsToKey: ->
      @_propsToKey ?= (props) -> @modelName

  # remove one key-value pair
  removeState: (key) ->
    @_removeFromModelStore key
    ret = @state[key]
    delete @state[key]

    @_saveToLocalStorage()
    ret

  ###
    Removes all values in @state.
    All entries currently in FluxStore become: state: missing
  ###
  clearState: ->
    for k, v of @state
      @_removeFromModelStore k

    @state = {}

    @_saveToLocalStorage()

  resetState: ->
    @replaceState @_getInitialState false

  ###
    Replace all state with newState.
    Logically equivelent to:
      @clearState()
      @setState newState
  ###
  replaceState: (newState) ->
    for k, v of @state
      unless newState.hasOwnProperty k
        @_removeFromModelStore k
        delete @state[k]

    @setState newState

  #################
  # PRIVATE
  #################
  # there should be no need to call this directly. call setState.
  # overrides FluxModel#load
  load: (key, callback) ->
    modelRecord = if key == @name
      status: success, data: @savableState
    else if @state.hasOwnProperty key
      status: success, data: @state[key]
    else
      status: missing

    @updateModelRecord key, modelRecord
    callback && @onNextReady -> callback modelRecord
    modelRecord

  _removeFromModelStore: (key) ->
    @updateModelRecord key, status: missing

  postProcessLoadedState: (state) -> state

  _loadFromLocalStorage: ->
    if @class._persistant && !getEnv().resetAppState
      Promise.then => jsonStore.getItem @localStorageKey
      .then (loadedState) =>
        loadedState = @postProcessLoadedState loadedState
        if loadedState && neq loadedState, @state
          log "ApplicationState #{@class.name} loaded"
          @replaceState merge @state, loadedState

  _updateAllState: ->
    @load @name
    @state

  @getter
    savableState: -> merge @state
    localStorageKey: -> "ApplicationState:#{@name}"

  _saveToLocalStorage: (state = @state)->
    if @class._persistant
      Promise.then =>
        jsonStore.setItem @localStorageKey, @savableState

  _getInitialState: (loadFromLocalStorage = true) ->
    @_loadFromLocalStorage() if loadFromLocalStorage

    merge @getInitialState(), @getStateFields()
