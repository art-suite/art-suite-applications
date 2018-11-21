{isCanvas, isImage} = require './BitmapBase'
module.exports = [
  {
    isCanvas, isImage
    mipmapCache: require('./MipmapCache').mipmapCache
  }
  require './Tools'
  require './CompositeModes'
]
