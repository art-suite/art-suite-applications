# TODO: rename to ApplicationStateModel
FluxCore = require '../Core'
{
  lowerCamelCase
  each, clone, BaseObject, log, isString, isPlainObject, merge, propsEq, mergeInto, Unique, defineModule
} = require 'art-standard-lib'
{FluxStore, FluxModel} = FluxCore
{fluxStore} = FluxStore
{pending, success, failure, missing} = require "art-communication-status"
StateFieldsMixin = require 'art-react/StateFieldsMixin'

###
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

defineModule module, class ApplicationState extends StateFieldsMixin FluxModel
  @abstractClass()
  @persistant: -> @_persistant = true

  @postCreateConcreteClass: ({hotReloaded, classModuleState}) ->
    ret = super

    if hotReloaded
      {liveClass, hotUpdatedFromClass} = classModuleState

      tempInstance = new hotUpdatedFromClass
      liveInstance = liveClass.getSingleton()
      newDefaultState = tempInstance.state
      currentState = liveInstance.state

      log "Flux.ApplicationState: model hot-reloaded": model: liveInstance.name
      for k, v of newDefaultState when !currentState.hasOwnProperty k
        liveInstance.setState k, v
        log "new state field added": field: k, value: v

    ret

  constructor: ->
    super
    @_updateAllState @state = @_getInitialState()

  ###
  provided for consistency with React Components
  To use: override
  But, using @stateFields works just as well and also declares field getter / setters.
  ###
  getInitialState: -> {}

  ###
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
    if isPlainObject map = key
      for k, v of map when !propsEq @state[k], v
        @state[k] = v
        @load k
    else if isString(key) && !propsEq @state[key], value
      @state[key] = value
      @load key

    @_updateAllState()

    @_saveToLocalStorage()
    key

  # remove one key-value pair
  removeState: (key) ->
    @_removeFromFluxStore key
    ret = @state[key]
    delete @state[key]
    ret

  ###
  Removes all values in @state.
  All entries currently in FluxStore become: state: missing
  ###
  clearState: ->
    for k, v of @state
      @_removeFromFluxStore k

    @state = {}

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
        @_removeFromFluxStore k
        delete @state[k]

    @setState newState

  #################
  # PRIVATE
  #################
  # there should be no need to call this directly. call setState.
  # overrides FluxModel#load
  load: (key, callback) ->
    fluxRecord = if key == @name
      status: success, data: @savableState
    else if @state.hasOwnProperty key
      status: success, data: @state[key]
    else
      status: missing

    @updateFluxStore key, fluxRecord
    callback && fluxStore.onNextReady -> callback fluxRecord
    fluxRecord

  _removeFromFluxStore: (key) ->
    @updateFluxStore key, status: missing

  _loadFromLocalStorage: ->
    if @class._persistant
      data = localStorage.getItem @localStorageKey
      v = JSON.parse data if data
      log _loadFromLocalStorage:v
      v

  _updateAllState: ->
    @load @name
    @state

  @getter
    savableState: -> merge @state
    localStorageKey: -> "ApplicationState:#{@name}"

  _saveToLocalStorage: (state = @state)->
    if @class._persistant
      localStorage.setItem @localStorageKey, JSON.stringify @savableState

  _getInitialState: (loadFromLocalStorage = true) ->
    merge @getInitialState(), @getStateFields(), loadFromLocalStorage && try @_loadFromLocalStorage()
