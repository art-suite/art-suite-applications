Foundation = require 'art-foundation'
Flux = require 'art-flux'
React = require 'art-react'
{log, Promise, timeout, createWithPostCreate} = Foundation
{success, missing} = Foundation.CommunicationStatus

{FluxStore, ModelRegistry, FluxModel, FluxComponent, createFluxComponentFactory, fluxStore} = Flux
{VolatileModel, VolatileStore} = Flux.Models
{volatileStore} = VolatileStore

{createComponentFactory, Element} = React

reset = ->
  fluxStore._reset()
  volatileStore._reset()
  ModelRegistry._reset()

suite "Art.Flux.React.FluxComponent", ->

  test "@subscriptions user: 'abc123'", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createFluxComponentFactory
      subscriptions:
        user: 'abc123'

      componentWillUpdate: (newProps, newState)->
        if newState.userStatus == success
          assert.eq newState.user, name:"bob", id:"abc123"
          done()

      render: -> Element {}

    myComponent = MyComponent()
    ._instantiate()
    assert.eq myComponent.state.userStatus, "pending"
    ModelRegistry.models.user.put "abc123", name:"bob"

  test "@subscriptions user: ->", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        user: (props) -> props.userId

      componentWillUpdate: (newProps, newState)->
        if newState.userStatus == success
          assert.eq newState.user, name:"bob", id:"abc123"
          done()

      render: -> Element {}

    myComponent = MyComponent userId:"abc123"
    ._instantiate()

    ModelRegistry.models.user.put "abc123", name:"bob"

  test "@subscriptions bob: model: 'user', id: 'abc123'", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        bob:
          model: 'user'
          key:   'abc123'

      componentWillUpdate: (newProps, newState)->
        if newState.bobStatus == success
          assert.eq newState.bob, name:"bob", id:"abc123"
          done()

      render: -> Element {}

    myComponent = MyComponent userId:"abc123"
    ._instantiate()

    ModelRegistry.models.user.put "abc123", name:"bob"

  test "@subscriptions abc123: model: 'user'", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        abc123: model: "user"

      componentWillUpdate: (newProps, newState)->
        if newState.abc123Status == success
          assert.eq newState.abc123, name:"bob", id:"abc123"
          done()

      render: -> Element {}

    myComponent = MyComponent userId:"abc123"
    ._instantiate()

    ModelRegistry.models.user.put "abc123", name:"bob"
  test "@subscriptions bob: model: ->, id: ->", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        bob:
          model: ({userModel}) -> userModel
          key:   ({userId}) -> userId

      componentWillUpdate: (newProps, newState)->
        if newState.bobStatus == success
          assert.eq newState.bob, name:"bob", id:"abc123"
          done()

      render: -> Element {}

    myComponent = MyComponent userId: "abc123", userModel: "user"
    ._instantiate()

    ModelRegistry.models.user.put "abc123", name: "bob"

  test "subscriptions - model with structured keys", (done)->
    reset()
    class MyStructuredKeyModel extends FluxModel
      @register()
      toFluxKey: (key) -> "#{key.foo}:#{key.bar}"
      load: (key) -> data: key, status: success

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        myStructuredKeyModel: -> foo:123, bar:456

      render: ->
        assert.eq @state.myStructuredKeyModel, "123:456"
        @onNextReady -> done()
        Element {}

    (myComponent = MyComponent())._instantiate()

  test "subscriptions - component with subscription to model with immediate result only renders once", (done)->
    reset()
    createWithPostCreate class MyModel extends FluxModel
      load: (key) -> data: key, status: success

    renderCount = 0
    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        myModel: -> "hi"

      render: ->
        renderCount++
        assert.eq renderCount, 1
        timeout 20, => done()
        Element {}

    (myComponent = MyComponent())._instantiate()

  test "subscription with initial value passed in as prop should not trigger load", (done)->
    reset()
    class User extends FluxModel
      @register()

      load: ->
        assert.fail()

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        user: (props) -> props.userId

      render: ->
        assert.eq @state.user, name:"george", id:"124"
        done()
        Element {}

    myComponent = MyComponent
      user: id:"124", name:"george"
    ._instantiate()
    assert.eq myComponent.state.userStatus, success

  test "subscriptions two fields with the same model", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        viewingUser: model: "user", key: "1"
        viewedUser:  model: "user", key: "2"

      componentWillUpdate: (newProps, newState)->
        if newState.viewingUserStatus == success && newState.viewedUserStatus == success
          assert.eq newState.viewingUser, name:"bill", id:"1"
          assert.eq newState.viewedUser,  name:"alice", id:"2"
          done()

      render: -> Element {}

    (myComponent = MyComponent())._instantiate()
    ModelRegistry.models.user.put "1", name:"bill"
    ModelRegistry.models.user.put "2", name:"alice"

  test "subscriptions - post - declarative subscriptions", (done)->
    reset()
    class User extends VolatileModel
      @fields name: {}

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        user: (props) -> props.userId

      componentWillUpdate: (newProps, newState)->
        if newState.userStatus == success
          assert.eq newState.user, name:"bob", id:"0"
          done()

      render: -> Element {}

    ModelRegistry.models.user.post name:"bob", (requestStatus)->
      if requestStatus.status != "pending"
        (myComponent = MyComponent userId:requestStatus.data.id)._instantiate()

  test "put", (done)->
    reset()
    class User extends VolatileModel
      @register()

    MyComponent = createComponentFactory class MyComponent extends FluxComponent

      putTest: ->
        @models.user.put "123", name: "bob", (requestStatus)->
          if requestStatus.status == success
            done()

      render: -> Element {}

    (myComponent = MyComponent())._instantiate()
    myComponent.putTest()

  test "subscribe - manual subscriptions", (done)->
    reset()

    class User extends FluxModel
      @register()
      load: (key) -> status: success

    class User extends VolatileModel
      @register()

    MyComponent = createComponentFactory class MyComponent extends FluxComponent

      getInitialState: ->
        user: @subscribe @models.user, "123", "user"

      componentWillUpdate: (newProps, newState)->
        if newState.userStatus == success
          assert.eq newState.user, name:"sally", id:"123"
          done()

      render: -> Element {}

    (myComponent = MyComponent())._instantiate()
    ModelRegistry.models.user.put "123", name:"sally"

  test "subscribe - changing subscriptions 0 to 123", (done)->
    reset()
    class User extends VolatileModel
      @register()

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        user: (props) -> props.userId

      componentWillUpdate: (newProps, newState)->
        if newState.userStatus == success
          assert.eq newState.user, name:"sally", id:"123"
          done()

      render: -> Element {}

    MyWrapperComponent = createComponentFactory
      getInitialState: -> userId: "0"
      render: -> MyComponent userId: @state.userId

    ModelRegistry.models.user.put "123", name:"sally"

    (myWrapperComponent = MyWrapperComponent())._instantiate()
    myWrapperComponent.onNextReady ->
      myWrapperComponent.setState userId: "123"

  test "subscribe - changing subscriptions to no subscription", (done)->
    reset()
    valuesWhen200 = []
    class User extends VolatileModel
      @register()

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        user: (props) -> props.userId

      componentWillUpdate: (newProps, newState)->
        if newState.userStatus == success
          @props.myUnsubscribe()
          valuesWhen200.push newState.user
          if valuesWhen200.length == 2
            assert.eq valuesWhen200, [{name:"sally", id:"123"}, undefined]
            done()

      render: -> Element {}

    MyWrapperComponent = createComponentFactory
      getInitialState: -> userId: "0"

      myUnsubscribe: -> @setState userId: null
      render: -> MyComponent userId: @state.userId, myUnsubscribe:@myUnsubscribe

    ModelRegistry.models.user.put "123", name:"sally"

    (myWrapperComponent = MyWrapperComponent())._instantiate()
    myWrapperComponent.onNextReady ->
      myWrapperComponent.setState userId: "123"

  test "post and subscribe", (done)->
    reset()
    class User extends VolatileModel
      @register()

    MyComponent = createComponentFactory class MyComponent extends FluxComponent

      postTest: ->
        @models.user.post name: "frank", (requestStatus) =>
          if id = requestStatus.data?.id
            @subscribe @models.user, id, "user"

      componentWillUpdate: (newProps, newState) ->
        if newState.userStatus == success
          assert.eq newState.user, name:"frank", id:"0"
          done()

      render: -> Element {}

    (myComponent = MyComponent())._instantiate()
    myComponent.postTest()

  test "query and subscribe", (done)->
    reset()
    class User extends VolatileModel
      @fields
        name: @fieldTypes.trimmedString
        email: @fieldTypes.email
      @query "email"

    MyComponent = createComponentFactory class MyComponent extends FluxComponent
      @subscriptions
        usersByEmail: -> "garry@yahoo.com"

      componentWillUpdate: (newProps, newState) ->
        if newState.usersByEmailStatus == success
          assert.eq newState.usersByEmail, [name:"garry", email:"garry@yahoo.com", id: "1"]
          done()

      render: -> Element {}

    promises = []
    for k, user of {
      a: name:"fred", email:"fred@gmail.com"
      b: name:"garry", email:"garry@yahoo.com"
      c: name:"frank", email:"frank@msn.com"
    }
      do (user) -> promises.push new Promise (done) -> ModelRegistry.models.user.post user, (statusRecord) ->
        done() if statusRecord.status != "pending"

    Promise.all promises
    .then (results) ->
      (myComponent = MyComponent())._instantiate()
