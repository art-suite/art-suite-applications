{
  log, max, modulo, round
  hslColor
  Component, createComponentFactory, createAndInstantiateTopComponent
  CanvasElement
  Element
  RectangleElement
  PagingScrollElement
  TextElement
  FluxComponent
  intRand
  arrayWith
  arrayWithoutValue
} = require 'art-suite'

StyleProps = require './StyleProps'

LineItem = createComponentFactory class LineItem extends FluxComponent
  module: module

  removeItem: ->
    log remove: @props.text
    @props.removeItem @props.text

  render: ->
    {text} = @props
    Element
      size: cs: 1
      margin: 5
      animators: size: toFromVoid: wcw:1, h: 0
      on: pointerClick: @removeItem
      clip: true
      RectangleElement color: StyleProps.palette.lightPrimaryBackground
      Element
        size: cs: 1
        padding: 20
        TextElement StyleProps.largeText, text: text

PseDemo = createComponentFactory class PseDemo extends FluxComponent
  module: module

  render: ->
    {alignment, items, removeItem} = @props

    Element
      margin: 10
      RectangleElement color: StyleProps.palette.primaryBackground

      PagingScrollElement
        childrenAlignment: alignment
        clip: true
        Element
          padding:  5
          size: ww:1, hch:1
          childrenLayout: "column"
          RectangleElement color: "#ff7", inFlow: false
          LineItem removeItem: removeItem, key: "Item:#{item}", text: item for item, i in items

SimpleButton = createComponentFactory class SimpleButton extends FluxComponent
  module: module
  pointerDown: -> @setState pointerDown: true
  pointerUp: -> @setState pointerDown: false

  pointerUpInside: -> @props.action?()

  render: ->
    {pointerDown} = @state
    {text} = @props
    Element
      on:
        pointerDown: @pointerDown
        pointerUp: @pointerUp
        pointerIn: @pointerDown
        pointerOut: @pointerUp
        pointerUpInside: @pointerUpInside
      size: cs: 1
      margin: 10
      RectangleElement StyleProps.buttonBackground pointerDown
      TextElement padding: 10, StyleProps.mediumText, text: text

module.exports = createComponentFactory class DynamicScroller extends FluxComponent
  module: module
  @stateFields
    alignment: "bottomLeft"
    items: ["Hello world!", "Hi!"]

  count = 1
  addItem: ->
    @items = arrayWith @items, "New line #{count++}"

  removeItem: (string) ->
    @items = arrayWithoutValue @items, string

  render: ->
    Element
      childrenLayout: "row"
      padding: 10
      RectangleElement padding: -10, inFlow: false, color: StyleProps.palette.grayBackground
      PseDemo @state, removeItem: @removeItem
      Element
        margin: 10
        childrenLayout: "flow"
        SimpleButton text: "add element", action: @addItem
