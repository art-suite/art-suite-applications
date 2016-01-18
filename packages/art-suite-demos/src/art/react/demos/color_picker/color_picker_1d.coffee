{log} = require 'art.foundation'
{Element, Rectangle, Component, createComponentFactory} = require 'art.react'

module.exports = createComponentFactory class ColorPicker1D extends Component
  @hotModule: module
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
      {color, channel} = @props

      if channel == "h"
        color.withHue(h) for h in [0..1] by 1/6
      else
        [color.withChannel(channel, 0), color.withChannel(channel, 1)]

  setPosFromPixels: (pixels) ->
    {setChannel, channel} = @props
    {currentWidth} = @state
    setChannel channel, pixels / currentWidth

  render: ->
    {value, channel, fgColor} = @props
    keyPrefix = "ColorPicker1D_#{channel}_"
    Element
      on: @handlers
      size: wpw:1, h:55
      margin: 10
      clip: true
      Rectangle key: "#{keyPrefix}background", to: "topRight", colors: @colors
      Rectangle
        key: "#{keyPrefix}handle"
        location: xpw: value, yph:.5
        size: 20
        axis: .5
        radius: 100
        color: fgColor
