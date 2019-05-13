{
  objectHasKeys
  toInspectedObjects
  log, globalCount, time, stackTime, BaseObject, shallowClone
  inspect, keepIfRubyTrue, stackTime, isPlainObject
  isWebWorker
  objectDiff
  Browser
  merge
  Promise
  propsEq
  defineModule
  compactFlattenAll2
  customCompactFlatten2
} = require 'art-standard-lib'
VirtualNode = require './VirtualNode'

defineModule module, class VirtualElement extends VirtualNode

  @resetCounters: ->
    @created = 0
    @instantiated = 0

  @resetCounters()

  @getCounters: -> {@created, @instantiated}

  emptyProps = {}
  emptyChildren = []
  constructor: (elementClassName, props, children) ->
    # globalCount "ReactVirtualElement_Created"
    VirtualElement.created++
    @elementClassName = elementClassName
    super props || emptyProps
    @children =
      if children?
        @_validateChildren customCompactFlatten2 children, keepIfRubyTrue
      else emptyChildren

  #################
  # Inspect
  #################
  @getter
    inspectedName: ->
      {key, elementClassName} = @
      "Virtual-#{elementClassName}#{if key then "-" + key  else ''}"

    inspectedObjects: ->
      "#{@inspectedName}": @inspectedObjectsContents

    inspectedObjectsContents: ->
      if @children.length > 0
        compactFlattenAll2 {@props}, toInspectedObjects @children
      else {@props}

  #####################################
  # Custom Concrete-Element Overrides
  #####################################
  ###
  EFFECT: execute the function 'f' with the Concrete-Element associated with this VirtualElement.
  IN: f = (concreteElement) -> x
  OUT: promise.then (x) ->

  OVERRIDE: OK

  PURPOSE: This is provided for the web-worker React so you can access the concrete element even though it is
    in another context. In that case, "f" will be serialized and any closure will be lost...
  ###
  withElement: (f) -> new Promise (resolve) => resolve f @element

  # EFFECT: @props has been updated and any props on the Concrete Element have been update
  # OUT: true if props changed
  _updateElementProps: (newProps) ->

  # IN: childrenElement: array of concrete elements to be all the children for this element
  _setElementChildren: (childElements) ->

  # OUT: new concrete element instance
  _newElement: (elementClassName, props, childElements, bindToOrCreateNewParentElementProps)->
    elementClassName

  _newErrorElement: -> null

  #################
  # Update
  #################
  _findOldChildToUpdate: (child)->
    oldChildren = @children
    for oldChild, i in oldChildren when oldChild
      if oldChild._canUpdateFrom child
        oldChildren[i] = null
        return oldChild
    null

  _canUpdateFrom: (b)->
    @elementClassName == b.elementClassName &&
    @key == b.key

  ###
  _fastUpdateChildren
    if no Nodes were added, removed or changed "types"
      _updateFrom newChild for all oldChildren
      return true
    else
      # use _slowUpdateChildren instead
      return false
  ###
  _fastUpdateChildren: (newChildren) ->
    oldChildren = @children
    return false unless oldChildren.length == newChildren.length
    for oldChild, i in oldChildren
      return false unless oldChild._canUpdateFrom newChildren[i]

    for oldChild, i in oldChildren
      oldChild._updateFrom newChildren[i]
    true

  _slowUpdateChildren: (newChildren) ->
    oldChildren = @children
    childElements = for newChild, i in newChildren
      finalChild = if oldChild = @_findOldChildToUpdate newChild
        newChildren[i] = oldChild._updateFrom newChild
      else
        newChild._instantiate @_parentComponent
      finalChild.element

    for child in oldChildren when child
      child._unmount()

    @_setElementChildren childElements
    @children = newChildren

  ###
  returns true if children changed
    if true, element.setChildren was called
    if false, the children individually may change, but
      this element's children are the same set
  ###
  _updateChildren: (newChildren) ->
    if @_fastUpdateChildren newChildren
      false
    else
      @_slowUpdateChildren newChildren
      true

  _unmount: ->
    for child in @children
      child._unmount()

  # returns this
  _updateFrom: (newNode) ->
    super
    return unless @element

    propsChanged    = @_updateElementProps newNode.props
    childrenChanged = @_updateChildren newNode.children

    # globalCount "ReactVirtualElement_UpdateFromTemporaryVirtualElement_#{if propsChanged || childrenChanged then 'Changed' else 'NoChange'}"

    @

  #####################
  # Instantiate
  #####################
  ###
  create element or componentInstance
  fully generate Virtual-AIM subbranch
  fully create all AIM elements
  returns this
  ###
  _instantiate: (parentComponent, bindToOrCreateNewParentElementProps) ->
    super
    VirtualElement.instantiated++
    # globalCount "ReactVirtualElement_Instantiated"

    childElements = for child, childIndex in @children
      try
        child._instantiate parentComponent
        child.element
      catch error
        log.error error
        log.error
          "Error instantiating child": {
            childIndex
            error
            child
            @elementClassName
            @props
          }
        @_newErrorElement()

    @element = @_newElement @elementClassName, @props, childElements, bindToOrCreateNewParentElementProps

    @

  ##################
  # PRIVATE
  ##################
  # EFFECT: @props has been set to the newProps if they changed
  # OUT: true if props changed
  _updateElementPropsHelper: (newProps, addedOrChanged, removed) ->
    oldPropsLength = @getPropsLength()
    oldProps = @props

    noChangeCount = 0
    noChange = -> noChangeCount++

    # objectDiff: (o1, o2, added, removed, changed, nochange, eq = defaultEq, o2KeyCount) ->
    newPropsLength = @setPropsLength objectDiff newProps, oldProps, addedOrChanged, removed, addedOrChanged, noChange, propsEq

    if newPropsLength == noChangeCount && oldPropsLength == newPropsLength
      false
    else
      @props = @_rawProps = newProps
      true

