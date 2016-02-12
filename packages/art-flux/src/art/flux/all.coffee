Foundation = require 'art-foundation'
Flux = require "./namespace"
FluxCore = require "./core"
FluxReact = require "./react"
ApplicationState = require './models/application_state'

{FluxStore, ModelRegistry, FluxModel, FluxStatus} = FluxCore
{FluxComponent} = FluxReact
{BaseObject, select} = Foundation
{createAllClass} = BaseObject
{fluxStore} = FluxStore

createAllClass Flux,
  FluxStatus

  FluxStore:                  FluxStore
  FluxModel:                  FluxModel
  ModelRegistry:              ModelRegistry
  FluxComponent:              FluxComponent
  ApplicationState:           ApplicationState

  models:                     ModelRegistry.models
  createFluxComponentFactory: FluxComponent.createFluxComponentFactory
  fluxStore:                  fluxStore

# used only for testing
Flux._reset = ->
    fluxStore._reset()
    ModelRegistry._reset()
