Foundation = require 'art-foundation'
Flux = require 'art-flux'
{merge, log, isString, Promise, BaseObject, Epoch, timeout, createWithPostCreate, CommunicationStatus, timeout} = Foundation

{models, FluxModel, fluxStore, ModelRegistry, FluxSubscriptionsMixin, ApplicationState} = Flux
{success, failure, missing, pending} = CommunicationStatus

reset = -> Flux._reset()

module.exports = suite:
  subscribe: ->
    setup reset
    test "with modelName and stateField", ->
      new Promise (resolve, reject) ->
        createWithPostCreate class MyModel extends ApplicationState
          ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

        myObject = new class MyObject extends FluxSubscriptionsMixin BaseObject

          setState: (key, value) ->
            resolve() if key == "myStateField" && value == "hi"

          constructor: ->
            super
            @subscribe "mySubscriptionKey", "myModel", "myFluxKey", stateField: "myStateField"

        assert.hasKeys myObject.subscriptions

        timeout()
        .then -> models.myModel.setState "myFluxKey", "hi"

    test "with fluxKey = null means dont subscribe", ->
      createWithPostCreate class MyModel extends ApplicationState
        ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

      myObject = new class MyObject extends FluxSubscriptionsMixin BaseObject

        constructor: ->
          super
          @subscribe "mySubscriptionKey", "myModel", null, stateField: "myStateField"

      assert.hasNoKeys myObject.subscriptions

  "subscribe and initialFluxRecord": ->
    setup reset

    test "with stateField and initialFluxRecord", ->
      createWithPostCreate class MyModel extends ApplicationState
        ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

      new class MyObject extends FluxSubscriptionsMixin BaseObject

        setState: (key, value) ->
          resolve() if key == "myStateField" && value == "hi"

        constructor: ->
          super
          @subscribe "mySubscriptionKey", "myModel", "myFluxKey",
            initialFluxRecord: data: "myInitialData"
            stateField: "myStateField"

      assert.eq
        status:     pending
        data:       "myInitialData"
        key:        "myFluxKey"
        modelName:  "myModel"
        fluxStore.get "myModel", "myFluxKey"

    test "with stateField and no initialFluxRecord", ->
      createWithPostCreate class MyModel extends ApplicationState
        ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

      new class MyObject extends FluxSubscriptionsMixin BaseObject

        setState: (key, value) ->
          resolve() if key == "myStateField" && value == "hi"

        constructor: ->
          super
          @subscribe "mySubscriptionKey", "myModel", "myFluxKey",
            stateField: "myStateField"

      assert.eq
        status:     missing
        key:        "myFluxKey"
        modelName:  "myModel"
        fluxStore.get "myModel", "myFluxKey"

  change: ->
    setup reset

    test "change subscription", ->
      new Promise (resolve, reject) ->
        createWithPostCreate class MyModel extends ApplicationState
          ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

        myObject = new class MyObject extends FluxSubscriptionsMixin BaseObject

          setState: (key, value) ->
            if key == "myStateField" && value
              if value == "hi"
                resolve()
              else
                reject wrongSetState: {key, value}

          constructor: ->
            super
            @subscribe "mySubscriptionKey", "myModel", "myFluxKey", stateField: "myStateField"

        timeout()
        .then ->
          # change the subscription
          myObject.subscribe "mySubscriptionKey", "myModel", "myFluxKey2", stateField: "myStateField"

        .then ->
          # should be ignored if properly not listening to old key
          models.myModel.setState "myFluxKey", "oops, still listening to old key"

          # should trigger updates, if properly listening to new key
          models.myModel.setState "myFluxKey2", "hi"

  unsubscribe: ->
    setup reset

    test "unsubscribe", ->
      new Promise (resolve, reject) ->
        createWithPostCreate class MyModel extends ApplicationState
          ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

        myObject = new class MyObject extends FluxSubscriptionsMixin BaseObject

          setState: (key, value) ->
            if key == "myStateField" && value
              if value == "hi"
                resolve()
              else
                log "reject"
                reject wrongSetState: {key, value}

          constructor: ->
            super
            @subscribe "mySubscriptionKey", "myModel", "myFluxKey", stateField: "myStateField"

        timeout()
        .then ->
          # comment this out and test should fail
          myObject.unsubscribe "mySubscriptionKey"

          # should be ignored if properly not listening to old key
          models.myModel.setState "myFluxKey", "oops, still listening to old key"

          timeout 10 # not the best method to give the setState-reject a chance to fire before resolving, can anyone think of a better way?
        .then ->
          log "resolve"
          resolve()

    test "unsubscribeAll", ->
      new Promise (resolve, reject) ->
        createWithPostCreate class MyModel extends ApplicationState
          ; # WTF CoffeeScript?!? - don't delete this line, it breaks stuff

        myObject = new class MyObject extends FluxSubscriptionsMixin BaseObject

          setState: (key, value) ->
            if key == "myStateField" && value
              if value == "hi"
                resolve()
              else
                log "reject"
                reject wrongSetState: {key, value}

          constructor: ->
            super
            @subscribe "mySubscriptionKey", "myModel", "myFluxKey", stateField: "myStateField"

        timeout()
        .then ->
          # comment this out and test should fail
          myObject.unsubscribeAll()

          # should be ignored if properly not listening to old key
          models.myModel.setState "myFluxKey", "oops, still listening to old key"

          timeout 10 # not the best method to give the setState-reject a chance to fire before resolving, can anyone think of a better way?
        .then ->
          log "resolve"
          resolve()


  extras: ->

    test "subscribeOnModelRegistered", ->
      new Promise (resolve, reject) ->
        createWithPostCreate class MyModelA extends FluxSubscriptionsMixin FluxModel
          constructor: ->
            super
            @subscribeOnModelRegistered "mySubscriptionKey", "myModelB", "myFluxKey", (updatesCallback: ->)
            .then resolve, reject

        createWithPostCreate class MyModelB extends FluxModel

