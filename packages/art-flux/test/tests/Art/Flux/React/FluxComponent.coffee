Foundation = require 'art-foundation'
Flux = require 'art-flux'
React = require 'art-react'
{eq, log, Promise, timeout, createWithPostCreate, defineModule, formattedInspect, isString} = Foundation
{success, missing, pending} = Foundation.CommunicationStatus

{FluxStore, ModelRegistry, models, FluxModel, FluxComponent, fluxStore, ApplicationState} = Flux

{Element} = React

myModelSetup = ->
  fluxStore._reset()
  ModelRegistry._reset()
  createWithPostCreate class MyModel extends ApplicationState
    @stateFields myField: {}, myField2: {}

defineModule module, suite:

  "subscriptions declaration types": ->
    setup myModelSetup

    testSubscriptionDefinition = (subDef, subField) ->
      subField ||= Object.keys(subDef)[0]

      statusField = "#{subField}Status"
      test "#{formattedInspect subDef}", ->
        new Promise (resolve) ->
          MyComponent = createWithPostCreate class MyComponent extends FluxComponent
            @subscriptions subDef

            componentWillUpdate: (newProps, newState)->
              if newState[statusField] == success
                assert.eq newState[subField], name:"bob"
                resolve()

            render: -> Element {}

          myComponent = MyComponent myModelId: "myField", myModelName: "myModel"
          ._instantiate()
          assert.eq myComponent.state[statusField], success
          models.myModel.myField = name:"bob"

    testSubscriptionDefinition myModel: 'myField'
    testSubscriptionDefinition bob: model: "myModel", key: "myField"
    testSubscriptionDefinition myField: model: 'myModel'

    testSubscriptionDefinition "myModel.myField", "myField"
    testSubscriptionDefinition "myModel", "myModel"

    testSubscriptionDefinition myModel: -> 'myField'
    testSubscriptionDefinition myModel: ({myModelId}) -> myModelId
    testSubscriptionDefinition bob:
      model: ({myModelName}) -> myModelName
      key:   ({myModelId}) -> myModelId

    test "two fields with the same model", ->
      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "myModel.myField myModel.myField2"

        componentWillUpdate: (newProps, newState)->
          if newState.myFieldStatus == success && newState.MyField2Status == success
            assert.eq newState.myField  , name:"bill"
            assert.eq newState.myField2 , name:"alice"
            done()

        render: -> Element {}

      (myComponent = MyComponent())._instantiate()
      models.myField  = name:"bill"
      models.myField2 = name:"alice"

  initialValues: ->
    setup myModelSetup

    test "subscriptions - component with subscription to model with immediate result only renders once", -> new Promise (resolve)->
      createWithPostCreate class MyModel extends FluxModel
        load: (key) -> data: key, status: success

      renderCount = 0
      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions
          myModel: -> "hi"

        render: ->
          renderCount++
          assert.eq renderCount, 1
          timeout 50, => resolve()
          Element {}

      (myComponent = MyComponent())._instantiate()

    test "subscription with initial value passed in as prop should not trigger load", -> new Promise (resolve)->
      createWithPostCreate class User extends FluxModel
        load: -> assert.fail()

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "user"

        render: ->
          assert.eq @state.user, name:"george", id:"124"
          timeout 50, => resolve()
          Element {}

      MyComponent(user: id:"124", name:"george")._instantiate()

    test "subscriptions - post - declarative subscriptions", -> new Promise (resolve) ->

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "myModel.myField"

        render: ->
          resolve() if @myField == "bob"
          Element {}

      models.myModel.myField = "bob"
      models.myModel.onNextReady -> MyComponent()._instantiate()

  getters: ->
    setup myModelSetup
    test "models getter", -> new Promise (resolve) ->

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "myModel.myField"

        test: -> @models.myModel.myField = "honor"

        render: ->
          resolve() if @state.myField == "honor"
          Element()

      MyComponent()._instantiate()
      .test()

    test "subscription field getters", -> new Promise (resolve) ->

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "myModel.myField"

        render: ->
          resolve() if @myField == "bob"
          Element {}

      MyComponent()._instantiate()
      models.myModel.myField = "bob"

  misc: ->
    setup myModelSetup

    test "manual subscriptions", -> new Promise (resolve) ->

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent

        getInitialState: ->
          user: @subscribe "mySubscriptionKey", "myModel", "myField", stateField: "myCustomStateField"

        render: ->
          resolve() if @state.myCustomStateField == "sally"
          Element()

      MyComponent()._instantiate()
      models.myModel.myField = "sally"

    test "changing subscription key updates subscription", -> new Promise (resolve) ->
      renderLog = []

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "myModel"

        render: ->
          renderLog.push @state.myModel
          resolve() if eq renderLog, ["george", "sally"]
          Element {}

      MyWrapperComponent = createWithPostCreate class MyWrapperComponent extends FluxComponent
        getInitialState: -> myModelId: "myField"
        render: -> MyComponent @state

      models.myModel.myField2 = "sally"
      models.myModel.myField = "george"

      (myWrapperComponent = MyWrapperComponent())._instantiate()
      myWrapperComponent.onNextReady -> myWrapperComponent.setState myModelId: "myField2"

    test "subscriptions with structured keys", -> new Promise (resolve) ->
      class MyStructuredKeyModel extends FluxModel
        @register()
        toFluxKey: (key) -> "#{key.foo}:#{key.bar}"
        load: (key) -> data: key, status: success

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions
          myStructuredKeyModel: -> foo:123, bar:456

        render: ->
          resolve() if @myStructuredKeyModel == "123:456"
          Element()

      MyComponent()._instantiate()
