Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
{Canvas} = Neptune.Art
{point} = Atomic
{log} = Foundation
{Bitmap} = Canvas

testDrawLog = (testName, setup) ->
  test testName, ->
    {bitmap, test} = setup()
    log bitmap, testName
    test? bitmap


module.exports = suite: ->
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

  testDrawLog "regression 2", ->
    bitmap:
      new Bitmap 128
      .drawRectangle null, 128, color: "yellow"
      .drawRectangle null, 128,
        colors: [
          '#ff000000'
          '#ff000001'
          '#ff000002'
          '#ff000005'
          '#ff00000a'
          '#ff00000f'
          '#ff000015'
          '#ff00001d'
          '#ff000025'
          '#ff00002f'
          '#ff000039'
          '#ff000043'
          '#ff00004f'
          '#ff00005a'
          '#ff000067'
          '#ff000073'
          '#ff000080'
          '#ff00008c'
          '#ff000098'
          '#ff0000a5'
          '#ff0000b0'
          '#ff0000bc'
          '#ff0000c6'
          '#ff0000d0'
          '#ff0000da'
          '#ff0000e2'
          '#ff0000ea'
          '#ff0000f0'
          '#ff0000f5'
          '#ff0000fa'
          '#ff0000fd'
          '#ff0000fe'
          '#ff0000'
          ]
