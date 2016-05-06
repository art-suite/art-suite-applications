define [
  'art-foundation'
  'art-engine'
  'art-react'
], (Foundation, Engine, React) ->
  {log} = Foundation

  {createComponentFactory, VirtualNode, VirtualElement, Component, ReactArtEngineEpoch, Element} = React
  {reactArtEngineEpoch} = ReactArtEngineEpoch

  suite "Art.React.Main", ->
    test "Element virtual-Aim factory", ->
      a = Element {}
      assert.ok a.class.constructor instanceof VirtualElement.constructor
      assert.eq a.elementClassName, "Element"

    test "createComponentFactory spec...", ->
      c = createComponentFactory render: ->

      node = c {}
      assert.ok node instanceof Component
      assert.eq node.class.name, "AnonymousComponent"

    test "createComponentFactory class...", ->
      c = createComponentFactory class MyComponent extends Component
        foo:1

      node = c {}
      assert.eq node.class, MyComponent

    test "MyComponent()", ->
      MyComponent = createComponentFactory
        render: -> Element()

      c = MyComponent()
      assert.eq c.props, {}

    test "MyComponent() merges multiple props objects", ->
      MyComponent = createComponentFactory
        render: -> Element()

      c = MyComponent {a:1}, {b:2}
      assert.eq c.props, a:1, b: 2

    test "MyComponent() children mingled with props", ->
      MyComponent = createComponentFactory
        render: -> Element()

      c = MyComponent {a:1}, Element(name:"child1"), {b:2}, Element(name:"child2")
      assert.eq c.props.a, 1
      assert.eq c.props.b, 2
      assert.eq ["child1", "child2"], (c.props.name for c in c.props.children)

