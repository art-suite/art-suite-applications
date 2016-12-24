{
  log
  Component
  Element
  RectangleElement
  TextElement
  defineModule
  PointerActionsMixin
} = require "art-suite"

defineModule module, class MyComponent extends PointerActionsMixin Component

  render: ->
    [text, color] = if @state.pointerIsDown
      ["and War", "red"]
    else
      ["Love", "pink"]

    Element
      on: @buttonHandlers

      RectangleElement
        color:      color
        animators:  "color"

      TextElement
        key:        text
        location:   ps: .5
        axis:       .5
        animators:  opacity: toFrom: 0
        text:       text
        color:      "white"
        fontSize:   50
