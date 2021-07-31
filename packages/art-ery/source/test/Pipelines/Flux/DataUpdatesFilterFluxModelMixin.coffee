{log, defineModule} = require 'art-standard-lib'
{getFluxLog} = require './FluxLog'

# CAN'T CONVERT TO CAFFEINE-SCRIPT YET - @artModelMixin must generate a CoffeeScript class
defineModule module, -> (superClass) ->
  class DataUpdatesFilterFluxModelMixin extends superClass
    dataUpdated: (key, data) -> getFluxLog().push(dataUpdated: {model: @name, key, data});super
    dataDeleted: (key, data) -> getFluxLog().push(dataDeleted: {model: @name, key, data});super
