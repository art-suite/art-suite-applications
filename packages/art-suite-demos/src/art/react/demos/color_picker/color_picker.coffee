{log, bound} = require 'art.foundation'
{color} = require 'art.atomic'
ColorPreview = require './color_preview'
ColorPicker1d = require './color_picker_1d'
{
  Component, createComponentFactory
  Element, Rectangle, TextElement, Outline, CanvasElement
} = require 'art.react'

module.exports = createComponentFactory class ColorPicker extends Component
  @hotModule: module

  # we maintain both the color and the individual channels
  # so we don't lose information in degenerate cases (like saturation or lightness == 0 or 1)
  getInitialState: ->
    color: color "#f00"
    r: 1
    g: 0
    b: 0
    h: 1
    s: 1
    l: 1

  setChannel: (channel, v)->
    c = @state.color.withChannel channel, v = bound 0, v, 1

    toSet = switch channel
      when "r", "g", "b" then h:c.h, s:c.s, l:c.l, color:c
      else r:c.r, g:c.g, b:c.b, color:c
    toSet[channel] = v

    @setState toSet

  render: ->
    clr = @state.color
    fgColor = if clr.perceptualLightness < .9 then "white" else "#0007"
    Element null,
      Rectangle color: "white"

      Element
        padding: 10
        childrenLayout: "column"
        ColorPreview  fgColor: fgColor, color: clr
        ColorPicker1d fgColor: fgColor, color: clr, value: @state.r, channel: "r", setChannel: @setChannel
        ColorPicker1d fgColor: fgColor, color: clr, value: @state.g, channel: "g", setChannel: @setChannel
        ColorPicker1d fgColor: fgColor, color: clr, value: @state.b, channel: "b", setChannel: @setChannel
        ColorPicker1d fgColor: fgColor, color: clr, value: @state.h, channel: "h", setChannel: @setChannel
        ColorPicker1d fgColor: fgColor, color: clr, value: @state.s, channel: "s", setChannel: @setChannel
        ColorPicker1d fgColor: fgColor, color: clr, value: @state.l, channel: "l", setChannel: @setChannel
