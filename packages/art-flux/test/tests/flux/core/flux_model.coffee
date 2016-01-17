define [
  'art.foundation'
  'art.flux'
], (Foundation, Flux) ->
  {log, isString, Join, BaseObject, Epoch} = Foundation

  {FluxModel, fluxStore, ModelRegistry} = Flux

  reset = -> Flux._reset()

  suite "Art.Flux.Core.FluxModel", ->

    test "model with async load", (done) ->
      reset()
      class MyBasicModel extends FluxModel
        @register()

        load: (key) ->
          fluxStore.onNextReady => fluxStore.update @_name, key, status: 404
          null

      res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
        return unless fluxRecord.status != "pending"
        assert.eq fluxRecord, status: 404, key: "123", modelName: "myBasicModel"
        done()
      assert.eq res, status: "pending", key: "123", modelName: "myBasicModel"

    test "model with load that returns fluxRecord", (done) ->
      reset()
      class MyBasicModel extends FluxModel
        @register()

        load: (key) -> fluxStore.update @_name, key, status: 404

      res = fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
        assert.eq fluxRecord, status: 404, key: "123", modelName: "myBasicModel"
        done()
      assert.eq res, status: 404, key: "123", modelName: "myBasicModel"

    test "model with custom load", (done) ->
      reset()
      class MyBasicModel extends FluxModel
        @register()

        load: (key, callback) -> fluxStore.update @_name, key, status: 200, data: theKeyIs:key

      joiner = new Join
      joiner.do (done) ->
        fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
          assert.eq fluxRecord, status: 200, key: "123", modelName: "myBasicModel", data: theKeyIs:"123"
          done()

      joiner.do (done) ->
        fluxStore.subscribe "myBasicModel", "456", (fluxRecord) ->
          assert.eq fluxRecord, status: 200, key: "456", modelName: "myBasicModel", data: theKeyIs:"456"
          done()

      joiner.join ->
        done()

    test "two simultantious FluxModel requests on the same key only triggers one store request", (done) ->
      reset()
      counts =
        load: 0
        sub1: 0
        sub2: 0
      class MyBasicModel extends FluxModel
        @register()
        load: (key, callback) ->
          counts.load++
          fluxStore.update @_name, key, status: 200, data: theKeyIs:key

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
      class MyBasicModel extends FluxModel
        @register()
        load: (key, callback) ->
          counts.load++
          fluxStore.update @_name, key, status: 200, data: theKeyIs:key

      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> counts.sub1++
      fluxStore.subscribe "myBasicModel", "456", (fluxRecord) -> counts.sub2++

      fluxStore.onNextReady ->
        assert.eq counts, load: 2, sub1: 1, sub2: 1
        done()

    test "@aliases addes aliases to the model registry", ->
      reset()
      class User extends FluxModel
        @aliases "owner", "sister"
        @register()

      assert.eq Flux.models.user.class, User
      assert.eq Flux.models.user, Flux.models.owner
      assert.eq Flux.models.user, Flux.models.sister
