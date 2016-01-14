console.log __dirname:__dirname
define [
  'art.foundation/src/art/dev_tools/test/art_chai'
  'art.foundation'
  'art.atomic'
  'art.canvas'
  ], (chai, Foundation, Atomic, Canvas) ->
  assert = chai.assert
  {point} = Atomic
  {inspect, log} = Foundation
  {Bitmap, AssetLoader} = Canvas

  assetRoot = self.testAssetRoot + "/asset_loader_test"
  BitmapClassPathName = Bitmap.getClassPathName()

  suite "Art.Canvas.AssetLoader", ->
    verifySourcesAreBitmaps = (assets, sources) =>
      for source in sources
        assert.ok assets[source] instanceof Bitmap

    test "allocate", ->
      al = new AssetLoader

    test "assetHandle", ->
      assert.eq "foo", AssetLoader.assetHandle "foo"
      assert.eq "foo", AssetLoader.assetHandle "foo.bar"
      assert.eq "foo", AssetLoader.assetHandle "foo@2x.bar"

    test "loading with explicit extensions", (done)->
      al = new AssetLoader assetRoot: assetRoot
      al.load ["image1.png", "image2.png"], (a, b, c) ->
        assert.eq a[b[0]].classPathName, BitmapClassPathName
        assert.eq a[b[1]].classPathName, BitmapClassPathName
        done()

    test "loading with implicit extensions", (done)->
      al = new AssetLoader assetRoot: assetRoot
      al.load ["image1", "image2"], (a, b, c) ->
        log bee:b, a:a, zero:a[b[0]], one:a[b[1]]
        assert.eq a.image1.classPathName, BitmapClassPathName
        assert.eq a.image2.classPathName, BitmapClassPathName
        done()

    test "two overlapping loads", (done)->
      al = new AssetLoader assetRoot: assetRoot
      loadCount = {}
      image2Object = null

      processCount = 0
      processLoad = (assets, sources, info) =>
        assert.equal info.loadedFromCache, 0
        assert.equal info.loadedAsynchronously, 2
        verifySourcesAreBitmaps assets, sources
        for source in sources
          if source=="image2.png"
            image2Object ||= assets[source]
            assert.equal image2Object, assets[source]

          loadCount[source] ||= 0
          loadCount[source] += 1

        processCount += 1
        assert.ok processCount <= 2
        if processCount == 2
          assert.equal loadCount["image1.png"], 1
          assert.equal loadCount["image2.png"], 2
          assert.equal loadCount["image3.png"], 1
          done()

      al.load ["image1.png", "image2.png"], processLoad
      al.load ["image2.png", "image3.png"], processLoad

    test "two sequential loads", (done)->
      al = new AssetLoader assetRoot: assetRoot
      count = 0
      al.load ["image1.png", "image2.png"], (assets, sources, info) =>
        assert.equal count++, 0
        verifySourcesAreBitmaps assets, sources
        assert.equal info.loadedAsynchronously, 2
        assert.equal info.loadedFromCache, 0
        al.load ["image2.png", "image3.png"], (assets, sources, info) =>
          assert.equal count++, 1
          verifySourcesAreBitmaps assets, sources
          assert.equal info.loadedAsynchronously, 1
          assert.equal info.loadedFromCache, 1
          done()

    test "completely from-cache load", (done)->
      al = new AssetLoader assetRoot: assetRoot
      count = 0
      al.addAsset "image1.png", new Bitmap 100, 100
      al.addAsset "image2.png", new Bitmap 100, 100
      al.load ["image1.png", "image2.png"], (assets, sources, info) =>
        assert.equal count++, 0
        verifySourcesAreBitmaps assets, sources
        assert.equal info.loadedAsynchronously, 0
        assert.equal info.loadedFromCache, 2
        done()
