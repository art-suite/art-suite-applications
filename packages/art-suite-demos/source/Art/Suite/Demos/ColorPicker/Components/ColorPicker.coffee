Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
ColorPreview = require './ColorPreview'
ColorPicker1d = require './ColorPicker1D'
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
