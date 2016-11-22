Foundation = require "art-foundation"
Demos = require "./demos"
Engine = require "art-engine"

{log, upperCamelCase, mergeInto} = Foundation
{FullScreenApp, Elements, Element, CanvasElement} = Engine
{RectangleElement, TextElement} = Elements

class LoaderButton extends Element
  constructor: (options)->
    mergeInto options,
      on:
        pointerDown: => @showWillActivate()
        pointerMoveOut: => @showWontActivate()
        pointerMoveIn: => @showWillActivate()
        pointerUpInside: => @showWontActivate();options.action?()
      margin: 10
      size: w:200, h:60
      cursor: "pointer"
      children: [
        @mainElement = new Element
          axis: .5
          location: ps: .5
          new RectangleElement color: "yellow"
          new TextElement
            size: ps: 1
            fontFamily: "sans-serif"
            align: "centerCenter"
            text: options.text || "Button"
      ]
    super

  showWillActivate: -> @mainElement.animate = duration: .1, to: scale: .95
  showWontActivate: -> @mainElement.animate = duration: .1, to: scale: 1

class Loader
  constructor: ->
    new CanvasElement
      canvasId: "artCanvas"
      new RectangleElement color: "#333"
      new Element
        childrenLayout: "flow"
        padding: 10
        for name, Demo of Demos.namespaces
          do (name, Demo) ->
            new LoaderButton
              text: name
              action: -> document.location = "?demo=#{name}"


FullScreenApp.init()
.then ->
  query = Foundation.parseQuery()
  demo = Demos[upperCamelCase query.demo || ""]

  if demo
    demo.Main()
  else
    new Loader()
