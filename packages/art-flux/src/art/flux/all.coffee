define [
  'art.foundation'
  "./namespace"
  "./core"
  "./react"
], (Foundation, Flux, {FluxStore, ModelRegistry, FluxModel}, {FluxComponent}) ->
  {BaseObject, select} = Foundation
  {createAllClass} = BaseObject
  {fluxStore} = FluxStore

  createAllClass Flux,
    select ModelRegistry, "models"
    FluxStore: FluxStore
    FluxModel: FluxModel
    FluxComponent: FluxComponent
    fluxStore: fluxStore

    # used only for testing
  Flux._reset = ->
      fluxStore._reset()
      ModelRegistry._reset()

  Flux
