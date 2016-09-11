Foundation = require 'art-foundation'
Flux = require 'art-flux'
{log, isString, Promise, BaseObject, Epoch, timeout, createWithPostCreate} = Foundation

{FluxModel, fluxStore, ModelRegistry, success, failure, missing, pending} = Flux

reset = -> Flux._reset()

module.exports = suite:
  load: ->

    test "model with async load", (done) ->
      reset()
      createWithPostCreate class MyBasicModel extends FluxModel

        load: (key) ->
          fluxStore.onNextReady => @updateFluxStore key, status: missing
          null

      res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
        log "subscription update", fluxRecord
        return unless fluxRecord.status != pending
        assert.eq fluxRecord, status: missing, key: "123", modelName: "myBasicModel"
        done()
      assert.eq res, status: pending, key: "123", modelName: "myBasicModel"


    test "model with @loadFluxRecord", (done) ->
      reset()
      createWithPostCreate class MyBasicModel extends FluxModel

        loadFluxRecord: (key) ->
          timeout(20).then -> status: missing

      res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
        log "subscription update", fluxRecord
        return unless fluxRecord.status != pending
        assert.eq fluxRecord, status: missing, key: "123", modelName: "myBasicModel"
        done()
      assert.eq res, status: pending, key: "123", modelName: "myBasicModel"

    test "model with custom load", ->
      reset()
      createWithPostCreate class MyBasicModel extends FluxModel

        load: (key, callback) -> @updateFluxStore key, status: success, data: theKeyIs:key

      new Promise (resolve) ->
        fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          assert.eq fluxRecord, status: success, key: "123", modelName: "myBasicModel", data: theKeyIs:"123"
          resolve()
      .then ->
        new Promise (resolve) ->
          fluxStore.subscribe "myBasicModel", "456", (fluxRecord) ->
            assert.eq fluxRecord, status: success, key: "456", modelName: "myBasicModel", data: theKeyIs:"456"
            resolve()

    test "model with @loadData", ->
      reset()
      createWithPostCreate class MyBasicModel extends FluxModel

        loadData: (key) -> Promise.resolve theKeyIs:key

      new Promise (resolve) ->
        fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          assert.eq fluxRecord, status: success, key: "123", modelName: "myBasicModel", data: theKeyIs:"123"
          resolve()
      .then ->
        new Promise (resolve) ->
          fluxStore.subscribe "myBasicModel", "456", (fluxRecord) ->
            assert.eq fluxRecord, status: success, key: "456", modelName: "myBasicModel", data: theKeyIs:"456"
            resolve()

  simultanious: ->

    test "two simultantious FluxModel requests on the same key only triggers one store request", (done) ->
      reset()
      counts =
        load: 0
        sub1: 0
        sub2: 0
      createWithPostCreate class MyBasicModel extends FluxModel
        load: (key, callback) ->
          counts.load++
          @updateFluxStore key, status: success, data: theKeyIs:key

      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> counts.sub1++
      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> counts.sub2++

      fluxStore.onNextReady ->
        assert.eq counts, load: 1, sub1: 1, sub2: 1
        done()

    test "two simultantious FluxModel requests on the different keys triggers two store requests", (done) ->
      reset()
      counts =
        load: 0
        sub1: 0
        sub2: 0
      createWithPostCreate class MyBasicModel extends FluxModel
        load: (key, callback) ->
          counts.load++
          @updateFluxStore key, status: success, data: theKeyIs:key

      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> counts.sub1++
      fluxStore.subscribe "myBasicModel", "456", (fluxRecord) -> counts.sub2++

      fluxStore.onNextReady ->
        assert.eq counts, load: 2, sub1: 1, sub2: 1
        done()

  aliases: ->
    test "@aliases adds aliases to the model registry", ->
      reset()
      createWithPostCreate class User extends FluxModel
        @aliases "owner", "sister"

      assert.eq Flux.models.user.class, User
      assert.eq Flux.models.user, Flux.models.owner
      assert.eq Flux.models.user, Flux.models.sister

  functionsBoundToInstances: ->
    test "use bound function", ->
      reset()
      createWithPostCreate class User extends FluxModel
        foo: -> @_foo = (@_foo || 0) + 1

      {user} = User
      {foo} = user
      foo()
      assert.eq user._foo, 1
      foo()
      assert.eq user._foo, 2
