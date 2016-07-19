Component = require './component'
{reactArtEngineEpoch} = require './react_art_engine_epoch'
{isPlainArray, isString, arrayWith, log} = require 'art-foundation'

module.exports = [
  [Component, "createAndInstantiateTopComponent", "createComponentFactory"]

  instantiateTopComponent: (componentInstance, bindToOrCreateNewParentElementProps) ->
    console.warn "React.instantiateTopComponent is DEPRICATED. Use: componentInstance.instantiateAsTopComponent"
    componentInstance.instantiateAsTopComponent bindToOrCreateNewParentElementProps

  onNextReady: (callback) -> reactArtEngineEpoch.onNextReady callback

  package: _package = require "art-react/package.json"
  version: _package.version

  objectTreeFactoryOptions:
    mergePropsInto: (into, props) ->
      for k, v of props
        into[k] = if k == "text" && isPlainArray(v) && isPlainArray oldValue = into[k]
          oldValue.concat v
        else
          v
      into

    preprocessElement: (element) ->
      if isString element
        text: [element]
      else
        element
]

