define [
  'art-foundation'
  '../core'
], (Foundation, FluxCore) ->
  {BaseObject, log, isString, isPlainObject, merge, plainObjectsDeepEq, mergeInto} = Foundation
  {FluxStore, FluxModel} = FluxCore
  {fluxStore} = FluxStore
  propsEq = plainObjectsDeepEq

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

  ###

  class ApplicationState extends FluxModel
    @classProperty "persistant"

    @stateFields: (fields) ->
      @_stateFields = mergeInto @_stateFields, fields
      for field, initialValue of fields
        do (field) =>
          @_addSetter @::, field, (v) -> @setState field, v
          @_addGetter @::, field, -> @state[field]

    loadFromLocalStorage: ->
      if @class.persistant
        data = localStorage.getItem @name
        v = JSON.parse data if data
        log loadFromLocalStorage:v
        v

    saveToLocalStorage: (state = @state)->
      if @class.persistant
        localStorage.setItem @name, v = JSON.stringify state
        log saveToLocalStorage:v

    constructor: ->
      super
      @state = merge @getInitialState(), @class._stateFields, try @loadFromLocalStorage()

    # override
    getInitialState: -> {}

    # signatures:
    #   (map from keys to values) ->  # set many states. => map
    #   (key, value) ->               # set one state. => key
    setState: (key, value) ->
      if isPlainObject map = key
        for k, v of map when !propsEq @state[k], v
          @state[k] = v
          @load k
      else if isString(key) && !propsEq @state[key], value
        @state[key] = value
        @load key

      @saveToLocalStorage()
      key

    # there should be no need to call this directly. call setState.
    load: (key, callback) ->
      fluxRecord = if @state.hasOwnProperty key
        status: 200, data: @state[key]
      else
        status: 404

      fluxStore.update @_name, key, fluxRecord
      callback && fluxStore.onNextReady -> callback fluxRecord
      fluxRecord
