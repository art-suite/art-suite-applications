Foundation = require "art-foundation"
Engine = require 'art-engine'
React = require 'art-react'
Atomic = require 'art-atomic'
{PointerActionsMixin} = require 'art-react/mixins'

{defineModule, createWithPostCreate, upperCamelCase, lowerCamelCase, log} = Foundation
{point} = Atomic
{
  Component, createComponentFactory, createAndInstantiateTopComponent
  CanvasElement
  Element
  RectangleElement
  PagingScrollElement
  TextElement
} = React

Demos = require "./demos"

textStyle =
  fontFamily: "Helvetica"
  fontSize: 16
  color: "#fffc"

defineModule module, ->
  Engine.FullScreenApp.init
    title: "Art.React.Demos"
  .then ->
    DemoButton = createWithPostCreate class DemoButton extends PointerActionsMixin Component

      doAction: ->
        @props.selectDemo @props.name

      render: ->
        {pointerIsDown, hover} = @state
        {name} = @props
        Element
          size: ww:1, hch:1

          RectangleElement
            color: if hover then "#fff" else "#fff0"
            animators: "color"

          TextElement textStyle,
            size: ww:1, hch:1
            cursor: "pointer"
            color:    "#0007"
            text:     name
            padding: 10
            on: @buttonHandlers

    BackButton = createWithPostCreate class BackButton extends PointerActionsMixin Component

      render: ->
        {pointerIsDown, hover} = @state
        {name} = @props
        Element
          size: cs: 1
          clip: true
          animators: size: toFrom: hch:1, w: 0

          RectangleElement
            color: if hover then "#999" else "#555"
            animators: "color"
            radius: 5

          TextElement textStyle,
            size: cs: 1
            cursor: "pointer"
            text:     "back"
            padding: 10
            on: @getButtonHandlers @props.back

    createAndInstantiateTopComponent

      selectDemo: (name)-> @setState selectedDemo: name
      back: -> @setState selectedDemo: null

      render: ->
        {selectedDemo} = @state

        CanvasElement
          childrenLayout: "column"
          Element
            size: ww:1, h:50
            childrenLayout: "row"
            childrenAlignment: "centerLeft"
            RectangleElement inFlow: false, color: "#333", padding: -10
            padding: 10

            BackButton {@back} if selectedDemo

            TextElement textStyle,
              fontSize: 20
              margin:   10
              text:     if selectedDemo then selectedDemo else "art-react-demos"

          Element null,
            if selectedDemo
              Element
                key: "demo-#{selectedDemo}"
                clip: true
                animators: axis: toFrom: point -1, 0

                Demos[selectedDemo].Main()
            else

              Element
                key: "select-demo"
                childrenLayout: "column"
                animators: axis: toFrom: "topRight"

                RectangleElement inFlow: false, color: "#eee"
                for name in Demos.getNamespaceNames()
                  DemoButton {name, @selectDemo}

