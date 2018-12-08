Foundation = require 'art-foundation'
VirtualNode = require './VirtualNode'
ReactArtEngineEpoch = require './ReactArtEngineEpoch'
{
  defineModule
  log, merge, mergeInto, clone, shallowClone
  inspect, compactFlatten, keepIfRubyTrue, BaseObject, fastBind
  slice
  isObject
  isString
  isArray
  isFunction
  globalCount
  time
  stackTime
  countStep
  createWithPostCreate
  arrayWithout
  upperCamelCase
  createObjectTreeFactory
  select
  formattedInspect
  getModuleBeingDefined
  InstanceFunctionBindingMixin
  getEnv
  mergeIntoUnless
} = Foundation
{reactArtEngineEpoch} = ReactArtEngineEpoch

React = require './namespace'
{artReactDebug} = getEnv()


{HotLoader} = require 'art-foundation/dev_tools/webpack'
{runHot} = HotLoader

StateFieldsMixin = require './StateFieldsMixin'
PropFieldsMixin = require './PropFieldsMixin'

if ArtEngineCore = Neptune.Art.Engine.Core
  {StateEpoch, GlobalEpochCycle} = ArtEngineCore
  {stateEpoch} = StateEpoch
  {globalEpochCycle} = GlobalEpochCycle
  onNextStateEpochReady = (f) -> stateEpoch.onNextReady f
  timePerformance = (name, f) -> globalEpochCycle.timePerformance name, f
else
  onNextStateEpochReady = (f) -> reactArtEngineEpoch.onNextReady f
  timePerformance = (name, f) -> f()

# globalCount = ->
# time = stackTime = (f) -> f()

###
React.js vs ReactArtEngine
--------------------------

Generaly, ReactArtEngine is designed to work just like React.js. There is
some evolution, though, which I try to note below. -SBD

ReactArtEngine: "Instantiation"
-------------------------------

This is not a concept in React.js. It isn't important to the client, but it
is useful to understand in the implementation.

In-short: a non-instantiated component only has properties. It doesn't have
state and it isn't rendered. An instantiated component has state and gets
rendered at least once.

When a component is used in a render function, and with every re-render,
an instance-object is created with standard javascript "new ComponentType."
However, that component instance is only a shell - it contains the
properties passed into the constructor and nothing else.

Once the entire render is done, the result is diffed against the current
Virtual-AIM. The component instance is compared against existing components
via the diff rules. If an existing, matching component exists, that
component is updated and the new instance is discard. However, if an
existing match doesn't exist, then the new component instance is
"instantiated" and added to the virtual-Aim.

QUESTIONS
---------

I just discovered it is possible, and useful, for a component to be rendered
after it is unmounted. I don't think this is consistent with Facebook-React.

Possible: if @setState is called after it is unmounted, it will trigger a
render. This can happen in FluxComponents when a subscription updates.

Useful: Why does this even make sense? Well, with Art.Engine we have
removedAnimations. That means the element still exists even though it has been
"removed." It exists until the animation completes. It is therefor useful to
continue to receive updates from React, where appropriate, during that "sunset"
time.

Thoughts: I think this is OK, though this changes what "unmounted" means. I just
fixed a bug where @state got altered without going through preprocessState first
when state changes after the component was unmounted. How should I TEST this???

