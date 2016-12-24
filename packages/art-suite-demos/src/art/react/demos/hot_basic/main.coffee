{
  log
  pluralize
  createComponentFactory
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
  defineModule
  point
} = require "art-suite"

defineModule module, class MyComponent extends Component

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

      RectangleElement
        color: clr
        animators: "color"

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
