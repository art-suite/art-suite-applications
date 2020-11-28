{Component, createComponentFactory} = Neptune.Art.React

{
  defineModule
  log, isPlainObject, isString, isFunction
  globalCount
  formattedInspect
} = require 'art-standard-lib'

{ModelRegistry, FluxSubscriptionsMixin} = require '../Core'
{success} = require 'art-communication-status'
{parseSubscriptions} = require './ComponentLib'

###
FluxComponent

Declarative (automatic) Flux Subscription support:
- @subscriptions declaration method

TODO:
  * _prepareSubscription should be triggered via createWithPostCreate rather than with each component creation
###

defineModule module, class FluxComponent extends FluxSubscriptionsMixin Component
  @abstractClass()

  ##########################
  # Constructor
  ##########################
  constructor: ->
    super
    @class._prepareSubscriptions()

  ##########################
  # Define Subscriptions
  ##########################
  # @Subscriptions does a lot; see parseSubscriptions and README.md for doc
  @subscriptions: (args...) ->
    for stateField, options of parseSubscriptions args
      @_addSubscription stateField, options

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
  # PRIVATE CLASS METHODS
  ##########################
  @extendableProperty subscriptionProperties: {}

  # TODO: add setStateField if the model implements a setStateField method
  @_addSubscription: (stateField, subscriptionOptions) ->

    throw new Error "subscription already defined for: #{formattedInspect {stateField}}" if @getSubscriptionProperties()[stateField]

    @extendSubscriptionProperties stateField, subscriptionOptions

    existingGetters = /element/ # TODO: make a list of all existing getters and don't replace them!
    unless stateField.match existingGetters
      @addGetter stateField, -> @state[stateField]
      @addGetter (statusField       = stateField + "Status"), -> @state[statusField]
      @addGetter (progressField     = stateField + "Progress"), -> @state[progressField]
      @addGetter (failureInfoField  = stateField + "FailureInfo"), -> @state[failureInfoField]

  @_prepareSubscription: (subscription) ->
    {stateField, model, key} = subscription

    throw new Error "no model specified in subscription: #{formattedInspect stateField:stateField, model:model, class:@name, subscription:subscription}" unless model

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

  ##########################
  # PRIVATE MEMBER METHODS
  ##########################
  _toFluxKey: (stateField, key, model, props) ->
    key ?= props[stateField]?.id
    if key?
      model.toKeyString key
    else
      null

  _updateSubscription: (stateField, key, model, props) ->

    @subscribe stateField,
      model.modelName
      key
      stateField: stateField
      initialFluxRecord: if initialData = props[stateField]
        status: success
        data:   initialData

  _updateAllSubscriptions: (props = @props) ->
    for stateField, subscriptionProps of @class.getSubscriptionProperties()
      {keyFunction, model} = subscriptionProps

      model = try
        if isFunction model
          model props
        else
          model

      catch error
        log "UpdateSubscription modelFunction error": {FluxComponent: @, stateField, model, subscriptionProps, error}
        null

      if isString model
        unless model = @models[model]
          console.error "Could not find model named #{formattedInspect model} for subscription in component #{@inspectedName}"

      if model
        key = try
          keyFunction props
        catch error
          log "UpdateSubscription keyFunction error": {FluxComponent: @, stateField, model, subscriptionProps, error}
          null
        @_updateSubscription stateField, key, model, props

    null

  ##########################
  # WebPack HotReload support
  ##########################
  _componentDidHotReload: ->
    @unsubscribeAll()
    @_updateAllSubscriptions()
    super

  @postCreateConcreteClass: ({hotReloaded})->
    @subscriptions @::subscriptions if @::subscriptions
    @_subscriptionsPrepared = false
    @_prepareSubscriptions() if hotReloaded
    super
