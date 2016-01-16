Text = require 'art.text'
Foundation = require 'art.foundation'
Atomic = require 'art.atomic'
# GoogleFontLoader = require 'art.canvas/google_font_loader'

{point, rect} = Atomic
{inspect, eq, merge, select, log, isString, selectAll, isNumber} = Foundation
{Metrics} = Text

longText = "Quickly the brown fox jumps over the lazy dog."

testFontMetrics = (metaOptions)->
  text = metaOptions.text
  fontOptions = metaOptions.fontOptions

  if tightShouldBe = metaOptions.tightShouldBe
    assert.eq selectAll(Metrics.get(text, fontOptions, "tight"), Object.keys tightShouldBe), tightShouldBe

  if tight0ShouldBe = metaOptions.tight0ShouldBe
    assert.eq selectAll(Metrics.get(text, fontOptions, "tight0"), Object.keys tight0ShouldBe), tight0ShouldBe

  if textualShouldBe = metaOptions.textualShouldBe
    assert.eq selectAll(Metrics.get(text, fontOptions, "textual"), Object.keys textualShouldBe), textualShouldBe

  if drawAreaShouldBe = metaOptions.drawAreaShouldBe
    assert.eq Metrics.get(text, fontOptions, "textual").drawArea, drawAreaShouldBe

# loadGoogleFont = (fontFamily, done) ->
#   googleFontLoader.load fontFamily, ->
#     done()

round = (v) ->
  if isNumber v
    Math.round v
  else
    v?.rounded || v

testMetrics = (text, fontOptions, layoutMode, minValues, maxValues) ->
  m = Metrics.get text, fontOptions, layoutMode
  m = selectAll m, Object.keys minValues
  # log textual:new Art.Text.Layout(options).toBitmap(), options: options
  for k, v of m
    minV = minValues[k]
    roundV = round v
    if maxValues
      maxV = maxValues[k]
      assert.within roundV, minV, maxV, "testing #{k} is within bounds (test value #{v} was rounded to #{roundV}) fontOptions: #{inspect fontOptions}, layoutMode: #{layoutMode}"
    else
      assert.eq roundV, minV, "testing equality of: #{k} (test value #{v} was rounded to #{roundV}) fontOptions: #{inspect fontOptions}, layoutMode: #{layoutMode}"

