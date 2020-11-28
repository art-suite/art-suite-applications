Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
{Canvas} = Neptune.Art

{log} = Foundation
{GoogleFontLoader} = Canvas
{googleFontLoader} = GoogleFontLoader

module.exports = suite: ->
  test "load Euphoria Script", (done)->
    googleFontLoader.load (name = "Euphoria Script"), (assets, sources, info) ->
      assert.ok assets[name]
      done()
    null

