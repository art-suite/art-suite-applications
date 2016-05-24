Foundation = require 'art-foundation'
VirtualElement = require '../react/virtual_element'
{log, createObjectTreeFactories, mergeInto, createObjectTreeFactory} = Foundation
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
    mergeInto @, createObjectTreeFactories elementClassNames, (elementClassName) ->
      (props, children) -> new VirtualElementClass elementClassName, props, children

    @bindHelperFunctions()
    @

  @bindHelperFunctions: ->
    @PagingScrollElement.getNextPageIndexes = getNextPageIndexes
