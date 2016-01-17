{log} = Foundation = require "art.foundation"
{
  createAndInstantiateTopComponent
  CanvasElement
  Element
  Rectangle
  TextElement
} = require "art.react"

module.exports = ->
  createAndInstantiateTopComponent

    getInitialState: ->
      text: "Love"
      colors: ["white", "pink"]
      handlers:
        pointerDown: @pointerDown
        pointerUp:   @pointerUp

    pointerDown:  -> @setState text: "and War",  colors: ["white", "red"]
    pointerUp:    -> @setState text: "Love",     colors: ["white", "pink"]

    render: ->
      {text, handlers, colors} = @state
      CanvasElement
        canvasId: "artCanvas"
        on:       handlers

        Rectangle colors: colors

        TextElement
          location: ps: .5
          axis:     .5
          text:     text
          color:    "white"
          fontSize: 50
