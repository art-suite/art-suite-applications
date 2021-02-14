Foundation = require 'art-foundation'
Flux = require '@art-suite/art-flux'
React = require 'art-react'
{eq, log, Promise, timeout, createWithPostCreate, defineModule, formattedInspect, isString} = Foundation
{success, missing, pending} = Foundation.CommunicationStatus

{FluxStore, ModelRegistry, models, FluxModel, FluxComponent, fluxStore, ApplicationState} = Flux
{assert} = require 'art-testbench'

{Element} = React

resetAll = ->
  Flux._reset()

myModelSetup = ->
  resetAll()
  .then ->
    createWithPostCreate class MyModel extends ApplicationState
      @stateFields myField: {}, myField2: {}

defineModule module, suite:


  misc: ->
    setup myModelSetup
    teardown -> fluxStore.onNextReady()

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
        @subscriptions myModel: ({myModelId}) -> myModelId

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
        toKeyString: (key) -> "#{key.foo}:#{key.bar}"
        load: (key) -> data: key, status: success

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions
          myStructuredKeyModel: -> foo:123, bar:456

        render: ->
          resolve() if @myStructuredKeyModel == "123:456"
          Element()

      MyComponent()._instantiate()

    test "props value for subscription shows up for first render", -> new Promise (resolve, reject) ->
      class Post extends FluxModel
        @register()
        load: (key) -> data: key, status: success

      MyComponent = createWithPostCreate class MyComponent extends FluxComponent
        @subscriptions "post"

        render: ->
          if @post?.foo == "bar"
            resolve()
          else
            reject()
          Element()

      MyComponent(post: foo: "bar")._instantiate()
