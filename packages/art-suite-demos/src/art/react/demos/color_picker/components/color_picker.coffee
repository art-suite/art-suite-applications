Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
ColorPreview = require './color_preview'
ColorPicker1d = require './color_picker_1d'
React = require 'art-react'
Flux = require 'art-flux'

{log, bound} = Foundation
{color} = Atomic
{
  Component, createComponentFactory
  Element, RectangleElement, TextElement, OutlineElement, CanvasElement
} = React

{FluxComponent} = Flux

module.exports = createComponentFactory class ColorPicker extends FluxComponent
  module: module

  render: ->
    {color} = @state
    Element null,
      RectangleElement color: "white"

      Element
        padding: 10
        childrenLayout: "column"
        ColorPreview()
        ColorPicker1d channel: "r", label: "red"
        ColorPicker1d channel: "g", label: "green"
        ColorPicker1d channel: "b", label: "blue"
        ColorPicker1d channel: "h", label: "hue"
        ColorPicker1d channel: "s", label: "saturation"
        ColorPicker1d channel: "l", label: "lightness"
