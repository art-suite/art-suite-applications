{log, merge, CommunicationStatus, createWithPostCreate} = require 'art-foundation'
{Core:{FluxStore, FluxModel, ModelRegistry}} = require 'art-flux'
{fluxStore} = FluxStore
{success, missing, pending} = CommunicationStatus

reset = ->
  fluxStore._reset()
  ModelRegistry._reset()
  createWithPostCreate class MyModel extends FluxModel

module.exports = suite: ->
  test "fluxStore.reset & length", ->
    reset()
    assert.eq fluxStore.length, 0

  test "fluxStore.update basic", ->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 1
      assert.eq fluxStore.get("myModel", "myKey"), status: pending, bar: 1, key: "myKey", modelName: "myModel"


  test "fluxStore.update with no subscriber is noop", ->
    reset()
    fluxStore.update "myModel", "myKey", bar:1

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 0
      assert.eq !!fluxStore._getEntry("myModel", "myKey"), false


  test "fluxStore.update twice replaces old value", ->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1
    fluxStore.update "myModel", "myKey", baz:2

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 1
      assert.eq fluxStore.get("myModel", "myKey"), status: pending, baz: 2, key: "myKey", modelName: "myModel"


  test "fluxStore.getHasSubscribers", ->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    assert.eq false, fluxStore.getHasSubscribers "myModel", "myKey"
    assert.eq false, fluxStore.getHasSubscribers "myModel", "myKey"

    fluxStore.onNextReady ->
      assert.eq true, fluxStore.getHasSubscribers "myModel", "myKey"


  test "fluxStore.update with update function can merge", ->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1
    fluxStore.update "myModel", "myKey", (old) -> merge old, baz:2

    fluxStore.onNextReady ->
      assert.eq fluxStore.length, 1
      assert.eq fluxStore.get("myModel", "myKey"), status: pending, bar:1, baz: 2, key: "myKey", modelName: "myModel"


  test "fluxStore.update cant set key", ->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1, key: "boggle"

    fluxStore.onNextReady ->
      assert.eq fluxStore.get("myModel", "myKey"), status: pending, bar: 1, key: "myKey", modelName: "myModel"


  test "fluxStore.update cant update key", ->
    reset()
    fluxStore.subscribe "myModel", "myKey", -> # required to make the record persist
    fluxStore.update "myModel", "myKey", bar:1

    fluxStore.onNextReady ->
      fluxStore.update "myModel", "myKey", bar:1, key: "boggle2"

      fluxStore.onNextReady ->
        assert.eq fluxStore.get("myModel", "myKey"), status: pending, bar: 1, key: "myKey", modelName: "myModel"


  test "fluxStore.subscribe basic", ->
    new Promise (resolve) ->

      reset()

      fluxStore.subscribe "myModel", "myKey", (fluxRecord, previousFluxRecord) ->
        assert.eq previousFluxRecord, status: missing, key: "myKey", modelName: "myModel"
        assert.eq fluxRecord, status: pending, bar: 1, key: "myKey", modelName: "myModel"
        resolve()

      fluxStore.update "myModel", "myKey", bar: 1

  test "fluxStore.unsubscribe", ->
    reset()
    count1 = 0
    count2 = 0
    subscriber1 = (fluxRecord) -> count1++
    subscriber2 = (fluxRecord) -> count2++

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


  test "fluxStore model callbacks: fluxStoreEntryUpdated, fluxStoreEntryAdded, fluxStoreEntryRemoved", ->
    new Promise (resolve) ->
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
          resolve()

      fluxStore.subscribe "myModel2", "myKey", mySubscription = -> 123
      fluxStore.onNextReady ->
        fluxStore.unsubscribe "myModel2", "myKey", mySubscription

  test "subscribe triggers load on model", ->
    new Promise (resolve) ->
      reset()
      class MyBasicModel extends FluxModel
        @register()

        load: resolve

      fluxStore.subscribe "myBasicModel", "123", (fluxRecord) -> null


  test "subscribe with initial value does not trigger load on model nor subscription callback", ->
    reset()
    class MyBasicModel extends FluxModel
      @register()

      load: (key) ->
        assert.fail()

    fluxStore.subscribe "myBasicModel", "123", (fluxRecord) ->
      assert.fail()
    , data: foo:1, bar:2
    fluxStore.onNextReady ->
