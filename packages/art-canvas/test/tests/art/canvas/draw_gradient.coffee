Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
Canvas = require 'art-canvas'
{point} = Atomic
{log} = Foundation
{Bitmap} = Canvas

testDrawLog = (testName, setup) ->
  test testName, ->
    {bitmap, test} = setup()
    log bitmap, testName
    test? bitmap


suite "Art.Canvas.Bitmap.drawGradient", ->
  test "basic", ->
    b = new Bitmap 128
    b.drawRectangle null, 128, colors: ["blue", "white"]
    log b

  test "three colors", ->
    b = new Bitmap 128
    b.drawRectangle null, 128, colors: ["red", "yellow", "green"]
    log b

  test "custom color spacing 1", ->
    b = new Bitmap 128
    b.drawRectangle null, 128, colors: 0:"red", 0.75:"yellow", 1:"green"
    log b

  test "custom color spacing 2", ->
    b = new Bitmap 128
    b.drawRectangle null, 128, colors: [{n:0, c:"red"}, {n:0.25, c:"yellow"}, {n:1, c:"green"}]
    log b

  test "custom from and to", ->
    b = new Bitmap 128
    b.drawRectangle null, 128,
      colors: ["blue", "white"]
      to: point 128, 0
      from: point 0, 128
    log b

  test "radial", ->
    b = new Bitmap 128
    b.drawRectangle null, 128,
      colors: ["blue", "white"]
      from: point 64, 64
      gradientRadius1: 64
    log b

  test "radial two radii", ->
    b = new Bitmap 128
    b.drawRectangle null, 128,
      colors: ["blue", "white"]
      from: point 64, 64
      gradientRadius1: 32
      gradientRadius2: 64 * 1.404
    log b

  test "radial from and to", ->
    b = new Bitmap 128
    b.drawRectangle null, 128,
      colors: ["blue", "white"]
      from: point 64, 64
      to: point 96, 96
      gradientRadius: 64 * 1.404
    log b

  testDrawLog "regression", ->
    bitmap:
      new Bitmap 128
      .drawRectangle null, 128,
        colors: [
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
