Foundation = require 'art-foundation'
FluxCore = require '../core'
FluxComponentBase = require './flux_component_base'

{Component, createComponentFactory} = Neptune.Art.React

{BaseObject, nextTick, mergeInfo, log, isPlainObject, isString, isFunction, inspect, time
  globalCount
  rubyTrue
  rubyFalse
  compactFlatten
} = Foundation

{ModelRegistry, FluxStatus} = FluxCore
{pending, success} = FluxStatus

###
FluxComponent

Declarative (automatic) Flux Subscription support:
- @subscriptions declaration method

TODO: _prepareSubscription should be triggered via createWithPostCreate rather than with each component creation
###

module.exports = class FluxComponent extends FluxComponentBase

  @createFluxComponentFactory: (spec) ->
    createComponentFactory spec, FluxComponent

  constructor: ->
    super
    @_autoMaintainedSubscriptions = {}
    @class._prepareSubscriptions()

  ###
  @subscriptions takes an object as input with each entry describing one subscription.
  A subscription consists of 3 parts:
    stateField:   the field in @state which will be set with the subscribed-to data
    model:        the subscribed-to model (from the ModelRegistry)
    key:          key for the specific, subscribed-to data in the model

  There are three different ways to define the subscription. Each entry in subscriptionMap
  can take any of the three patterns:

  Entry-pattern 1: Fully Explicit

    @subscriptions
      stateField:
        model: "modelName", model-instance or (props) -> "modelName"
        key:   "key",       key-object     or (props) -> "key" or key-object

  Entry-pattern 2: Implicit-key-from-stateField, Explicit-model

    DEPRICATED: See Entry-pattern 5.

    @subscriptions
      stateField:
        model: "modelName", model-instance or (props) -> "modelName"

    In this pattern, the key is the set to the same name as stateField. This is useful when
    subscribing to a known singleton value.

    For example, when using the ApplicationState model, you might to something like this:

      @subscriptions
        currentUser: model: "applicationState"

  Entry-pattern 3: Implicit-model, Explicit-key

    @subscriptions
      stateField: "key" or (props) -> "key" or key-object

    In this pattern the name of the model is the same as the stateField. This is the most common
    pattern. Example:

      @subscriptions
        user: (props) -> props.userId

    Or, using coffeescript shorthand:

      @subscriptions
        user: ({userId}) -> userId

    NOTE: If the key is not a function, it must be a string. Otherwise the subscription initialization
    will detect one of the other patterns. To use this pattern with a non-string key, do this:

      @subscriptions
        following: (props) -> userId: props.userId, feedId: props.feedId

  Entry-pattern 4: Implicit-key-from-props, implicit-model

    @subscriptions "myField"

    is equivelent to:

    @subscriptions
      myField:
        model:  myField
        key:    ({myField, myFieldId}) -> myField?.id || myFieldId

    Example:

      this:

        @subscriptions "post"

      is short for:

        @subscriptions
          post:
            model:  "post"
            key:    ({post, postId}) -> post?.id || postId

    TODO: What about a subscription to another post in the same component?

      Ex: @subscriptions "post", "chapterPost"

      I think the answer may be to declare model aliases. If there was a model
      named "chapterPost" declared, FluxComponent wouldn't need any changes. The
      trick is we want the chapterPost model to actually be the "post" model - i.e.
      if both a post and chapterPost subscription had the same key, they should share
      they same FluxStore entry.

      I think we can do this fairly well via that FluxModel. Something like this:

        class Post extends FluxModel
          @aliases "chapterPost"

      In fact... couldn't we just make @register assign the model instance to both .posts and .chapterPost?

      I think that's all we need!

  Entry-pattern 5: Implicit-key-from-fieldName, implicit-model

    @subscriptions "modelName.fieldName"

    is equivelent to:

    @subscriptions
      fieldName:
        key: fieldName
        model: modelName

  Key and Model functions:

    If the key or model is a function, the function:

      is executed without @ set
      inputs: (props)
      outputs: key or modelName respectively

  Key functions:

    Key-functions are called initially during getInitialState to set up initial
    subscriptions.

    If the key-function returns null, all depenendent state fields will be set to
    null. No other action will be taken.

    Whenever @props changes (e.g. when componentWillReceiveProps is called), these
    key-functions are re-evaluated. If the return value changes, subscriptions are
    updated and new data is requested where needed.
  ###
  @subscriptions: ->
    subscriptionProperties = @_getSubscriptionProperties()

    for arg in compactFlatten arguments
      if isPlainObject subscriptionMap = arg

        for stateField, value of subscriptionMap
          do (stateField, value) =>
            subscriptionProperties[stateField] =
              stateField: stateField
              params: value

      else if isString subscriptionNames = arg
        for subscriptionName in subscriptionNames.match /[_a-zA-Z][._a-zA-Z0-9]*/g
          # log subscriptionName:subscriptionName
          do (subscriptionName) ->
            if matches = subscriptionName.match /([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)/
              [_, modelName, field] = matches

              subscriptionProperties[field] =
                stateField: field
                params:
                  model: modelName
                  key: field

            else
              subscriptionNameId = subscriptionName + "Id"

              subscriptionProperties[subscriptionName] =
                stateField: subscriptionName
                params:
                  model: subscriptionName
                  key: (props) -> props[subscriptionName]?.id || props[subscriptionNameId]

    null

  ##########################
  # Lifecycle
  ##########################

  preprocessProps: (newProps) ->
    @_updateAllSubscriptions newProps = super
    newProps

  ##########################
  # PRIVATE
  ##########################

  @_getSubscriptionProperties: -> @getPrototypePropertyExtendedByInheritance "subscriptionProperties", {}

  @_prepareSubscription: (subscription) ->
    {stateField, params} = subscription

    if isPlainObject options = params
      {model, key} = options
      key = stateField unless key?
    else
      key = params
      model = stateField

    throw new Error "no model specified in subscription: #{inspect stateField:stateField, model:model, class:@name, subscription:subscription}" unless model

    if isString model
      modelName = model
      model = ModelRegistry.models[modelName]
      unless model
        console.error error = "RestComponent::subscriptions() model #{modelName} not registered (component = #{@getNamespacePath()})"
        throw new Error error

    subscription.model = model
    subscription.keyFunction = if isFunction key
        key
      else
        -> key

  @postCreate: ->
    @subscriptions @::subscriptions if @::subscriptions
    @_subscriptionsPrepared = false
    super

  @_prepareSubscriptions: ->
    return if @_subscriptionsPrepared
    @_subscriptionsPrepared = true
    for stateField, subscription of @_getSubscriptionProperties()
      @_prepareSubscription subscription

  _toFluxKey: (stateField, key, model, props) ->
    key = props[stateField]?.id if rubyFalse key
    if rubyTrue key
      model.toFluxKey key
    else
      null

  _updateSubscription: (stateField, key, model, props) ->
    fluxKey = @_toFluxKey stateField, key, model, props

    unless rubyTrue existingSubscriptionFluxKey = @_autoMaintainedSubscriptions[stateField]
      existingSubscriptionFluxKey = null

    if model && (fluxKey != null || fluxKey != existingSubscriptionFluxKey)
      if existingSubscriptionFluxKey != null
        @unsubscribe model, existingSubscriptionFluxKey, stateField

      @_autoMaintainedSubscriptions[stateField] = fluxKey

      if rubyTrue fluxKey
        @setState stateField + "Reload", -> model.load fluxKey
        @subscribe model, fluxKey, stateField, if initialData = props[stateField]
          status: success
          data: initialData

      else
        # clear state fields previously set
        @setStateFromFluxRecord stateField, status: success

      true

  _updateAllSubscriptions: (props = @props) ->

    for stateField, subscriptionProps of @class._getSubscriptionProperties()
      {keyFunction, model} = subscriptionProps
      if isFunction model
        model = model props

      if isString model
        unless model = @models[model]
          console.error "Could not find model named #{inspect model} for subscription in component #{@inspectedName}"

      if model
        @_updateSubscription stateField, keyFunction(props), model, props

    null

