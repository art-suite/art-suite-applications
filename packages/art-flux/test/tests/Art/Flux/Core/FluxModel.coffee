Foundation = require 'art-foundation'
{models} = Flux = require 'art-flux'
{merge, log, isString, Promise, BaseObject, Epoch, timeout, createWithPostCreate, CommunicationStatus} = Foundation

{FluxModel, fluxStore, ModelRegistry} = Flux
{success, failure, missing, pending} = CommunicationStatus

reset = -> Flux._reset()

module.exports = suite:
  load: ->

    test "model with async load", ->
      new Promise (resolve) ->
        reset()
        createWithPostCreate class MyBasicModel extends FluxModel

          load: (key) ->
            fluxStore.onNextReady => @updateFluxStore key, status: missing
            null

        res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          return unless fluxRecord.status != pending
          assert.eq fluxRecord, status: missing, key: "123", modelName: "myBasicModel"
          resolve()
        assert.eq res, status: pending, key: "123", modelName: "myBasicModel"


    test "model with @loadFluxRecord", ->
      new Promise (resolve) ->
        reset()
        createWithPostCreate class MyBasicModel extends FluxModel

          loadFluxRecord: (key) ->
            timeout(20).then -> status: missing

        res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          return unless fluxRecord.status != pending
          assert.eq fluxRecord, status: missing, key: "123", modelName: "myBasicModel"
          resolve()
        assert.eq res, status: pending, key: "123", modelName: "myBasicModel"

    test "model with custom load - delayed", ->
      reset()
      createWithPostCreate class MyBasicModel extends FluxModel

        load: (key, callback) ->
          @updateFluxStore key, -> status: success, data: theKeyIs:key
          null

      new Promise (resolve) ->
        res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          assert.eq fluxRecord, status: success, key: "123", modelName: "myBasicModel", data: theKeyIs:"123"
          resolve()
        assert.eq res, status: pending, key: "123", modelName: "myBasicModel"

      .then ->
        new Promise (resolve) ->
          fluxStore.subscribe "myBasicModel", "456", (fluxRecord) ->
            assert.eq fluxRecord, status: success, key: "456", modelName: "myBasicModel", data: theKeyIs:"456"
            resolve()

    test "model with custom load - immediate", ->
      reset()
      createWithPostCreate class MyBasicModel extends FluxModel

        load: (key, callback) ->
          @updateFluxStore key, status: success, data: theKeyIs:key

      new Promise (resolve) ->
        res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          log.error "THIS SHOULDN'T HAPPEN!"
          reject()
        assert.eq res, status: success, key: "123", modelName: "myBasicModel", data: theKeyIs:"123"
        fluxStore.onNextReady -> resolve()

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

    test "two simultantious FluxModel requests on the same key only triggers one store request", ->
      reset()
      counts =
        load: 0
        subscription1: 0
        subscription2: 0
      createWithPostCreate class MyBasicModel extends FluxModel
        load: (key, callback) ->
          counts.load++
          @updateFluxStore key, status: success, data: theKeyIs:key

      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> assert.eq(fluxRecord.count, 2);counts.subscription1++
      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> assert.eq(fluxRecord.count, 2);counts.subscription2++

      fluxStore.update "myBasicModel", "123", (fluxRecord) -> count: (fluxRecord.count || 0)+ 1
      fluxStore.update "myBasicModel", "123", (fluxRecord) -> count: (fluxRecord.count || 0)+ 1

      fluxStore.onNextReady ->
        assert.eq counts, load: 1, subscription1: 1, subscription2: 1

    test "two simultantious FluxModel requests on the different keys triggers two store requests", ->
      reset()
      counts =
        load: 0
        sub1: 0
        sub2: 0
      createWithPostCreate class MyBasicModel extends FluxModel
        load: (key, callback) ->
          counts.load++
          @updateFluxStore key, status: success, data: theKeyIs:key

      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> assert.eq(fluxRecord.count, 1);counts.sub1++
      fluxStore.subscribe "myBasicModel", "456", (fluxRecord) -> assert.eq(fluxRecord.count, 1);counts.sub2++

      fluxStore.update "myBasicModel", "123", (fluxRecord) -> count: (fluxRecord.count || 0)+ 1
      fluxStore.update "myBasicModel", "456", (fluxRecord) -> count: (fluxRecord.count || 0)+ 1

      fluxStore.onNextReady ->
        assert.eq counts, load: 2, sub1: 1, sub2: 1

  loadPromise: ->
    test "multiple loadPromises with the same key only load once", ->
      reset()
      loadCount = 0
      createWithPostCreate class User extends FluxModel
        loadData: (key) ->
          timeout 10
          .then ->
            loadCount++
            id: key
            userName: "fred"

      p1 = models.user.loadPromise "abc"
      p2 = models.user.loadPromise "abc"
      p3 = models.user.loadPromise "def"
      Promise.all [p1, p2, p3]
      .then ->
        assert.eq loadCount, 2
        assert.eq p1, p2
        assert.neq p1, p3

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
