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

  test "regression > 10 colors with no positions", ->
    colors = GradientFillStyle.colorsToObjectsAndStringColors [
      "#f00"
      "#f70"
      "#ff0"
      "#7f0"
      "#0f0"
      "#0f7"
      "#0ff"
      "#07f"
      "#00f"
      "#70f"
      "#f0f"
      ]
    assert.eq colors, [
      {c: "#f00"}
      {c: "#f70"}
      {c: "#ff0"}
      {c: "#7f0"}
      {c: "#0f0"}
      {c: "#0f7"}
      {c: "#0ff"}
      {c: "#07f"}
      {c: "#00f"}
      {c: "#70f"}
      {c: "#f0f"}
    ], "colorsToObjectsAndStringColors"
    colors = GradientFillStyle.interpolateColorPositions colors
    assert.eq colors, [
      {c: "#f00", n: .0}
      {c: "#f70", n: .1}
      {c: "#ff0", n: .2}
      {c: "#7f0", n: .3}
      {c: "#0f0", n: .4}
      {c: "#0f7", n: .5}
      {c: "#0ff", n: .6}
      {c: "#07f", n: .7}
      {c: "#00f", n: .8}
      {c: "#70f", n: .9}
      {c: "#f0f", n: 1}
    ], "interpolateColorPositions"
