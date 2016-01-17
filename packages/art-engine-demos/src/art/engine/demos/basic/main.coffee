{inspect, log} = require "art.foundation"
{point, rect, color} = require "art.atomic"
{CanvasElement, Rectangle} = require("art.engine").Elements

module.exports = ->
  downColor = "#d44"
  upColor = "#dd4"

  new CanvasElement
    canvasId: "artCanvas"
    on:
      pointerMove: (e) -> element.setLocation e.location.sub element.currentSize.div 2
      pointerDown:   -> element.color = downColor
      pointerUp:     -> element.color = upColor
    new Rectangle color: "#333"
    element = new Rectangle cursor: "pointer", color: upColor, size:100, radius:50, location:25
