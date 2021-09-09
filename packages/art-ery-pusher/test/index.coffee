require '../Client'
require './TestConfig'
require 'art-flux'
{ArtEryFluxModel} = require 'art-ery/Flux'
require "art-foundation/testing"
.init
  artConfigName: "Test"
  defineTests: ->
    out = require './tests'
    ArtEryFluxModel.defineModelsForAllPipelines()
    out