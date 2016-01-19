define [
  'art-foundation'
  "./bitmap"
], (Foundation, Bitmap) ->
  {Binary, inspect, log, slice, BatchLoader} = Foundation
  EncodedImage = Binary.EncodedImage

  assetHandle = (src) ->
    src.split(".")[0].split("@")[0]

  class AssetLoader extends BatchLoader
    @assetHandle = assetHandle

    constructor: (options = {})->
      defaultExtenstion = options.defaultExtenstion || ".png"
      super (src, addAsset) =>
        fullPath = src
        fullPath += defaultExtenstion unless fullPath.match /\.[0-9a-zA-Z]+$/
        fullPath = "#{@assetRoot}/"+fullPath if @assetRoot
        EncodedImage.get fullPath, (image) =>
          bitmap = @bitmapFactory.newBitmap image
          bitmap.pixelsPerPoint = if fullPath.match /@2x\./ then 2 else 1
          # addAsset assetHandle(src), bitmap
          addAsset src, bitmap
        , (rawEvent) =>
          console.error "asset #{inspect fullPath} could not be loaded. Error:", rawEvent

      @bitmapFactory = options.bitmapFactory || Bitmap
      @assetRoot = options.assetRoot
