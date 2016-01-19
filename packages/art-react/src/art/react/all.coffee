define [
  'art-foundation'
  './namespace'
  './component'
  './react_art_engine_epoch'
  './aim'
], (Foundation, React, Component, ReactArtEngineEpoch, Aim) ->
  {log, createAllClass, select} = Foundation
  {reactArtEngineEpoch} = ReactArtEngineEpoch

  createAllClass React,
    select Component, "createAndInstantiateTopComponent", "createComponentFactory"

    instantiateTopComponent: (componentInstance, bindToElementOrNewCanvasElementProps) ->
      console.warn "React.instantiateTopComponent is DEPRICATED. Use: componentInstance.instantiateAsTopComponent"
      componentInstance.instantiateAsTopComponent bindToElementOrNewCanvasElementProps

    onNextReady: (callback) -> reactArtEngineEpoch.onNextReady callback

    Aim
