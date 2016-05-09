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
        for demo in Demos.namespaces
          do (demo) ->
            new LoaderButton
              text: demo.name
              action: -> document.location = "?demo=#{demo.name}"


FullScreenApp.init()
.then ->
  query = Foundation.Browser.Parse.query()
  demo = Demos[upperCamelCase query.demo || ""]

  if demo
    demo.Main()
  else
    new Loader()
    console.log "invalid option: ?demo=#{query.demo}" if query.demo
    console.log "Select demo with:"
    for demo in Demos.namespaces
      console.log "  ?demo=#{demo.name}"
