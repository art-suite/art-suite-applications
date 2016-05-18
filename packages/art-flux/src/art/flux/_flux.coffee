FluxCore = require "./core"
{FluxComponent} = require "./react"

{FluxStore, ModelRegistry, FluxModel, FluxStatus} = FluxCore
{fluxStore} = FluxStore

module.exports = [
  FluxStatus

  FluxStore:                  FluxStore
  FluxModel:                  FluxModel
  ModelRegistry:              ModelRegistry
  FluxComponent:              FluxComponent
  ApplicationState:           require './models/application_state'

  models:                     ModelRegistry.models
  createFluxComponentFactory: FluxComponent.createFluxComponentFactory
  fluxStore:                  fluxStore

  # ONLY for testing
  _reset: ->
    fluxStore._reset()
    ModelRegistry._reset()
]
