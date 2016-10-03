Foundation = require 'art-foundation'
FluxCore = require '../core'

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

  FluxEntry-pattern 1: Fully Explicit

    @subscriptions
      stateField:
        model: "modelName", model-instance or (props) -> "modelName"
        key:   "key",       key-object     or (props) -> "key" or key-object

  FluxEntry-pattern 2: Implicit-key-from-stateField, Explicit-model

    DEPRICATED: See FluxEntry-pattern 5.

    @subscriptions
      stateField:
        model: "modelName", model-instance or (props) -> "modelName"

    In this pattern, the key is the set to the same name as stateField. This is useful when
    subscribing to a known singleton value.

    For example, when using the ApplicationState model, you might to something like this:

      @subscriptions
        currentUser: model: "applicationState"

  FluxEntry-pattern 3: Implicit-model, Explicit-key

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

  FluxEntry-pattern 4: Implicit-key-from-props, implicit-model

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

  FluxEntry-pattern 5: Implicit-key-from-fieldName, implicit-model

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

    @addGetter stateField, -> @state[stateField]

  ##########################
  # Lifecycle
  ##########################

  preprocessProps: (newProps) ->
    @_updateAllSubscriptions newProps = super
    newProps

  componentWillUnmount: ->
    super
    @unsubscribeAll()

  ##########################
  # PRIVATE
  ##########################

  @extendableProperty subscriptionProperties: {}

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

  @postCreateConcreteClass: ->
    @subscriptions @::subscriptions if @::subscriptions
    @_subscriptionsPrepared = false
    super

  @_prepareSubscriptions: ->
    return if @_subscriptionsPrepared
    @_subscriptionsPrepared = true
    for stateField, subscription of @getSubscriptionProperties()
      @_prepareSubscription subscription

  _toFluxKey: (stateField, key, model, props) ->
    key = props[stateField]?.id if rubyFalse key
    if rubyTrue key
      model.toFluxKey key
    else
      null

  _updateSubscription: (stateField, key, model, props) ->
    fluxKey = @_toFluxKey stateField, key, model, props

    unless @state[stateField]
      @state[stateField] = initialData = props[stateField]

    unless rubyTrue existingSubscriptionFluxKey = @_autoMaintainedSubscriptions[stateField]
      existingSubscriptionFluxKey = null

    if model && (fluxKey != null || fluxKey != existingSubscriptionFluxKey)
      if existingSubscriptionFluxKey != null
        @unsubscribe model, existingSubscriptionFluxKey, stateField

      @_autoMaintainedSubscriptions[stateField] = fluxKey

      if rubyTrue fluxKey
        @subscribe model, fluxKey, stateField, if initialData
          status: success
          data: initialData

      else
        # clear state fields previously set
        @setStateFromFluxRecord stateField, status: success

      true

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

