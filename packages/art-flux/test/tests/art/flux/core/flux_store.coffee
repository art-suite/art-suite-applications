{log, merge, createWithPostCreate} = require 'art-foundation'
{Core:{FluxStore, FluxModel, ModelRegistry}} = require 'art-flux'
{fluxStore} = FluxStore

reset = ->
  fluxStore._reset()
  ModelRegistry._reset()
  createWithPostCreate class MyModel extends FluxModel

suite "Art.Flux.Core.FluxStore", ->
  test "fluxStore.reset & length", ->
    reset()
    assert.eq fluxStore.length, 0

  test "fluxStore.update basic", (done)->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 1
      assert.eq fluxStore.get("myModel", "myKey"), bar: 1, key: "myKey", modelName: "myModel"
      done()

  test "fluxStore.update with no subscriber is noop", (done)->
    reset()
    fluxStore.update "myModel", "myKey", bar:1

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 0
      assert.eq !!fluxStore._getEntry("myModel", "myKey"), false
      done()

  test "fluxStore.update twice replaces old value", (done)->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1
    fluxStore.update "myModel", "myKey", baz:2

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 1
      assert.eq fluxStore.get("myModel", "myKey"), baz: 2, key: "myKey", modelName: "myModel"
      done()

  test "fluxStore.getHasSubscribers", (done)->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    assert.eq false, fluxStore.getHasSubscribers "myModel", "myKey"
    assert.eq false, fluxStore.getHasSubscribers "myModel", "myKey"

    fluxStore.onNextReady ->
      assert.eq true, fluxStore.getHasSubscribers "myModel", "myKey"
      done()

  test "fluxStore.update with update function can merge", (done)->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1
    fluxStore.update "myModel", "myKey", (old) -> merge old, baz:2

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 1
      assert.eq fluxStore.get("myModel", "myKey"), bar:1, baz: 2, key: "myKey", modelName: "myModel"
      done()

  test "fluxStore.update cant set key", (done)->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1, key: "boggle"

    fluxStore.onNextReady ->
      assert.eq fluxStore.get("myModel", "myKey"), bar: 1, key: "myKey", modelName: "myModel"
      done()

  test "fluxStore.update cant update key", (done)->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1

    fluxStore.onNextReady ->
      fluxStore.update "myModel", "myKey", bar:1, key: "boggle2"

      fluxStore.onNextReady ->
        assert.eq fluxStore.get("myModel", "myKey"), bar: 1, key: "myKey", modelName: "myModel"
        done()

  test "fluxStore.subscribe basic", (done)->
    reset()
    subscriber = (fields) ->
      assert.eq fields, bar: 1, key: "myKey", modelName: "myModel"
      done()

    fluxStore.subscribe "myModel", "myKey", subscriber
    fluxStore.update "myModel", "myKey", bar: 1

  test "fluxStore.unsubscribe", (done)->
    reset()
    count1 = 0
    count2 = 0
    subscriber1 = (fields) -> count1++
    subscriber2 = (fields) -> count2++

    fluxStore.subscribe "myModel", "myKey", subscriber1
    fluxStore.subscribe "myModel", "myKey", subscriber2
    fluxStore.update "myModel", "myKey", bar: 1
    fluxStore.onNextReady ->
      assert.eq count1, 1
      assert.eq count2, 1
      fluxStore.unsubscribe "myModel", "myKey", subscriber2
      fluxStore.update "myModel", "myKey", bar: 2
      fluxStore.onNextReady ->
        assert.eq count1, 2
        assert.eq count2, 1
        done()

  test "fluxStore model callbacks: fluxStoreEntryUpdated, fluxStoreEntryAdded, fluxStoreEntryRemoved", (done)->
    reset()
    updateCount = 0
    addedCount = 0
    removedCount = 0
    createWithPostCreate class MyModel2 extends FluxModel
      fluxStoreEntryUpdated:  (entry) -> updateCount++
      fluxStoreEntryAdded:    (entry) -> addedCount++
      fluxStoreEntryRemoved:  (entry) ->
        assert.eq 2, updateCount
        assert.eq 1, addedCount
        assert.eq 1, ++removedCount
        done()

    fluxStore.subscribe "myModel2", "myKey", mySubscription = -> 123
    fluxStore.onNextReady ->
      fluxStore.unsubscribe "myModel2", "myKey", mySubscription

  test "subscribe triggers load on model", (done) ->
    reset()
    class MyBasicModel extends FluxModel
      @register()

      load: (key) ->
        done()

    fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> null


  test "subscribe with initial value does not trigger load on model nor subscription callback", (done) ->
    reset()
    class MyBasicModel extends FluxModel
      @register()

      load: (key) ->
        assert.fail()

    fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
      assert.fail()
    , data: foo:1, bar:2
    fluxStore.onNextReady -> done()
