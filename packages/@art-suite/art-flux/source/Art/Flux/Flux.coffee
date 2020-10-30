{defineModule} = require 'art-foundation'
FluxCore = require "./Core"

{FluxStore, ModelRegistry, FluxModel, FluxSubscriptionsMixin} = FluxCore
{fluxStore} = FluxStore

defineModule module, [

  FluxSubscriptionsMixin:     FluxSubscriptionsMixin
  FluxStore:                  FluxStore
  FluxModel:                  FluxModel
  ModelRegistry:              ModelRegistry
  ApplicationState:           require './Models/ApplicationState'

  models:                     ModelRegistry.models
  fluxStore:                  fluxStore

  # ONLY for testing
  _reset: ->
    fluxStore._reset()
    ModelRegistry._reset()
]
