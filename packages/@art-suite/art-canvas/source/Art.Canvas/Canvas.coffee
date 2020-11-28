{isCanvas, isImage, getImageSize} = require './BitmapBase'
module.exports = [
  {
    isCanvas, isImage, getImageSize
    mipmapCache: require('./MipmapCache').mipmapCache
  }
  require './Tools'
  require './CompositeModes'
]
