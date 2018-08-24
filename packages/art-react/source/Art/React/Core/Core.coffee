Component = require './Component'
{reactArtEngineEpoch} = require './ReactArtEngineEpoch'
{isPlainArray, isString, arrayWith, log, isFunction} = require 'art-foundation'

module.exports = [
  [Component, "createAndInstantiateTopComponent", "createComponentFactory"]

  instantiateTopComponent: (componentInstance, bindToOrCreateNewParentElementProps) ->
    console.warn "React.instantiateTopComponent is DEPRICATED. Use: componentInstance.instantiateAsTopComponent"
    componentInstance.instantiateAsTopComponent bindToOrCreateNewParentElementProps

  onNextReady: (callback) -> reactArtEngineEpoch.onNextReady callback

  objectTreeFactoryOptions:
    mergePropsInto: (into, props) ->
      for k, v of props
        into[k] = if k == "text" && (oldValue = into[k])?
          if isPlainArray oldValue
            oldValue.concat v
          else
            [oldValue, v]
        else
          v
      into

    preprocessElement: (element) ->
      if isString element
        text: element

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

