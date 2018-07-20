Component = require './Component'
{reactArtEngineEpoch} = require './ReactArtEngineEpoch'
{isPlainArray, isString, arrayWith, log} = require 'art-foundation'

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
      else
        element
]