suite "Art.Text.Metrics", ->
  test "getWidth", ->
    assert.within Metrics.getWidth("!"          , fontFamily:"Times New Roman", fontSize:16), 5, 6
    assert.within Metrics.getWidth("!!!"        , fontFamily:"Times New Roman", fontSize:16), 15, 16
    assert.within Metrics.getWidth("hello world", fontFamily:"Times New Roman", fontSize:16), 72, 74

  test "textualBaseline", ->
    # text = "Going somewhere?"
    text = "joe"
    fontOptions = fontFamily:"Times New Roman", fontSize:16
    m1 = Metrics.get text, fontOptions, "textual"
    m2 = Metrics.get text, fontOptions, "textualBaseline"
    log m1:m1, m2:m2
    assert.eq m1.area.h, m2.area.h + m2.descender
    assert.eq m1.drawArea, m2.drawArea

  test "get descender", ->
    fontOptions = fontFamily:"Times New Roman", fontSize:16
    text = "joe"
    testMetrics text, fontOptions, "textual",
      {layoutArea: rect(0, 0, 19, 16), ascender: 12, descender: 4}
      {layoutArea: rect(0, 0, 20, 16), ascender: 12, descender: 4}

    testMetrics text, fontOptions, "tight",  layoutArea: rect(0, 0, 20, 14), ascender: 12, descender: 2
    testMetrics text, fontOptions, "tight0",
      {layoutArea: rect(0, 0, 21, 16), ascender: 13, descender: 3},
      {layoutArea: rect(0, 0, 22, 16), ascender: 13, descender: 3}

  test "get ascender", ->
    fontOptions = fontFamily:"Times New Roman", fontSize:16
    text = "Hello"
    testMetrics text, fontOptions, "tight",
      {layoutArea: rect(0, 0, 34, 11), ascender: 12, descender: -1}
      {layoutArea: rect(0, 0, 34, 11), ascender: 12, descender: -1}
    testMetrics text, fontOptions, "tight0",
      {layoutArea: rect(0, 0, 35, 13), ascender: 13, descender: 0}
      {layoutArea: rect(0, 0, 36, 13), ascender: 13, descender: 0}
    testMetrics text, fontOptions, "textual",
      {layoutArea: rect(0, 0, 35, 16), ascender: 12, descender: 4}
      {layoutArea: rect(0, 0, 36, 16), ascender: 12, descender: 4}

  test "get symbols", ->
    fontOptions = fontFamily:"Times New Roman", fontSize:16
    text = "!@#$%^&*()|"
    testMetrics text, fontOptions, "tight",
      {layoutArea: rect(0, 0, 87, 14), ascender: 12, descender: 2}
      {layoutArea: rect(0, 0, 88, 14), ascender: 12, descender: 2}
    testMetrics text, fontOptions, "tight0",
      {layoutArea: rect(0, 0, 89, 16), ascender: 13, descender: 3}
      {layoutArea: rect(0, 0, 90, 16), ascender: 13, descender: 3}
    testMetrics text, fontOptions, "textual",
      {layoutArea: rect(0, 0, 90, 16), ascender: 12, descender: 4}
      {layoutArea: rect(0, 0, 92, 16), ascender: 12, descender: 4}

  test "get large", ->
    text = "hi"
    fontOptions = fontFamily:"Impact", fontSize:64
    testMetrics text, fontOptions, "tight",   layoutArea: rect(0, 0, 47, 51), ascender: 52, descender: -1
    testMetrics text, fontOptions, "tight0",  layoutArea: rect(0, 0, 49, 52), ascender: 53, descender: -1
    testMetrics text, fontOptions, "textual",
      {layoutArea: rect(0, 0, 51, 64), ascender: 48, descender: 16}
      {layoutArea: rect(0, 0, 52, 64), ascender: 48, descender: 16}

  test "get small", ->
    text = longText
    fontOptions = fontFamily:"Times New Roman", fontSize:6
    testMetrics text, fontOptions, "tight",
      {layoutArea: rect(0, 0, 99, 4),  ascender: 5, descender: -1}
      {layoutArea: rect(0, 0, 120, 5), ascender: 5, descender: 0}
    testMetrics text, fontOptions, "tight0",
      {layoutArea: rect(0, 0, 116, 7), ascender: 6, descender: 1}
      {layoutArea: rect(0, 0, 123, 7), ascender: 6, descender: 1}
    testMetrics text, fontOptions, "textual",
      {layoutArea: rect(0, 0, 115, 6), ascender: 5, descender: 2}
      {layoutArea: rect(0, 0, 123, 6), ascender: 5, descender: 2}

  test "multiline not supported", ->
    # isn't actually supported by canvas, but we test to make sure it doesn't suddently become supported and change behavior
    multiLineText = "Quickly the brown\nfox jumps over\nthe lazy dog."

    assert.throws ->
      testFontMetrics
        text:multiLineText
        fontOptions: fontFamily:"Times New Roman", fontSize:"24"
        testMetrics text, fontOptions, "tight", area: rect(1, -17, 461, 22), ascender: 18, descender: 4

  # test "exotic Fonts - Nosifer", (done)->
  #   loadGoogleFont "Nosifer", ->
  #     fontOptions = fontFamily:"Nosifer", fontSize:24
  #     text = longText
  #     testMetrics text, fontOptions, "tight",
  #       {area:rect(1, -17, 868, 26), ascender: 18, descender: 8}
  #       {area:rect(1, -17, 869, 27), ascender: 18, descender: 9}
  #     done()

  # test "exotic Fonts - Euphoria Script", (done)->
  #   log "loading Euphoria Script"
  #   loadGoogleFont "Euphoria Script", ->
  #     log "loaded Euphoria Script"
  #     fontOptions = fontFamily:"Euphoria Script", fontSize:48
  #     text = longText
  #     testMetrics text, fontOptions, "tight0",
  #       {area: rect(-2, -32, 685, 45), ascender: 33, descender: 12},
  #       {area: rect(-1, -32, 687, 45), ascender: 33, descender: 12}
  #     testMetrics text, fontOption, "tight",
  #       {area: rect(-1, -31, 684, 44), ascender: 32, descender: 12},
  #       {area: rect(-1, -31, 685, 44), ascender: 32, descender: 12}
  #     done()

  # test "exotic Fonts - Henny Penny", (done)->
  #   loadGoogleFont "Henny Penny", ->
  #     fontOptions = fontFamily:"Henny Penny", fontSize:"32"
  #     text = longText
  #     testMetrics text, fontOptions, "tight0",
  #       {area: rect(-1, -37, 669, 53), ascender: 38, descender: 15}
  #       {area: rect(-1, -37, 694, 53), ascender: 38, descender: 15}
  #     testMetrics text, fontOptions, "tight",
  #       {area: rect(0, -36, 667, 52), ascender: 37, descender: 15}
  #       {area: rect(0, -36, 692, 52), ascender: 37, descender: 15}
  #     done()

  # test "exotic Fonts - Griffy", (done)->
  #   loadGoogleFont "Griffy", ->
  #     fontOptions = fontFamily:"Griffy", fontSize:"48"
  #     text = longText
  #     testMetrics text, fontOptions, "tight0", area: rect(1, -36, 932, 55), ascender: 37, descender: 18
  #     testMetrics text, fontOptions, "tight", area: rect(2, -36, 930, 54), ascender: 37, descender: 17
  #     done()

  # test "exotic Fonts - Freckle Face", (done)->
  #   loadGoogleFont "Freckle Face", ->
  #     fontOptions = fontFamily:"Freckle Face", fontSize:"48"
  #     text = longText
  #     testMetrics text, fontOptions, "tight0",
  #       {area: rect(0, -37, 934, 49), ascender: 38, descender: 11},
  #       {area: rect(0, -37, 935, 49), ascender: 38, descender: 11}
  #     testMetrics text, fontOptions, "tight",
  #       {area: rect(1, -36, 932, 47), ascender: 37, descender: 10},
  #       {area: rect(1, -36, 933, 47), ascender: 37, descender: 10}
  #     done()

  # test "exotic Fonts - Limelight", (done)->
  #   loadGoogleFont "Limelight", ->
  #     fontOptions = fontFamily:"Limelight", fontSize:"48"
  #     text = "CUSTOM"
  #     testMetrics text, fontOptions, "tight0",   area: rect(1, -36, 211, 37), ascender: 37, descender: 0
  #     testMetrics text, fontOptions, "tight",    area: rect(2, -35, 209, 35), ascender: 36, descender: -1
  #     done()

  # test "exotic Fonts - Rouge Script", (done)->
  #   loadGoogleFont 'Rouge Script', ->
  #     fontOptions = fontFamily:'Rouge Script', fontSize:"48"
  #     text = longText
  #     testMetrics text, fontOptions, "tight0",
  #       {area: rect(0, -32, 639, 48), ascender: 33, descender: 15},
  #       {area: rect(0, -32, 644, 48), ascender: 33, descender: 15}
  #     testMetrics text, fontOptions, "tight",
  #       {area: rect(1, -32, 637, 47), ascender: 33, descender: 14},
  #       {area: rect(1, -32, 642, 47), ascender: 33, descender: 14}
  #     done()

  test "get no ascenders or descenders", ->
    text = "were r u"
    fontOptions = fontFamily:"Times New Roman", fontSize:16

    metrics =
      tight:   Metrics.get text, fontOptions, "tight"
      tight0:  Metrics.get text, fontOptions, "tight0"
      textual: Metrics.get text, fontOptions, "textual"

    assert.within metrics.tight.layoutArea, rect(0, 0, 52, 8), rect(0, 0, 54, 8)
    assert.eq metrics.tight.ascender, 9
    assert.eq metrics.tight.descender, -1

    assert.within metrics.tight0.layoutArea, rect(0, 0, 52, 9), rect(0, 0, 54, 9)
    assert.eq metrics.tight0.ascender, 9
    assert.eq metrics.tight0.descender, 0

    assert.within metrics.textual.layoutArea, rect(0, 0, 52, 16), rect(0, 0, 53, 16)
    assert.eq metrics.textual.ascender, 12
    assert.eq metrics.textual.descender, 4

    log textual:new Text.Layout(text, fontOptions).toBitmap()

    assert.eq metrics.textual.alignedDrawArea, rect -8, -8, 67, 31

  testWrap = (wordWrapWidth, string, expectedLines, maxWidth) ->
    test "testWrap: wordWrapWidth:#{wordWrapWidth} string:#{inspect string}", ->
      fontOptions = {}
      Metrics.normalizeFontOptions fontOptions
      fontCss = Metrics.toFontCss fontOptions

      lines = Metrics.wrap string, fontOptions, wordWrapWidth, fontCss
      maxWidth = wordWrapWidth unless maxWidth?
      assert.eq expectedLines, (line.text for line in lines)
      for line in lines
        assert.within line.area.w, 0, maxWidth

  testWrap 100, "The quick brown fox jumped over the lazy dog.",  ["The quick", "brown fox", "jumped over", "the lazy dog."]
  testWrap 100, "",                                               [""]
  testWrap 100, "   The quick brown fox jumped over the lazy...", ["   The quick", "brown fox", "jumped over", "the lazy..."]
  testWrap 200, "The quick brown fox jumped over the lazy dog.",  ["The quick brown fox jumped", "over the lazy dog."]
  testWrap 100, "abcdefghijklmnipqrstuvwxyz",                     ["abcdefghijklm", "nipqrstuvwxyz"]
  testWrap 100, "   abcdefghijklmnipqrstuvwxyz",                  ["   abcdefghijkl", "mnipqrstuvwx", "yz"]
  testWrap 70,  "abcdefghijklmnipqrstuvwxyz",                     ["abcdefghij", "klmnipqrst", "uvwxyz"]
  testWrap 70,  "hi abcdefghijklmnipqrstuvwxyz",                  ["hi", "abcdefghij", "klmnipqrst", "uvwxyz"]
  testWrap 70,  "hi abcdefghijklmnipqrstuvwxyz i",                ["hi", "abcdefghij", "klmnipqrst", "uvwxyz i"]
  testWrap 0,  "Well now.",                                       ["W", "e", "l", "l", "n", "o", "w", "."], 16
  testWrap 0,  "  now",                                           [" ", " ", "n", "o", "w"], 12
  testWrap -140,  "  now",                                           [" ", " ", "n", "o", "w"], 12
