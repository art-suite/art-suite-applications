define [
  'art.foundation/src/art/dev_tools/test/art_chai'
  'art.foundation'
  'art.canvas'
], (chai, Foundation, Canvas) ->
  assert = chai.assert
  {log} = Foundation
  {GoogleFontLoader} = Canvas
  {googleFontLoader} = GoogleFontLoader

  suite "Art.Canvas.GoogleFontLoader", ->
    test "load Euphoria Script", (done)->
      googleFontLoader.load (name = "Euphoria Script"), (assets, sources, info) ->
        assert.ok assets[name]
        done()

