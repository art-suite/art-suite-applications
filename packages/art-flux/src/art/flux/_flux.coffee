{defineModule} = require 'art-foundation'
FluxCore = require "./core"
{FluxComponent} = require "./react"

{FluxStore, ModelRegistry, FluxModel, FluxSubscriptionsMixin} = FluxCore
{fluxStore} = FluxStore

defineModule module, [

  FluxSubscriptionsMixin:     FluxSubscriptionsMixin
  FluxStore:                  FluxStore
  FluxModel:                  FluxModel
  ModelRegistry:              ModelRegistry
  FluxComponent:              FluxComponent
  ApplicationState:           require './models/ApplicationState'

  models:                     ModelRegistry.models
  createFluxComponentFactory: FluxComponent.createFluxComponentFactory
  fluxStore:                  fluxStore

  # ONLY for testing
  _reset: ->
    fluxStore._reset()
    ModelRegistry._reset()

  package: _package = require "art-flux/package.json"
  version: _package.version
]
