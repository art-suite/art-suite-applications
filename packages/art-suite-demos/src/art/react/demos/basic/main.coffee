{log} = Foundation = require "art.foundation"
{
  createComponentFactory
  Component
  CanvasElement
  Element
  Rectangle
  TextElement
  arrayWithout
} = require "art.react"
{point} = require "art.atomic"

MyComponent = createComponentFactory class MyComponent extends Component
  @hotModule: module

  getInitialState: -> mode: "love"
  toggleMode: -> @setState mode: if @state.mode == "war" then "love" else "war"

  render: ->
    {handlers, mode, _hotModuleReloadCount} = @state
    {clr, text} = if mode == "love"
      text: "Love",     clr: "pink"
    else
      text: "and War",  clr: "red"

    CanvasElement
      canvasId: "artCanvas"
      on:
        pointerDown: @toggleMode
        pointerUp:   @toggleMode

      Rectangle color: "pink", animate: to: color: clr

      TextElement
        key: text
        location: ps: .5
        addedAnimation: from: opacity: 0, axis: point 1, .5
        removedAnimation: to: opacity: 0, axis: point 0, .5
        axis:     .5
        text:     text + " #{_hotModuleReloadCount || ""}"
        color:    "white"
        fontSize: 50

module.exports = ->
  MyComponent.instantiateAsTopComponent()
