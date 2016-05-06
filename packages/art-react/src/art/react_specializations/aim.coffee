Foundation = require 'art-foundation'
VirtualElement = require '../react/virtual_element'
{log, createObjectTreeFactories, mergeInto} = Foundation
{getNextPageIndexes} = require "./paging_scroll_element"

module.exports = class Aim
  @createVirtualElementFactories: (VirtualElementClass) ->
    mergeInto @, createObjectTreeFactories "
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
    , (elementClassName, props, children) ->
      new VirtualElementClass elementClassName, props, children

    @bindHelperFunctions()
    @

  @bindHelperFunctions: ->
    @PagingScrollElement.getNextPageIndexes = getNextPageIndexes
