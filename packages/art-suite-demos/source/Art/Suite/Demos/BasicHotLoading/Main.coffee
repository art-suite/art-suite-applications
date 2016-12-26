{
  log
  pluralize
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
  defineModule
  point
  PointerActionsMixin
} = require "art-suite"

defineModule module, class BasicHotLoading extends PointerActionsMixin Component

  @stateFields toggled: false

  toggle: -> @toggled = !@toggled

  render: ->
    {_hotModuleReloadCount} = @state

    [text, color] = if @state.pointerIsDown
      ["and War", "red"]
    else
      ["Love", "pink"]

    hotText = if _hotModuleReloadCount > 0
      "hot reloaded #{pluralize _hotModuleReloadCount, 'time'}"
    else
      "edit Main.coffee, save, and watch the magic!"

    Element
      on: @buttonHandlers

      RectangleElement
        color:      color
        animators:  "color"

      TextElement
        key: text
        location: ps: .5
        animators:
          opacity:  toFromVoid: 0
          axis:     fromVoid: "centerRight", toVoid: "centerLeft"

        axis:     .5
        text:     text
        color:    "white"
        fontSize: 50

      TextElement
        key: hotText
        location: xw: .5, y: 5
        animators:
          opacity:  toFromVoid: 0
          axis:     fromVoid: "bottomCenter", toVoid: point .5, -1

        axis:     "topCenter"
        text:     hotText
        color:    "white"
        fontSize: 20