###
defineModule module, -> class Component extends PropFieldsMixin StateFieldsMixin InstanceFunctionBindingMixin VirtualNode
  @abstractClass()

  @nonBindingFunctions: "getInitialState
    componentWillReceiveProps
    componentWillMount
    componentWillUnmount
    componentWillUpdate
    componentDidMount
    componentDidUpdate
    render".split /\s+/


  @resetCounters: ->
    @created =
    @rendered =
    @instantiated = 0

  @resetCounters()

  @getCounters: -> {@created, @rendered, @instantiated}

  @topComponentInstances: []
  @rerenderAll: ->
    for component in @topComponentInstances
      component.rerenderAll()

  rerenderAll: ->
    @_queueRerender()
    for component in @subComponents
      component.rerenderAll()

  @createAndInstantiateTopComponent: (spec) ->
    Component.createComponentFactory(spec).instantiateAsTopComponent()

  unknownModule = {}
  @createComponentFactory: (spec, BaseClass = Component) ->
    componentClass = if spec?.prototype instanceof Component
      spec
    else if spec?.constructor == Object
      _module = getModule(spec) || unknownModule
      _module.uniqueComponentNameId ||= 1

      anonymousComponentName = "Anonymous#{BaseClass.getClassName()}"
      anonymousComponentName += "_#{_module.uniqueComponentNameId++}"
      anonymousComponentName += if _module.id then "_Module#{_module.id}" else '_ModuleUnknown'

      class AnonymousComponent extends BaseClass
        @_name: anonymousComponentName

        for k, v of spec
          @::[k] = v
    else
      throw new Error "Specification Object or class inheriting from Component required."

    createWithPostCreate componentClass

  @getModule: getModule = (spec = @::)->
    spec.module || spec.hotModule || getModuleBeingDefined()

  @getCanHotReload: -> @getModule()?.hot

  @_hotReloadUpdate: (@_moduleState) ->
    name = @getClassName()
    if hotInstances = @_moduleState.hotInstances
      log "Art.React.Component #{@getName()} HotReload":
        instanceToRerender: hotInstances.length

      # update all instances
      for instance in hotInstances
        instance._componentDidHotReload()

  @allComponents: {}

  @postCreateConcreteClass: ({classModuleState, hotReloadEnabled})->
    super
    @_hotReloadUpdate classModuleState if hotReloadEnabled
    @toComponentFactory()

  @toComponentFactory: ->
    {objectTreeFactoryOptions} = React
    {postProcessProps} = objectTreeFactoryOptions

    createObjectTreeFactory (merge objectTreeFactoryOptions,
        inspectedName: @getName() + "ComponentFactory"
        class: @
        bind: "instantiateAsTopComponent"
      ),
      (props, children) =>
        if children
          if props
            props.children = children
          else
            props = {children}

        instance = new @ postProcessProps props
        # instance._validateChildren props?.children # TODO: only in dev mode!

        instance

  @instantiateAsTopComponent = (props, options) ->
    new @(props).instantiateAsTopComponent options

  @createdComponents: null
  @pushCreatedComponent: (c)->
    @createdComponents ||= []
    @createdComponents.push c
  @resetCreatedComponents: -> @createdComponents = null

  emptyProps = {}
  constructor: (props = emptyProps) ->
    Component.created++
    globalCount "ReactComponent_Created"
    super props
    @state = {}
    @refs = null
    @_pendingState = null
    @_pendingUpdates = null
    @_virtualAimBranch = null
    @_mounted = false
    @_wasMounted = false
    @_bindList = null
    @_epochUpdateQueued = false
    Component.pushCreatedComponent @

  ###
  SEE: VirtualElement#withElement for more
  IN: f = (concreteElement) -> x
  OUT: promise.then (x) ->
  ###
  withElement: (f) -> @_virtualAimBranch.withElement f

  #OUT: this
  instantiateAsTopComponent: (bindToOrCreateNewParentElementProps) ->
    Component.topComponentInstances.push @
    @_instantiate null, bindToOrCreateNewParentElementProps

  unbindTopComponent: ->
    unless 0 <= index = Component.topComponentInstances.indexOf @
      throw new Error "not a top component!"

    Component.topComponentInstances = arrayWithout Component.topComponentInstances, index
    @_unmount()

  @getter
    inspectedName: -> "#{@className}#{if @key then "-"+@key  else ''}"
    mounted: -> @_mounted

  onNextReady: (callback, forceEpoch = true) ->
    onNextStateEpochReady callback, forceEpoch, @

  ################################################
  # Component API (based loosly on Facebook.React)
  ################################################

  # signatures:
  #   (newStateMapObject, callback) ->
  #     sets state from each k-v pair in newStateMapObject
  #     returns newStateMapObject
  #   (null, callback) ->
  #     no-op (except for callback)
  #     returns: null
  #   (stateKey, stateValue, callback) ->
  #     set one state
  #     returns: stateValue
  # callback is always called onNextReady
  setState: (a, b, c) ->
    if isString a
      c && @onNextReady c
      return @_setSingleState a, b

    newState = a
    callback = b

    callback && @onNextReady callback

    if newState
      if isFunction newState
        @_queueUpdate newState

      else
        testState = @state
        _state = null
        for k, v of newState when @_pendingState || testState[k] != v
          _state ||= @_getStateToSet()
          _state[k] = v

    newState

  # OUT: newState
  replaceState: (newState, callback) ->
    @_setPendingState newState
    callback && @onNextReady callback
    newState

  # OUT: true
  forceUpdate: (callback) ->
    log.error "forceUpdate is DEPRICATED"
    @_queueChangingComponentUpdates()
    callback && @onNextReady callback
    true

  # Called when the component is instantiated.
  # ReactArtEngine ONLY: you CAN call setState/setSingleState during getInitialState:
  #   * setState calls populate @_pendingState and are merged after getInitialState: @state = merge @getInitialState(), @_pendingState
  #   * a reactArtEngineEpoch cycle is not queued; the only significant expense is one extra object creation to store the @_pendingState
  getInitialState: -> {}

  # TODO: Facebook React provides this. Add it if we have a concrete use for it.
  # @getDefaultProps: -> {}

  # returns a VirtalNode instance
  # render: -> Element()

  ################################################
  # Component LifeCycle based on Facebook React
  ################################################

  ###
  Called each time webpack hot-reloads a module.
  It is important that this change the components state to trigger a rerender.
  Make sure you add module: module to your component definition or
  run your definition in a runHot module, -> function
  ###
  componentDidHotReload: ->
    count = (@state._hotModuleReloadCount || 0) + 1
    @setState _hotModuleReloadCount: count

  # Invoked when a component is receiving new props. This method is not called
  # for the initial render.
  #
  # Use this as an opportunity to react to a prop transition before render()
  # is called by updating the state using this.setState(). The old props can
  # be accessed via this.props. Calling this.setState() within this function
  # will not trigger an additional render.
  componentWillReceiveProps: defaultComponentWillReceiveProps = (newProps) ->

  # Invoked once, both on the client and server, immediately before the initial
  # rendering occurs. If you call setState within this method, render() will see
  # the updated state and will be executed only once despite the state change.
  componentWillMount: defaultComponentWillMount = ->

  # Invoked immediately before a component is unmounted from the AIM.
  # Perform any necessary cleanup in this method, such as invalidating
  # timers or cleaning up any AIM elements that were created in componentDidMount.
  componentWillUnmount: defaultComponentWillUnmount = ->

  # Invoked immediately before rendering when new props or state are being
  # received. This method is not called for the initial render.
  #
  # Use this as an opportunity to perform preparation before an update occurs.
  #
  # Note: You cannot use @setState() in this method. If you need to update
  # state in response to a prop change, use componentWillReceiveProps instead.
  #
  # ReactArtEngine-specific: if newProps == @props then props didn't change; same with newState
  componentWillUpdate: defaultComponentWillUpdate = (newProps, newState)->

  # Invoked once immediately after the initial rendering occurs. At this
  # point in the lifecycle, the component has an AIM representation which you
  # can access via @getDOMNode() (TODO).
  componentDidMount: defaultComponentDidMount = ->

  # Invoked immediately after updating occurs. This method is not called for the initial render.
  # Use this as an opportunity to operate on the AIM when the component has been updated.
  #
  # ReactArtEngine-specific: if newProps == @props then props didn't change; same with newState
  componentDidUpdate: defaultComponentDidUpdate = (oldProps, oldState)->

  # TODO: Facebook React provides this. Add it if we have a concrete use for it.
  # NOTE: So far this seems unnecessary since we control the whole stack.
  # shouldComponentUpdate(newProps, newState) -> boolean

  ################################################
  # Component LifeCycle - ArtReact extensions
  ################################################

  ###
  Function:     preprocessProps

  When:         Called on component instantiation and any time props are updated

  IN:           newProps - The props received from the render call which created/updated this component

  OUT:          plain Object - becomes @props. Can be newProps, based on newProps or entirely new.

  Guarantee:    @props will allways be passed through preprocessProps before it is set.
                i.e. Your render code will never see a @props that hasen't been preprocessed.

  Be sure your preprocessProps: (requirements)
    - returns a plain Object
    - doesn't modify the newProps object passed in (create and return new object to add/alter props)
    - call super!

  Examples:
    # minimal
    preprocessProps: ->
      merge super, myProp: 123

    # a little of everything
    preprocessProps: ->
      newProps = super
      @setState foo: newProps.foo
      merge newProps, myProp: "dude: #{newProps.foo}"

  Okay:
    you can call @setState (Art.Flux.Component does exactly this!)

  Description:
    Either return exactly newProps which were passed in OR create a new, plain object.
    The returned object can contain anything you want.
    These are the props the component will see in any subsequent lifecycle calls.

  NOTE: Unique to Art.React. Not in Facebook's React.

  NOTES RE Facebook.React:
    Why add this? Well, often you want to apply a transformation to @props whenever its set OR it changes.
    With Facebook.React there is no one lifecycle place for this. Component instantiation/mounting
    and component updating are kept separate. I have found it is very error-prone to implement
    this common functionality manually on each component that needs it.

  ###
  preprocessProps: defaultPreprocessProps = (newProps) -> newProps

  ###
  Function:     preprocessState

  When:         preprocessState is called:
                  immediatly after getInitialState
                  after preprocessProps
                  after componentWillUpdate
                  before rendering

  IN:           newState - the state which is proposed to become @state
  OUT:          object which will become @state. Can be newState, be based on newState or completely new.

  Guarantees:   @state will allways be passed through preprocessState before it is set.
                i.e. Your render code will never see a @state that hasen't been preprocessed.

  NOTES RE Facebook.React:
    Why add this? Well, often you want to apply a transformation to @state whenever it is initialized
    OR it changes. With Facebook.React there is no one lifecycle place for this. Component
    instantiation/mounting and component updating are kept separate. I have found it is very
    error-prone to implement this common functionality manually on each component that needs it.

    An example of this is FluxComponents. They alter state implicitly as the subscription data comes in, and
    and component instantiation. preprocessState makes it easy to transform any data written via FluxComponents
    into a standard form.

  SBD NOTES TO SELF:
    I think:
      - it is OK to directly mutate newState, can we declare this offically part of the API?
      - calls to @setState in preprocessState will be applied NEXT epoch.
      - could make getInitialState obsolete, but I think we'll keep it around for convenience and consistency
  ###
  preprocessState: defaultPreprocessState = (newState) -> newState

  ######################
  # ART REACT EXTENSIONS
  ######################

  # findAll: t/f  # by default find won't return children of matching Elements, set to true to return all matches
  # verbose: t/f  # log useful information on found objects
  find: (pattern, {findAll, verbose} = {}, matches = [], path) ->

    pathString = if path then path + "/" + @inspectedName else @inspectedName

    matchFound = if usedFunction = isFunction pattern
      !!(functionResult = pattern @)
    else
      pathString.match pattern

    if matchFound
      if verbose
        @log if usedFunction
          matched: pathString, functionResult: functionResult
        else
          matched: pathString
      matches.push @
    else if verbose == "all"
      @log if usedFunction
        notMatched: pathString, functionResult: functionResult
      else
        notMatched: pathString

    if (!matchFound || findAll) && @subComponents
      child.find pattern, arguments[1], matches for child in @subComponents
    matches

  @getter
    inspectedObjects: ->
      "Component-#{@inspectedName} #{@_virtualAimBranch?.inspectedName ? '(not instantiated)'}":
        @_virtualAimBranch?.inspectedObjectsContents ? {@props}

  getPendingState: -> @_pendingState || @state

  ######################
  # PRIVATE
  ######################
  _getStateToSet: ->
    if @_wasMounted then @_getPendingState() else @state

  _setSingleState: (stateKey, stateValue, callback) ->
    if @_pendingState || @state[stateKey] != stateValue
      @_getStateToSet()[stateKey] = stateValue

    stateValue

  _queueRerender: ->
    @_getPendingState()

  _setPendingState: (pendingState) ->
    ###
    2016-12: I can't decide! Should we allow state updates on unmounted components or not?!?!
    RELVANCE: allowing state updates allows us to update animating-out Art.Engine Elements.
    This is useful, for example, to hide the TextInput Dom element

    I'm generally against updating unmounted components:
      - they don't get new props. Logically, since they are unmounted,
        they should have no props, yet they do. They would surely
        completely break if we set @props = {}.

      - Since they don't get new @props, there is no way for the parent-before-unmounting
        to control unmounted Components. If their state can change, their parent-before
        should have some control.

    BUT, we need a better answer for animating-out Components. There is a need for re-rendering them
    at the beginning and ending of their animating-out process.

    Animating-Out
      - Most things can probably be handled by 1 render just before animating-out starts. This
        is awkward to do manually: First render decides we are going to remove a sub-component, but
        doesn't - during that render - instead it tells that component it is about to be animated-out.
        Then, it queues another render where it actually removes the sub-component. And this must all
        be managed by the parent Component, when really it's 100% the child-component's concern.

      - What if a Component can request a "final render" just BEFORE it is unmounted? The parent Component's
        render runs, removing the child Component. Then ArtReact detects the child needs unmounting, but just
        before it unmounts it, the child gets a re-render as-if it's props changed, though they didn't. This
        in turn will update any Element or child Components for their animating-out state. After that,
        the component will get no more renders - since it will then be unmounted and unmounted components don't
        get rendered.

      - Further, when we do this final render, we can signal it is "final" via @props.
        - have the component get a final-render notification (via a member function override).
          That function takes as inputs the last-good @props, and returns the final-render @props.
          If it returns null, there will be no final render. This is the default implementation.

        - I LIKE!

      - Conclusion: New Component override: (TODO - I think we should go for this solution!)

          finalRenderProps: (previousProps) -> null

        To request a final-render, all you need to do is add this to your Component:

          finalRenderProps: (previousProps) -> previousProps

        And you may find it handy to also do:

          finalRenderProps: (previousProps) -> merge previousProps, finalRender: true

        Then you can do something special for your final-render:

          render: ->
            {finalRender} = @props

            if finalRender ...

    DO WE NEED SOMETHING MORE POWERFUL?

      - Do we need more than 1 "final render" - during animating-out?
      - Do we need an animating-out-done render?
      - A general solution would be a "manual unmount" option. I don't love this, but
        I also don't love tying this explicitly to ArtEngine's animating-out features.

    To ENABLE updates on unmounted Components, remove: || !@_mounted
    ###
    @_queueChangingComponentUpdates()
    @_pendingState = pendingState

  _queueChangingComponentUpdates: ->
    unless @_epochUpdateQueued
      @_epochUpdateQueued = true
      reactArtEngineEpoch.addChangingComponent @

  _queueUpdate: (updateFunction) ->
    @_queueChangingComponentUpdates()
    (@_pendingUpdates ?= []).push updateFunction

  _getPendingState: ->
    @_pendingState || @_setPendingState {}

  _unmount: ->
    @_removeHotInstance()
    @_componentWillUnmount()

    @_virtualAimBranch?._unmount()
    @_mounted = false

  _addHotInstance: ->
    if moduleState = @class._moduleState
      (moduleState.hotInstances ||= []).push @

  _removeHotInstance: ->
    if moduleState = @class._moduleState
      {hotInstances} = moduleState
      if hotInstances && 0 <= index = hotInstances.indexOf @
        moduleState.hotInstances = arrayWithout hotInstances, index

  #OUT: this
  emptyState = {}
  _instantiate: (parentComponent, bindToOrCreateNewParentElementProps) ->
    super
    globalCount "ReactComponent_Instantiated"
    @bindFunctionsToInstance()

    @props = @_preprocessProps @props

    # globalCount "ReactComponent _instantiate", stackTime =>

    @_addHotInstance()
    @_componentWillMount()

    initialState = @getInitialState()
    __state = @state
    @state = emptyState

    @state = @_preprocessState merge @getStateFields(), __state, initialState

    @_virtualAimBranch = @_renderCaptureRefs()

    @_virtualAimBranch._instantiate @, bindToOrCreateNewParentElementProps
    @element = @_virtualAimBranch.element

    @_componentDidMount()
    @_wasMounted = @_mounted = true
    @

  emptyArray = []
  _renderCaptureRefs: ->
    Component.rendered++

    start = globalEpochCycle?.startTimePerformance()

    ret = null
    globalCount "ReactComponent_Rendered"
    VirtualNode.assignRefsTo = @refs = {}
    VirtualNode.currentlyRendering = @
    Component.resetCreatedComponents()

    log "render component: #{@className}" if artReactDebug

    ret = @render()
    throw new Error "#{@className}: render must return a VirtualNode. Got: #{inspect ret}" unless ret instanceof VirtualNode

    @subComponents = Component.createdComponents || emptyArray
    VirtualNode.currentlyRendering =
    VirtualNode.assignRefsTo = null

    globalEpochCycle?.endTimePerformance "reactRender", start
    ret

  _updateRefsAfterReRender: ->
    for k, v of @refs
      if _updateTarget = @refs[k]._updateTarget
        @refs[k] = _updateTarget

    for c, i in @subComponents when update = c._updateTarget
      @subComponents[i] = update

  _canUpdateFrom: (b)->
    @class == b.class &&
    @key == b.key

  _shouldReRenderComponent: (componentInstance) ->
    @_propsChanged(componentInstance) || @_pendingState

  # renders the component and updates the Virtual-AIM as needed.
  _reRenderComponent: ->

    oldRefs = @refs

    unless newRenderResult = @_renderCaptureRefs()
      log.error ComponentRenderError: @
      throw new Error "Component render function returned: #{formattedInspect newRenderResult}"

    if @_virtualAimBranch._canUpdateFrom newRenderResult
      @_virtualAimBranch._updateFrom newRenderResult
      @_updateRefsAfterReRender()
    else
      # TODO - this should probably NOT be an error, but it isn't easy to solve.
      # Further, this is wrapped up with the pending feature of optionally returing an array of Elements from the render function.
      # Last, this should not be special-cased if possible. VitualElement children handling code should be used to handle these updates.

      console.error """
        REACT-ART-ENGINE ERROR - The render function's top-level Component/VirtualElement changed 'too much.' The VirtualNode returned by a component's render function cannot change its Type or Key.

        Solution: Wrap your changing VirtualNode with a non-changing VirtualElement.

        Offending component: #{@classPathName}
        Offending component assigned to: self.offendingComponent
        """
      console.log "CHANGED-TOO-MUCH-ERROR-DETAILS - all these properties must be the same on the oldRoot and newRoot",
        oldRoot: select @_virtualAimBranch, "key", "elementClassName", "class"
        newRoot: select newRenderResult, "key", "elementClassName", "class"
      self.offendingComponent = @
      @_virtualAimBranch?._unmount()
      (@_virtualAimBranch = newRenderResult)._instantiate @

    @element = @_virtualAimBranch.element

  # 1. Modifies @ to be an exact clone of componentInstance.
  # 2. Updates the true-AIM as we go.
  # 3. returns @
  _updateFrom: (componentInstance) ->

    super
    if @_shouldReRenderComponent componentInstance
      globalCount "ReactComponent_UpdateFromTemporaryComponent_Changed"
      @_applyPendingState componentInstance.props
    else
      globalCount "ReactComponent_UpdateFromTemporaryComponent_NoChange"

    @

  ###
  Clears out @_pendingUpdates and @_pendingState, applying them all to 'state' as passed-in.

  NOTE:
    This is a noop if @_pendingUpdates and @_pendingState are null.
    OldState is returned without any work done.

  ASSUMPTIONS:
    if @_pendingState is set, it is an object we are allowed to mutate
      It will be mutated and be the return-value of this function.

  IN:
    oldState - the state to update

  EFFECTS:
    oldState is NOT modified
    @_pendingState and @_pendingUpdates are null and have been applied to oldState

  OUT: state is returned as-is unless @_pendingState or @_pendingUpdates is set
  ###
  _resolvePendingUpdates: (oldState = @state)->
    if @_pendingState
      newState = mergeIntoUnless @_pendingState, oldState
      @_pendingState = null

    if @_pendingUpdates
      newState ?= merge oldState

      for updateFunction in @_pendingUpdates
        newState = updateFunction.call @, newState

      @_pendingUpdates = null

    newState ? oldState


  ###
  NOTES:
    - newProps is non-null if this component is being updated from a non-instantiated Component.
    - This is where @props gets set for any update, but not where it gets set for component initializiation.
  ###
  _applyPendingState: (newProps) ->
    return unless @_epochUpdateQueued || newProps

    oldProps = @props
    oldState = @state

    if newProps
      newProps = @_preprocessProps @_rawProps = newProps

      # NOTE: User-overridable @componentWillReceiveProps is allowed to call @setState.
      @_componentWillReceiveProps newProps
    else
      newProps = oldProps

    @_updateComponent newProps, @_resolvePendingUpdates()

    @_reRenderComponent()

    # NOTE: Any updates state-changes triggered in @componentDidUpdate will be delayed until next epoch
    @_componentDidUpdate oldProps, oldState


  ###
  IN:
    newProps: if set, replaces props
    newState:
  ###
  _updateComponent: (newProps, newState) ->

    # NOTE: User-overridable @componentWillUpdate is allowed to call @setState.
    @_componentWillUpdate newProps, newState

    ###
    React.js forbids calling setState from componentWillUpdate, but I see no reason for this.
    This next line safely supports state updates in componentWillUpdate in a pure-functionalish way:
      after a setState in @componentWillUpdate,
      the new state will not be visible in the remainder of that @componetWillUpdate call
      but it will be visible in any subsquent lifecycle call such as @render

    NOTES:
      @_resolvePendingUpdates is used here to immeidately apply any changes @_componentDidUpdate
        caused. However, if it didn't cause any changes, it's a noop.
        Performance FYI: If @_componentDidUpdate triggers any changes, one new object will be created.

      @_epochUpdateQueued is cleared AFTER @_componentDidUpdate so calles to @setState won't
        actually trigger an epoch.
    ###
    newState = @_resolvePendingUpdates newState
    @_epochUpdateQueued = false

    # SAVE THE CHANGES NOW!
    @props = newProps

    # NOTE: Any updates state-changes triggered in @preprocessState will be delayed until next epoch
    # NOTE: @_preprocessState assumes @props has already been updated
    @state = @_preprocessState newState

  ########################
  # PRIVATE
  # LifeCycle Management
  ########################

  # NOTE: The reason for defaultComponent* values instead of making the defaults NULL
  #   is so inheritors can call "super" safely.
  # IDEA: We could make createComponentFactory gather up all custom life-cycle functions,
  #   and execute each in sequence therefor they don't need to call super.
  #   We could also enable mixins this way.
  _componentWillReceiveProps: (newProps) ->
    return if defaultComponentWillReceiveProps == @componentWillReceiveProps
    @componentWillReceiveProps newProps

  _preprocessProps: (props) ->
    props = super props # triggers PropFieldsMixin - which will include any default values from @propFields
    return props if defaultPreprocessProps == @preprocessProps
    try
      @preprocessProps props
    catch error
      log preprocessProps: {Component: @, error}
      props

  _preprocessState: (state) ->
    return state if defaultPreprocessState == @preprocessState
    try
      @preprocessState state
    catch error
      log preprocessState: {Component: @, error}
      state

  _componentWillMount: ->
    return if defaultComponentWillMount == @componentWillMount
    @componentWillMount()

  _componentDidHotReload: ->
    @bindFunctionsToInstance true
    try @componentDidHotReload()

  _componentWillUnmount: ->
    return if  defaultComponentWillUnmount == @componentWillUnmount
    @componentWillUnmount()

  _componentWillUpdate: (newProps, newState)->
    return unless defaultComponentWillUpdate
    @componentWillUpdate newProps, newState

  _componentDidMount: ->
    return if defaultComponentDidMount == @componentDidMount
    @onNextReady =>
      @componentDidMount()

  _componentDidUpdate: (oldProps, oldState)->
    return if defaultComponentDidUpdate == @componentDidUpdate
    @onNextReady =>
      @componentDidUpdate oldProps, oldState
