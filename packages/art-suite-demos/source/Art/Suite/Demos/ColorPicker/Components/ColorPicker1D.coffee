{
  log
  defineModule
  Element, RectangleElement, Component, TextElement
  FluxComponent
} = require 'art-suite'

defineModule module, class ColorPicker1D extends FluxComponent

  @subscriptions "currentColor.color",
    currentColor: ({channel}) -> channel

  constructor: ->
    super
    @handlers =
      preprocess:
        pointerDown:  (e) => e.location.x
        pointerMove:  (e) => e.location.x
        ready:        (e) => e.target.currentSize.x

      pointerDown:  (x) => @setPosFromPixels x
      pointerMove:  (x) => @setPosFromPixels x
      ready:        (w) => @setState currentWidth:w

  @getter
    colors: ->
      {channel} = @props
      {color} = @state

      if channel == "h"
        color.withHue(h) for h in [0..1] by 1/6
      else
        [color.withChannel(channel, 0), color.withChannel(channel, 1)]

  setPosFromPixels: (pixels) ->
    {channel} = @props
    {currentWidth} = @state
    @models.currentColor.setChannel channel, pixels / currentWidth

  render: ->
    {channel, label} = @props
    value = @state.currentColor

    keyPrefix = "ColorPicker1D_#{channel}_"
    Element
      on: @handlers
      size: wpw:1, h:46
      margin: 10
      childrenLayout: "column"
      RectangleElement
        size: ww:1, h: 23
        key: "#{keyPrefix}background"
        to: "topRight"
        colors: @colors

      Element
        size: ww:1, h: 23
        RectangleElement color: "#eee"
        clip: true

        TextElement
          text: "▲"
          color: "#999"
          fontSize: 20
          layoutMode: "tight"
          key: "#{keyPrefix}handle"
          location: xw: value, yh:.5
          animators: location: duration: .1
          axis: .5

        TextElement
          fontFamily: "sans-serif"
          text: label
          size: hh:1, wcw:1
          padding: h:4
          align: "centerLeft"
          color: "#777"

        TextElement
          axis: "topRight"
          location: xw: 1
          fontFamily: "sans-serif"
          text: "#{value * 100 | 0}%"
          size: hh:1, wcw:1
          padding: h:4
          align: "centerLeft"
          color: "#777"
