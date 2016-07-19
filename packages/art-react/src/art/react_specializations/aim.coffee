Foundation = require 'art-foundation'
React = require '../react'
{log, createObjectTreeFactories, mergeInto, createObjectTreeFactory} = Foundation
{VirtualElement, objectTreeFactoryOptions} = React
{getNextPageIndexes} = require "./paging_scroll_element"

standardArtEngineElementClassNames = "
  BitmapElement
  BlurElement
  CanvasElement
  ShapeElement
  Element
  FillElement
  OutlineElement
  PagingScrollElement
  RectangleElement
  ShadowElement
  TextElement
  TextInput
  "

module.exports = class Aim
  @createVirtualElementFactories: (VirtualElementClass, elementClassNames = standardArtEngineElementClassNames) ->
    mergeInto @, createObjectTreeFactories objectTreeFactoryOptions, elementClassNames, (elementClassName) ->
      (props, children) -> new VirtualElementClass elementClassName, props, children

    @bindHelperFunctions()
    @

  @bindHelperFunctions: ->
    @PagingScrollElement.getNextPageIndexes = getNextPageIndexes
