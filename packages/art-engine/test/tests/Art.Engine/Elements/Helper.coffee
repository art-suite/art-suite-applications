{log, BaseObject} = require "@art-suite/art-foundation"
{point, Matrix} = require "art-atomic"
{StateEpoch, Element} = require("art-engine").Core
{Bitmap} = require "@art-suite/art-canvas"
{stateEpoch} = StateEpoch

module.exports = class Helper extends BaseObject
  @drawTest: (element, text, options={})->

    stateEpoch.onNextReady ->
      b = new Bitmap element.currentSize.add 50
      b.clear "#eee"
      m = element.elementToParentMatrix.mul Matrix.translate 10

      options.beforeDraw?()
      element.drawOnBitmap b, m
      options.afterDraw?()
      log b, text:"#{text}"
      options.done?()

  # options done: -> # function called just before test's "done()"
  @drawTest2: (text, f, options)=>
    test text, (done) =>
      d2 = if options?.done
        ->
          options.done()
          done()
      else
        done
      @drawTest f(), text, done:d2
      null

  @drawTest3: (text, options={})=>
    test text, (done)=>
      element = options.element()
      stagingBitmapsCreated = stagingBitmapsCreatedBefore = null

      @drawTest element, text,
        beforeDraw: -> stagingBitmapsCreatedBefore = Element.stats.stagingBitmapsCreated
        afterDraw: -> stagingBitmapsCreated = Element.stats.stagingBitmapsCreated - stagingBitmapsCreatedBefore
        done: ->
          if (v = options.stagingBitmapsCreateShouldBe)?
            assert.eq stagingBitmapsCreated, v, "stagingBitmapsCreateShouldBe"
          if (v = options.elementSpaceDrawAreaShouldBe)?
            assert.eq element.elementSpaceDrawArea, v, "stagingBitmapsCreateShouldBe"

          options.test? element

          done()
      null
