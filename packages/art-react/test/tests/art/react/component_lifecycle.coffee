define [
  'extlib/chai'
  'art.foundation'
  'art.engine'
  'lib/art/react'
], (chai, Foundation, Engine, React) ->
  assert = chai.assert

  {StateEpoch} = Engine.Core
  {stateEpoch} = StateEpoch

  {createComponentFactory, Component, VirtualElement, Element, Rectangle} = React

  suite "Art.React.Component.LifeCycle", ->
    test "componentWillMount", (done)->
      rendered = false
      componentWillMounted = false
      MyComponent = createComponentFactory
        componentWillMount: ->
          componentWillMounted = true
          assert.eq rendered, false

        render: ->
          assert.eq componentWillMounted, true, "componentWillMounted should be true at this point"
          rendered = true
          done()
          Element name: "child"

      MyComponent().instantiateAsTopComponent root = new Engine.Elements.Element name: "root"

    test "componentDidMount", (done)->
      rendered = false
      componentDidMounted = false
      MyComponent = createComponentFactory
        componentDidMount: ->
          componentDidMounted = true
          assert.eq rendered, true
          assert.eq @element.rootElement, root
          done()

        render: ->
          assert.eq componentDidMounted, false, "componentDidMount should be false at this point"
          rendered = true
          Element name: "child"

      MyComponent().instantiateAsTopComponent root = new Engine.Elements.Element name: "root"

    test "componentWillUpdate", (done)->
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
            done()
          renderCount++
          Element name: @state.name

      mc = MyComponent().instantiateAsTopComponent root = new Engine.Elements.Element name: "root"
      React.onNextReady -> mc.setState name: "awesome child"

    test "componentDidUpdate", (done)->
      renderCount = 0
      componentDidUpdated = false
      MyComponent = createComponentFactory
        getInitialState: ->
          name: "child"

        componentDidUpdate: ->
          assert.eq renderCount, 2
          componentDidUpdated = true
          assert.eq @element.rootElement, root
          done()

        render: ->
          assert.eq componentDidUpdated, false, "componentWillUpdated should be false on the first render"
          renderCount++
          Element name: @state.name

      mc = MyComponent().instantiateAsTopComponent root = new Engine.Elements.Element name: "root"
      React.onNextReady -> mc.setState name: "awesome child"

    test "componentWillUnmount nested inside VirtualElement", (done)->
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
          done()

        render: ->
          assert.eq componentWillMounted, true, "componentWillMounted should be true at this point"
          assert.eq componentWillUnmounted, false, "componentWillUnmounted should be false at this point"
          rendered = true
          Element name: "child"

      wc = WrapperComponent().instantiateAsTopComponent root = new Engine.Elements.Element name: "root"
      React.onNextReady -> wc.setState includeComponent: false



