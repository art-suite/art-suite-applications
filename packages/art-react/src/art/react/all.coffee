Foundation = require 'art-foundation'
Component = require './component'
ReactArtEngineEpoch = require './react_art_engine_epoch'

{log, createAllClass, select} = Foundation
{reactArtEngineEpoch} = ReactArtEngineEpoch

React = require './namespace'
.includeInNamespace null,
  [Component, "createAndInstantiateTopComponent", "createComponentFactory"]

  instantiateTopComponent: (componentInstance, bindToElementOrNewCanvasElementProps) ->
    console.warn "React.instantiateTopComponent is DEPRICATED. Use: componentInstance.instantiateAsTopComponent"
    componentInstance.instantiateAsTopComponent bindToElementOrNewCanvasElementProps

  onNextReady: (callback) -> reactArtEngineEpoch.onNextReady callback
