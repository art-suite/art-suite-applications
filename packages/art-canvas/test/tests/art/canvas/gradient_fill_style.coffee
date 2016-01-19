{assert} = require 'art-foundation/src/art/dev_tools/test/art_chai'
{point} = require 'art-atomic'
{log} = require 'art-foundation'
{GradientFillStyle} = require 'art-canvas'

suite "Art.Canvas.GradientFillStyle", ->
  test "explicit 3-step gradient", ->
    gfs = new GradientFillStyle point(0,0), point(100,0), 0:"#000", .75:"#f00", 1:"#0f0"
    assert.eq gfs.colors, [{c: "#000", n: 0}, {n: 0.75, c: "#f00"}, {c: "#0f0", n: 1}]

  test "implicit 3-step gradient", ->
    gfs = new GradientFillStyle point(0,0), point(100,0), ["#000", "#f00", "#0f0"]
    assert.eq gfs.colors, [{c: "#000", n: 0}, {n: 0.5, c: "#f00"}, {c: "#0f0", n: 1}]

