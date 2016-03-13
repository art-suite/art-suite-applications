Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
ColorPreview = require './color_preview'
ColorPicker1d = require './color_picker_1d'
React = require 'art-react'
Flux = require 'art-flux'

{log, bound, wordsArray} = Foundation
{color} = Atomic
{
  Component, createComponentFactory
  Element, RectangleElement, TextElement, OutlineElement, CanvasElement
} = React

{FluxComponent} = Flux

channels = wordsArray "red green blue hue saturation lightness"

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
        ColorPicker1d channel: channel.slice(0, 1), label: channel for channel in channels
