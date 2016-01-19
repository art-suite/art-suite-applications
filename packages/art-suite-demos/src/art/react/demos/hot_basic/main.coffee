{log, pluralize} = Foundation = require "art-foundation"
{
  createComponentFactory
  Component
  CanvasElement
  Element
  Rectangle
  TextElement
  arrayWithout
} = require "art-react"
{point} = require "art-atomic"

module.exports = createComponentFactory class MyComponent extends Component
  @hotModule: module

  getInitialState: -> toggled: false
  toggle: -> @setState toggled: !@state.toggled

  render: ->
    {toggled, _hotModuleReloadCount} = @state
    [text, clr] = if toggled
      ["and War", "red"]
    else
      ["Love", "pink"]

    hotText = if _hotModuleReloadCount > 0
      "hot reloaded #{pluralize _hotModuleReloadCount, 'time'}"
    else
      "edit hot_basic/main.coffee, save, and watch the magic!"

    Element
      on:
        pointerDown: @toggle
        pointerUp:   @toggle

      Rectangle color: "pink", animate: to: color: clr

      TextElement
        key: text
        location: ps: .5
        addedAnimation: from: opacity: 0, axis: "centerRight"
        removedAnimation: to: opacity: 0, axis: "centerLeft"
        axis:     .5
        text:     text
        color:    "white"
        fontSize: 50

      TextElement
        key: hotText
        location: xw: .5, y: 5
        addedAnimation: from: opacity: 0, axis: "bottomCenter"
        removedAnimation: to: opacity: 0, axis: point .5, -1
        axis:     "topCenter"
        text:     hotText
        color:    "white"
        fontSize: 20
