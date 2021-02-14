{inspect, log} = require "art-foundation"
{point, rect, color} = require "art-atomic"
Engine = require "art-engine"
{CanvasElement, RectangleElement} = Engine

module.exports = ->
  downColor = "#d44"
  upColor = "#dd4"

  new CanvasElement
    canvasId: "artCanvas"
    on:
      pointerMove: (e) -> element.setLocation e.location.sub element.currentSize.div 2
      pointerDown:   -> element.color = downColor
      pointerUp:     -> element.color = upColor
    new RectangleElement color: "#333"
    element = new RectangleElement cursor: "pointer", color: upColor, size:100, radius:50, location:25
