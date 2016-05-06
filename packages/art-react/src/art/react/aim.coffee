Foundation = require 'art-foundation'
VirtualElement = require './virtual_element'
{log} = Foundation

{createVirtualElementFactory} = VirtualElement
classForElement = if ArtEngineCore = Neptune.Art.Engine.Core
  {elementFactory} = ArtEngineCore.ElementFactory
  (e) ->
    unless klass = elementFactory.classForElement e
      console.error "Could not find Class for Element: #{e}"
    klass
else
  (e) -> e

elementClassNames = "
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
  ".split /\s+/

module.exports = class Aim
  @addElement: (elementClassName) ->
    Aim[elementClassName] ||= createVirtualElementFactory classForElement elementClassName

Aim.addElement elementClassName for elementClassName in elementClassNames

###
SBD: I'm not sure where best to put getNextPageIndexes, so I'm putting it here for now.
It is potentially needed by any react component using PagingScrollElement. I'd put it on the
actual PagingScrollElement Element class, but that class isn't loaded when doing React in
a web-worker.

getNextPageIndexes could be reusable with any PagingScrollElement where pages are indexed
and the maxPageIndex and minPageIndex are known. It's even OK if maxPageIndex and
minPageIndex change - as long as they don't change too much per frame.

IN:
  lastPageIndexes =
      firstPageIndex: 0
      lastPageIndex:  2

    essentially, this is the output from last call. For the first call, do 0 and 2

  currentGeometry =
      suggestedPagesBeforeFocusedPage: 1
      suggestedPagesAfterFocusedPage:  1

    set from currentGeometry from the last onScollChange event

  focusedPageIndex = integer;       the current focused page index
  maxKeep =          integer >= 0;  see below
  maxPrerender =     integer >= 0;  see below
  maxPageIndex =     integer;       see below
  minPageIndex =     0 (integer);   see below

OUT:
  null if nothing changed, else, returns the next range of pages to render for PagingScrollElement:
    firstPageIndex: integer
    lastPageIndex:  integer

Supports:
  minPageIndex / maxPageIndex: output page indexes will be: minPageIndex <= output page index <= maxPageIndex
  maxKeep: maximum number of already rendered pages to keep even though they are no longer
    in the suggested + prerender window
  maxPrerender: in addition to the suggestedPages from PagingScrollElement, render this many extra pages.
    This is useful if the pages trigger external network requests which ideally would be complete before
    the page is displayed on screen. If pages are showing up that are not fully loaded, increase this
    value.

    Down-sides:
      increased initial render time
      increased memory use

    Up-sides:
      should not significantly effect performance after initial render, even during scrolling
      gives external data requests triggered by page renders more time to complete before the page is onscreen

###
{max, min, bound} = Foundation
Aim.PagingScrollElement.getNextPageIndexes = (lastPageIndexes, suggestedPageSpread, focusedPageIndex, maxKeep, maxPrerender, maxPageIndex, minPageIndex = 0) ->

  {firstPageIndex, lastPageIndex} = lastPageIndexes

  newFirstPageIndex = focusedPageIndex - suggestedPageSpread - maxPrerender
  newLastPageIndex = focusedPageIndex + suggestedPageSpread + maxPrerender

  firstPageIndex = max minPageIndex, bound newFirstPageIndex - maxKeep, firstPageIndex, newFirstPageIndex
  lastPageIndex  = min maxPageIndex, bound newLastPageIndex, lastPageIndex, newLastPageIndex  + maxKeep

  # log getNextPageIndexes:
  #   suggestedPagesBeforeFocusedPage: suggestedPagesBeforeFocusedPage
  #   suggestedPagesAfterFocusedPage: suggestedPagesAfterFocusedPage
  #   focusedPageIndex: focusedPageIndex
  #   newFirstPageIndex: newFirstPageIndex
  #   newLastPageIndex: newLastPageIndex
  #   firstPageIndex: firstPageIndex
  #   lastPageIndex: lastPageIndex

  if firstPageIndex == lastPageIndexes.firstPageIndex && lastPageIndex == lastPageIndexes.lastPageIndex
    null
  else
    firstPageIndex: firstPageIndex
    lastPageIndex: lastPageIndex
