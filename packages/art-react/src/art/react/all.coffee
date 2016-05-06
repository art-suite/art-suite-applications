Foundation = require 'art-foundation'
Component = require './component'
ReactArtEngineEpoch = require './react_art_engine_epoch'

{log, createAllClass, select} = Foundation
{reactArtEngineEpoch} = ReactArtEngineEpoch

React = require './namespace'
.includeInNamespace null,
  [Component, "createAndInstantiateTopComponent", "createComponentFactory"]

  instantiateTopComponent: (componentInstance, bindToOrCreateNewParentElementProps) ->
    console.warn "React.instantiateTopComponent is DEPRICATED. Use: componentInstance.instantiateAsTopComponent"
    componentInstance.instantiateAsTopComponent bindToOrCreateNewParentElementProps

  onNextReady: (callback) -> reactArtEngineEpoch.onNextReady callback
