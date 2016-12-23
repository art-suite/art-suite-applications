{w, Promise, object} = require 'art-foundation'
{Bitmap} = require 'art-canvas'

module.exports = class Assets
  @files: w "
    boy2.jpg
    rose.jpg
    boy1.jpg
    cockpit.jpg
    colors.jpg
    dessert.jpg
    leaves.jpg
    science.jpg
    grey.jpg
    8mpSunset.jpg
    "

  @fileMap = object @files

  # OUT: promise -> {filename: bitmap, ...}
  @loadAll: =>
    @_loadPromise ||= Promise.deepAll object @files, (file) -> Bitmap.get testAssetRoot + "/" + file

  # OUT: promise -> bitmap
  @load: (file) =>
    throw new Error "#{file} does not exists" unless @fileMap[file]
    @loadAll()
    .then (map) -> map[file]
