define [
  'art-foundation'
  "./namespace"
  "./core"
  "./react"
], (Foundation, Flux, {FluxStore, ModelRegistry, FluxModel, FluxStatus}, {FluxComponent}) ->
  {BaseObject, select} = Foundation
  {createAllClass} = BaseObject
  {fluxStore} = FluxStore

  createAllClass Flux,
    select ModelRegistry, "models"
    FluxStore: FluxStore
    FluxModel: FluxModel
    ModelRegistry: ModelRegistry
    FluxComponent: FluxComponent
    fluxStore: fluxStore
    FluxStatus


    # used only for testing
  Flux._reset = ->
      fluxStore._reset()
      ModelRegistry._reset()

  Flux
