Foundation = require 'art-foundation'
FluxCore = require '../Core'

{Component, createComponentFactory} = Neptune.Art.React

{
  defineModule
  BaseObject, nextTick, mergeInfo, log, isPlainObject, isString, isFunction, inspect, time
  globalCount
  rubyTrue
  rubyFalse
  compactFlatten
  Validator
, defineModule, CommunicationStatus} = Foundation

{ModelRegistry, FluxSubscriptionsMixin} = FluxCore
{pending, success} = CommunicationStatus

###
FluxComponent

Declarative (automatic) Flux Subscription support:
- @subscriptions declaration method

TODO: _prepareSubscription should be triggered via createWithPostCreate rather than with each component creation
###

defineModule module, class FluxComponent extends FluxSubscriptionsMixin Component
  @abstractClass()

  @postCreateConcreteClass: ->
    @subscriptions @::subscriptions if @::subscriptions
    @_subscriptionsPrepared = false
    super

  ##########################
  # Constructor
  ##########################
  constructor: ->
    super
    # @_autoMaintainedSubscriptions = {}
    @class._prepareSubscriptions()

  ##########################
  # Define Subscriptions
  ##########################

  # @Subscriptions does a lot.
  # Please see the docs: https://github.com/imikimi/art-flux/wiki
  @subscriptions: ->
    for arg in compactFlatten arguments
      if isPlainObject subscriptionMap = arg

        for stateField, value of subscriptionMap
          do (stateField, value) =>
            @_addSubscription stateField, value

      else if isString subscriptionNames = arg
        for subscriptionName in subscriptionNames.match /[_a-z][._a-z0-9]*/gi

          do (subscriptionName) =>
            if matches = subscriptionName.match /([_a-z0-9]+)\.([_a-z0-9]+)/i
              [_, modelName, stateField] = matches
              @_addSubscription stateField, model: modelName

            else
              subscriptionNameId = subscriptionName + "Id"

              @_addSubscription subscriptionName,
                key: (props) -> props[subscriptionName]?.id || props[subscriptionNameId]

    null

  ##########################
  # Lifecycle
  ##########################

  _preprocessProps: (newProps) ->
    @_updateAllSubscriptions newProps = super
    newProps

  componentWillUnmount: ->
    super
    @unsubscribeAll()

  ##########################
  # PRIVATE
  ##########################

  @extendableProperty subscriptionProperties: {}

  subscriptionValidator = new Validator
    stateField: "present string"
    model:      required: validate: (v) -> isFunction(v) || isString(v)
    key:        required: validate: (v) -> v != "undefined"

  @_normalizeSubscriptionOptions: normalizeSubscriptionOptions = (stateField, subscriptionOptions) ->
    if isPlainObject subscriptionOptions
      {key, model} = subscriptionOptions
      stateField: stateField
      model:      model || stateField
      key:        if subscriptionOptions.hasOwnProperty("key") then key else stateField
    else
      stateField: stateField
      model:      stateField
      key:        subscriptionOptions

  @_addSubscription: (stateField, subscriptionOptions) ->

    subscriptionOptions = normalizeSubscriptionOptions stateField, subscriptionOptions

    subscriptionValidator.validateSync subscriptionOptions

    throw new Error "stateField subscription already defined" if @getSubscriptionProperties()[stateField]

    @extendSubscriptionProperties stateField, subscriptionOptions

    existingGetters = /element/ # TODO: make a list of all existing getters and don't replace them!
    unless stateField.match existingGetters
      @addGetter stateField, -> @state[stateField]


  @_prepareSubscription: (subscription) ->
    {stateField, model, key} = subscription

    throw new Error "no model specified in subscription: #{inspect stateField:stateField, model:model, class:@name, subscription:subscription}" unless model

    if isString model
      modelName = model
      model = ModelRegistry.models[modelName]
      unless model
        console.error error = "#{@getName()}::subscriptions() model '#{modelName}' not registered (component = #{@getNamespacePath()})"
        throw new Error error

    subscription.model = model
    subscription.keyFunction = if isFunction key
        key
      else
        -> key

  @_prepareSubscriptions: ->
    return if @_subscriptionsPrepared
    @_subscriptionsPrepared = true
    for stateField, subscription of @getSubscriptionProperties()
      @_prepareSubscription subscription

  _toFluxKey: (stateField, key, model, props) ->
    key ?= props[stateField]?.id
    if key?
      model.toKeyString key
    else
      null

  _updateSubscription: (stateField, key, model, props) ->

    # DO WE NEED THIS???
    # I think subscribe calls setState synchronously
    # AND I think during Component init, setStates are sync, not async....
    # Need to test!
    unless @state[stateField]
      @state[stateField] = initialData = props[stateField]

    @subscribe stateField,
      model.modelName
      key
      stateField: stateField
      initialFluxRecord: if initialData
        status: success
        data:   initialData

  _updateAllSubscriptions: (props = @props) ->

    for stateField, subscriptionProps of @class.getSubscriptionProperties()
      {keyFunction, model} = subscriptionProps

      model = model props if isFunction model

      if isString model
        unless model = @models[model]
          console.error "Could not find model named #{inspect model} for subscription in component #{@inspectedName}"

      if model
        @_updateSubscription stateField, keyFunction(props), model, props

    null

