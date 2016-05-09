
module.exports = ->
  Foundation = require 'art-foundation'
  Atomic = require 'art-atomic'
  Engine = require 'art-engine'
  {hslColor} = Atomic
  {log, Browser, inspect, bound, min, max, abs, round, modulo} = Foundation
  {RectangleElement, TextElement, CanvasElement, Element, PagingScrollElement} = Engine

  scroll = ({vertical:"vertical", horizontal:"horizontal"}[Browser.Parse.query().scroll]) || "vertical"
  log
    PagingScrollElementDemo:
      scroll: scroll
      options:
        dev: "?dev=true/false"
        scroll: "?scroll=vertical/horizontal"

  generatedChildrenMap = {}
  generateChildren = (centerIndex, spread = 2)->
    oldGeneratedChildrenMap = generatedChildrenMap
    generatedChildrenMap = {}
    for pageIndex in [max(0, centerIndex - spread) .. centerIndex + spread] by 1
      h = modulo pageIndex / 24, 1
      # log h:h
      text = round(h*360) + "°"
      key = pageIndex.toString()
      generatedChildrenMap[key] = oldGeneratedChildrenMap[key] || new Element
        size:
          if scroll == "horizontal"
            hh:1, w:300
          else
            ww:1, h:300
        key: key
        # margin: 10
        new RectangleElement color: hslColor h, 1, 1
        new TextElement
          location: ps: .5
          axis: .5
          fontSize: 128
          color: "#0007"
          text: text

  new CanvasElement
    canvasId: "artCanvas"
    new RectangleElement color: "#333"
    new PagingScrollElement
      padding: 5
      scroll: scroll
      on:
        scrollUpdate: ({target, props:{focusedPage, currentGeometry}}) ->
          target.setChildren generateChildren focusedPage.key | 0, currentGeometry.suggestedPageSpread

      generateChildren 0

    new TextElement
      color: "#fffc"
      location: 10
      text: "PagingScrollElement Demo"
