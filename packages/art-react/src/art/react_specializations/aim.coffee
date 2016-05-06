Foundation = require 'art-foundation'
VirtualElement = require '../react/virtual_element'
{log, createObjectTreeFactories} = Foundation

module.exports = Aim = createObjectTreeFactories "
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
  new VirtualElement elementClassName, props, children

{getNextPageIndexes} = require "./paging_scroll_element"
Aim.PagingScrollElement.getNextPageIndexes = getNextPageIndexes
