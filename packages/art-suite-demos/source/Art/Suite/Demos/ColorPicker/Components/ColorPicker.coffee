ColorPreview = require './ColorPreview'
ColorPicker1d = require './ColorPicker1D'

{
  log, bound, w
  Component,
  defineModule
  Element, RectangleElement, TextElement, OutlineElement, CanvasElement
  FluxComponent
} = require 'art-suite'

defineModule module, class ColorPicker extends FluxComponent

  channels = w "red green blue hue saturation lightness"

  render: ->
    {color} = @state
    Element null,
      RectangleElement color: "white"

      Element
        padding: 10
        childrenLayout: "column"
        ColorPreview()

        for channel in channels
          ColorPicker1d
            channel:  channel.slice 0, 1
            label:    channel
