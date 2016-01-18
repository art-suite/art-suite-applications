{upperCamelCase, lowerCamelCase} = Foundation = require "art.foundation"
{
  Component, createComponentFactory, createAndInstantiateTopComponent
  CanvasElement
  Element
  Rectangle
  PagingScrollElement
  TextElement
} = require 'art.react'
{point} = require 'art.atomic'

Demos = require "./demos"

require "art.engine/full_screen_app"
.then ->
  query = Foundation.Browser.Parse.query()
  demo = Demos[upperCamelCase query.demo || ""]

  DemoButton = createComponentFactory
    # hotModule: module

    selectDemo: ->
      @props.selectDemo @props.name

    render: ->
      {name} = @props
      TextElement
        fontFamily: "Helvetica"
        color:    "#0007"
        text:     name
        padding: 10
        on: pointerClick: @selectDemo

  createAndInstantiateTopComponent
    hotModule: module

    selectDemo: (name)->
      @setState selectedDemo: name

    deselectDemo: ->
      @setState selectedDemo: null

    render: ->
      {selectedDemo} = @state

      CanvasElement
        canvasId: "artCanvas"
        childrenLayout: "column"

        # Demos.PagingScrollElement.Main()

        Element
          size: ww:1, h:50
          childrenLayout: "row"
          childrenAlignment: "centerLeft"
          Rectangle inFlow: false, color: "#333", padding: -10
          padding: 10
          selectedDemo &&
            Element
              size: cs: 1
              Rectangle color: "#555", radius: 5
              on: pointerClick: @deselectDemo
              TextElement
                color:    "#fffc"
                text:     "back"
                fontSize: 16
                fontFamily: "Helvetica"
                margin: 10
                padding: h:10, v:5

          TextElement
            color:    "#fffc"
            text:     if selectedDemo then selectedDemo else "art.react.demos"
            fontSize: 20
            fontFamily: "Helvetica"
            margin: 10

        Element null,
          if selectedDemo
            Element
              key: "demo-#{selectedDemo}"
              clip: true
              addedAnimation: from: axis: point -1, 0
              removedAnimation: to: axis: point -1, 0

              Demos[selectedDemo].Main()
          else

            Element
              key: "select-demo"
              childrenLayout: "column"
              addedAnimation: from: axis: "topRight"
              removedAnimation: to: axis: "topRight"
              Rectangle inFlow: false, color: "#eee"
              for demo in Demos.namespaces
                DemoButton name:demo.name, selectDemo:@selectDemo

