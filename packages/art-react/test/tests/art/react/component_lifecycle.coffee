Foundation = require 'art-foundation'
Engine = require 'art-engine'
React = require 'art-react'

{log, merge, clone} = Foundation
{createComponentFactory, Component, VirtualElement, Element, RectangleElement} = React

suite "Art.React.Component.lifeCycle", ->
  test "componentWillMount", ->
    new Promise (resolve) ->
      rendered = false
      componentWillMounted = false
      MyComponent = createComponentFactory
        componentWillMount: ->
          componentWillMounted = true
          assert.eq rendered, false

        render: ->
          assert.eq componentWillMounted, true, "componentWillMounted should be true at this point"
          rendered = true
          resolve()
          Element name: "child"

      MyComponent().instantiateAsTopComponent root = new Engine.Core.Element name: "root"

  test "componentDidMount", ->
    new Promise (resolve) ->
      rendered = false
      componentDidMounted = false
      MyComponent = createComponentFactory
        componentDidMount: ->
          componentDidMounted = true
          assert.eq rendered, true
          assert.eq @element.rootElement, root
          resolve()

        render: ->
          assert.eq componentDidMounted, false, "componentDidMount should be false at this point"
          rendered = true
          Element name: "child"

      MyComponent().instantiateAsTopComponent root = new Engine.Core.Element name: "root"

  test "componentWillUpdate", ->
    new Promise (resolve) ->
      renderCount = 0
      componentWillUpdated = false
      MyComponent = createComponentFactory
        getInitialState: ->
          name: "child"

        componentWillUpdate: (newProps, newState)->
          assert.eq renderCount, 1
          componentWillUpdated = true
          assert.neq @state.name, newState.name
          assert.eq @element.rootElement, root

        render: ->
          if renderCount == 0
            assert.eq componentWillUpdated, false, "componentWillUpdated should be false on the first render"
          else
            assert.eq componentWillUpdated, true, "componentWillUpdated should be true on the second render"
            resolve()
          renderCount++
          Element name: @state.name

      mc = MyComponent().instantiateAsTopComponent root = new Engine.Core.Element name: "root"
      React.onNextReady -> mc.setState name: "awesome child"

  test "componentDidUpdate", ->
    new Promise (resolve) ->
      renderCount = 0
      componentDidUpdated = false
      MyComponent = createComponentFactory
        getInitialState: ->
          name: "child"

        componentDidUpdate: ->
          assert.eq renderCount, 2
          componentDidUpdated = true
          assert.eq @element.rootElement, root
          resolve()

        render: ->
          assert.eq componentDidUpdated, false, "componentWillUpdated should be false on the first render"
          renderCount++
          Element name: @state.name

      mc = MyComponent().instantiateAsTopComponent root = new Engine.Core.Element name: "root"
      React.onNextReady -> mc.setState name: "awesome child"

  test "componentWillUnmount nested inside VirtualElement", ->
    new Promise (resolve) ->
      rendered = false
      altRendered = false
      componentWillMounted = false
      componentWillUnmounted = false

      WrapperComponent = createComponentFactory
        getInitialState: ->
          includeComponent: true

        render: ->
          Element
            name:"wrapper"
            if @state.includeComponent
              MyComponent()
            else
              assert.eq rendered, true, "rendered should be true at this point"
              assert.eq componentWillMounted, true, "componentWillMounted should be true at this point"
              assert.eq componentWillUnmounted, false, "componentWillUnmounted should be false at this point"
              altRendered = true
              Element name: "stub"

      MyComponent = createComponentFactory
        componentWillMount: ->
          assert.eq componentWillUnmounted, false, "componentWillUnmounted should be false at this point"
          assert.eq rendered, false, "rendered should be false at this point"
          componentWillMounted = true

        componentWillUnmount: ->
          assert.eq rendered, true, "rendered should be true at this point"
          assert.eq componentWillMounted, true, "componentWillMounted should be true at this point"
          assert.eq altRendered, true, "altRendered should be true at this point"
          componentWillUnmounted = true
          resolve()

        render: ->
          assert.eq componentWillMounted, true, "componentWillMounted should be true at this point"
          assert.eq componentWillUnmounted, false, "componentWillUnmounted should be false at this point"
          rendered = true
          Element name: "child"

      wc = WrapperComponent().instantiateAsTopComponent root = new Engine.Core.Element name: "root"
      React.onNextReady -> wc.setState includeComponent: false

suite "Art.React.Component.lifeCycle.preprocessProps", ->
  test "instantiate with preprocessProps", ->
    class MyComponent extends Component
      preprocessProps: (props) -> name:"Hi #{props.name || "John Doe"}!"
      render: ->
        Element name: @props.name

    c = new MyComponent name: "Sally"
    assert.eq c.state, {}
    c._instantiate()
    assert.eq c.element.class, Engine.Core.Element
    assert.eq c.element.pendingName, "Hi Sally!"

  test "_updateFrom with preprocessProps", ->
    class MyComponent1 extends Component
      preprocessProps: (props) -> name:"Hi #{props.name || "John Doe"}!"
      render: -> Element name: @props.name

    (a = new MyComponent1 name: "foo")._instantiate()
    b = new MyComponent1 name: "bar"
    a._updateFrom b
    assert.eq a.props.name, "Hi bar!"

suite "Art.React.Component.lifeCycle.preprocessState", ->
  test "instantiate with preprocessState", ->
    new Promise (resolve) ->
      class MyComponent extends Component
        getInitialState: -> name: @props.name
        preprocessState: (state) -> merge state, greeting: "Hi #{state.name}!"
        render: ->
          assert.eq @state.greeting, "Hi Sally!"
          resolve()
          Element()

      c = new MyComponent name: "Sally"
      c._instantiate()

  test "preprocessState after preprocessProps", ->
    new Promise (resolve) ->
      class MyComponent extends Component
        preprocessProps: ({name})-> @setState name: name
        preprocessState: (state) ->
          assert.neq state.name, @state.name
          merge state, greeting: "Hi #{state.name}!"
        render: ->
          assert.eq @state.greeting, "Hi Sally!"
          resolve()
          Element()

      c = new MyComponent name: "Sally"
      c._instantiate()

  test "_updateFrom with preprocessState", ->
    new Promise (resolve) ->
      class MyComponent extends Component
        getInitialState: -> initialName: @props.name
        preprocessState: (state) ->
          log preprocessState: state:state, props:@props
          merge state, greeting: "Hi #{@props.name}!"
        render: ->
          assert.eq @state.greeting, "Hi #{@props.name}!"
          resolve() if @state.greeting == "Hi John!" && @state.initialName == "Sally"
          Element()

      c1 = new MyComponent name: "Sally"
      c2 = new MyComponent name: "John"
      c1._instantiate()
      c1.onNextReady ->
        c1._updateFrom c2


