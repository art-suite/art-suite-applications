{log} = require 'art-foundation'
{point} = require 'art-atomic'
Engine = require('art-engine')
{StateEpoch} = Engine.Core
{stateEpoch} = StateEpoch

{createComponentFactory, VirtualElement, VirtualNode, Component, Element, RectangleElement} = require 'art-react'

module.exports = suite:
  basic: ->
    test "new VirtualElement from createVirtualElementFactory()", ->
      a = Element {}
      assert.ok a instanceof VirtualElement
      assert.eq a.elementClassName, "Element"
      assert.eq a.element, null

    test "Element()", ->
      a = Element()
      assert.ok a instanceof VirtualElement
      assert.eq a.elementClassName, "Element"
      assert.eq a.element, null

    test "VirtualElement with props", ->
      a = Element size: 123
      assert.eq a.props, size: 123

    test "VirtualElement merges 2 or more property sets", ->
      a = Element {a:1}, {b:2}
      assert.eq a.props, a:1, b:2

    test "VirtualElement with children", ->
      a = Element
        name: "parent"
        Element name: "child1"
        Element name: "child2"

      assert.eq ["child1", "child2"], (child.props.name for child in a.children)

    test "VirtualElement with structured children", ->
      a = Element
        name: "parent"
        if false
          Element name: "child1"
        Element name: "child2"
        [
          null
          Element name: "child3"
          false
          Element name: "child4"
        ]

      assert.eq ["child2", "child3", "child4"], (child.props.name for child in a.children)

    test "VirtualElement with intermingled props and children", ->
      a = Element
        a:1
        Element name: "child1"
        b:2
        Element name: "child2"

      assert.eq a.props, a:1, b:2
      assert.eq ["child1", "child2"], (child.props.name for child in a.children)

  instantiate: ->
    test "instantiate VirtualElement with props", ->
      a = Element size: 123
      a._instantiate {}
      assert.ok a.element instanceof Engine.Core.Element

      stateEpoch.onNextReady ->
        assert.eq a.element.currentSize, point 123


    test "instantiate VirtualElement with children", ->
      a = Element
        name: "parent"
        Element name: "child1"
        Element name: "child2"
      a._instantiate {}

      stateEpoch.onNextReady ->
        assert.eq ["child1", "child2"], (child.name for child in a.element.children)


  _canUpdateFrom: ->
    test "_canUpdateFrom matching elementClasses == true", ->
      a = Element name: "foo"
      b = Element name: "bar"
      assert.eq true, a._canUpdateFrom b

    test "_canUpdateFrom missmatched elementClasses == false", ->
      a = Element name: "foo"
      b = RectangleElement name: "bar"
      assert.eq false, a._canUpdateFrom b

    test "_canUpdateFrom missmatched keys == false", ->
      a = Element key: "foo"
      b = Element key: "bar"
      assert.eq false, a._canUpdateFrom b

  _updateFrom: ->
    test "_updateFrom changed props", ->
      a = Element name: "foo"
      b = Element name: "bar"

      a._instantiate {}
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq a.element.name, "bar"


    test "_updateFrom: same children reuses children's array and children's VitualElement instances", ->
      a = Element
        name: "foo"
        Element name: "child1"
        Element name: "child2"
      b = Element
        name: "bar"
        Element name: "child1"
        Element name: "child2"

      a._instantiate {}
      initialelements = (child.element for child in a.children)
      initialChildren = a.children
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq a.element.name, "bar"
        assert.ok initialChildren == a.children
        assert.eq initialelements, (child.element for child in a.children)
        assert.eq ["child1", "child2"], (child.props.name for child in a.children)


    test "_updateFrom: children with only props changed reuses children's array and children's VitualElement instances", ->
      a = Element
        name: "foo"
        Element name: "child1"
        Element name: "child2"
      b = Element
        name: "bar"
        Element name: "child3"
        Element name: "child4"

      a._instantiate {}
      initialelements = (child.element for child in a.children)
      initialChildren = a.children
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq a.element.name, "bar"
        assert.ok initialChildren == a.children
        assert.eq initialelements, (child.element for child in a.children)
        assert.eq ["child3", "child4"], (child.props.name for child in a.children)


    test "_updateFrom: children with keys can reuse with swapped order", ->
      a = Element
        name: "foo"
        Element key: "child1"
        Element key: "child2"
      b = Element
        name: "bar"
        Element key: "child2"
        Element key: "child1"

      a._instantiate {}
      [element1, element2] = (child.element for child in a.children)
      initialChildren = a.children
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq a.element.name, "bar"
        assert.ok initialChildren != a.children
        assert.eq initialChildren.length, a.children.length
        assert.eq [element2, element1], (child.element for child in a.children)
        assert.eq ["child2", "child1"], (child.props.key for child in a.children)


    test "_updateFrom: children without keys and same type won't swap order", ->
      a = Element
        name: "foo"
        Element name: "child1"
        Element name: "child2"
      b = Element
        name: "bar"
        Element name: "child2"
        Element name: "child1"

      a._instantiate {}
      [element1, element2] = (child.element for child in a.children)
      initialChildren = a.children
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq a.element.name, "bar"
        assert.ok initialChildren == a.children
        assert.eq initialChildren.length, a.children.length
        assert.eq [element1, element2], (child.element for child in a.children)
        assert.eq ["child2", "child1"], (child.props.name for child in a.children)


    test "_updateFrom: children without keys but different types can swap order", ->
      a = Element
        name: "foo"
        Element name: "child1"
        RectangleElement name: "child2"
      b = Element
        name: "bar"
        RectangleElement name: "child2"
        Element name: "child1"

      a._instantiate {}
      [element1, element2] = (child.element for child in a.children)
      initialChildren = a.children
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq a.element.name, "bar"
        assert.ok initialChildren != a.children
        assert.eq initialChildren.length, a.children.length
        assert.eq [element2, element1], (child.element for child in a.children)
        assert.eq ["child2", "child1"], (child.props.name for child in a.children)


    test "_updateFrom: add child", ->
      a = Element
        name: "foo"
        Element name: "child1"
      b = Element
        name: "bar"
        Element name: "child1"
        Element name: "child2"

      a._instantiate {}
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq ["child1", "child2"], (child.props.name for child in a.children)



    test "_updateFrom: remove child", ->
      a = Element
        name: "foo"
        Element name: "child1"
        Element name: "child2"
        Element name: "child3"
      b = Element
        name: "bar"
        Element name: "child1"
        Element name: "child3"

      a._instantiate {}
      a._updateFrom b
      stateEpoch.onNextReady ->
        assert.eq ["child1", "child3"], (child.props.name for child in a.children)


