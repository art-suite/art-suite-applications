
module.exports = ->
  {point, rect, color} = require 'art-atomic'
  {inspect, log, merge} = require 'art-foundation'
  {Elements:{Rectangle, Element, TextElement, CanvasElement}} = require 'art-engine'

  color1 = "#d44"
  color2 = "#4d4"

  makeElement = (options) ->
    new Element options,
      new Rectangle color: color1
      new Rectangle color: color2, compositeMode:"add", location: {yph:.2, xpw:-.1}, size: wpw:1.2, hph:1
      new TextElement axis:.5, text:options.text, fontFamily:"arial", location: ps:.5

  new CanvasElement
    canvasId: "artCanvas"
    new Rectangle color: "#333"
    makeElement text:"clip: false", clip:false,                        axis:.5, size: 100, location: yph:.25, xpw:.25
    makeElement text:"clip: true",  clip:true,                         axis:.5, size: 100, location: yph:.25, xpw:.50
    makeElement text:"clip: true\nopacity: .5", opacity:.5, clip:true, axis:.5, size: 100, location: yph:.25, xpw:.75

    makeElement text:"clip: false", clip:false,                        axis:.5, angle:Math.PI/6, size: 100, location: yph:.50, xpw:.25
    makeElement text:"clip: true",  clip:true,                         axis:.5, angle:Math.PI/6, size: 100, location: yph:.50, xpw:.50
    makeElement text:"clip: true\nopacity: .5", opacity:.5, clip:true, axis:.5, angle:Math.PI/6, size: 100, location: yph:.50, xpw:.75

    makeElement text:"clip: false", clip:false,                        axis:.5, scale:.7575, size: 100, location: yph:.75, xpw:.25
    makeElement text:"clip: true",  clip:true,                         axis:.5, scale:.7575, size: 100, location: yph:.75, xpw:.50
    makeElement text:"clip: true\nopacity: .5", opacity:.5, clip:true, axis:.5, scale:.7575, size: 100, location: yph:.75, xpw:.75

