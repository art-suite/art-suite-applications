Component = require './Component'
{reactArtEngineEpoch} = require './ReactArtEngineEpoch'
{isPlainArray, isString, arrayWith, log, isFunction, isArray} = require 'art-foundation'
VirtualNode = require './VirtualNode'
VirtualElement = require './VirtualElement'

getMergedTextPropValue = (oldValue, v) ->
  if oldValue?
    v = if isArray oldValue
      oldValue.concat v
    else
      [oldValue, v]
  else v

module.exports = [
  [Component, "createAndInstantiateTopComponent", "createComponentFactory"]

  resetReactPerfCounters: ->
    VirtualElement.resetCounters()
    Component.resetCounters()

  getReactPerfCounters: ->
    VirtualElement: VirtualElement.getCounters()
    Component:      Component.getCounters()

  instantiateTopComponent: (componentInstance, bindToOrCreateNewParentElementProps) ->
    console.warn "React.instantiateTopComponent is DEPRICATED. Use: componentInstance.instantiateAsTopComponent"
    componentInstance.instantiateAsTopComponent bindToOrCreateNewParentElementProps

  onNextReady: (callback) -> reactArtEngineEpoch.onNextReady callback

  objectTreeFactoryOptions:

    # NOTE: postProcessProps is ignored by objectTreeFactory - we must apply it oursevles
    postProcessProps: (props) ->
      if v = props?._textFromString
        props.text = getMergedTextPropValue props.text, v
        delete props._textFromString
      props

    mergePropsInto: (into, props) ->
      for k, v of props
        if k == "_textFromString"
          into.text = getMergedTextPropValue into.text, v
        else
          into[k] = v

      into

    preprocessElement: (element, Factory) ->
      if isString element
        log.warn "ArtReact: string children are DEPRICATED. Use text: 'string'. Currently rendering: #{VirtualNode.currentlyRendering?.inspectedName || 'none'}. Factory: #{Factory.inspect()}"
        _textFromString: element

      # DEPRICATED
        # Why? It seemed like a good idea, but a better idea, is
        # the possibility of passing a function for sub-rendering children.
        # For example, I use this for my ButtonWrapper -  a child can be a function
        # which takes a bool as input to signale if the cursor is currently hovering.
      # else if isFunction element
      #   action: element
      else
        element
]

