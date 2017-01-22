Foundation = require 'art-foundation'
Flux = require 'art-flux'
{merge, log, isString, Promise, BaseObject, Epoch, timeout, createWithPostCreate, CommunicationStatus} = Foundation

{FluxModel, fluxStore, ModelRegistry, FluxSubscriptionsMixin} = Flux
{success, failure, missing, pending} = CommunicationStatus

reset = -> Flux._reset()

module.exports = suite:
  load: ->

    test "subscribeOnModelRegistered", ->
      new Promise (resolve, reject) ->
        createWithPostCreate class MyModelA extends FluxSubscriptionsMixin FluxModel
          constructor: ->
            super
            @subscribeOnModelRegistered "myModelB", "myFluxKey"
            .then resolve, reject

        createWithPostCreate class MyModelB extends FluxModel