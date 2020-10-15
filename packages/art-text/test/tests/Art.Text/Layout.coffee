{defineModule, inspect, eq, log, isString} = require 'art-standard-lib'
{point, rect} = require 'art-atomic'
{Metrics, Layout} = require 'art-text'

oneLineText = "Quickly the brown fox jumps over the lazy dog."

logBitmapTest = (name, testF) ->
  test name, ->
    log testF(), name

defineModule module, suite:
  basics: ->
    test "new", ->
      layout = new Layout oneLineText,
        textLayoutMode: "textual" # or "tight"
        fontFamily: "Arial"
        fontSize: 16

      assert.within layout.size, point(328, 12), point(331, 12)

    logBitmapTest "toBitmap basic", ->
      layout = new Layout oneLineText
      layout.toBitmap()

    logBitmapTest "blank lines", ->
      layout = new Layout "Hi\n\nthere."
      assert.eq 3, layout.lineCount
      layout.toBitmap()

    logBitmapTest "layoutMode: 'textualBaseline'", ->
      layout = new Layout "Going somewhere?", {fontSize: 16}, layoutMode: 'textualBaseline'
      b = layout.toBitmap()
      # assert.eq layout.size.y, 10
      # assert.eq b.size.y, 10
      b

    logBitmapTest "blank lines with layoutAreaWidth", ->
      layout = new Layout "Hi to the world of wonder.\n\nThere is so much fun!", {}, {}, 100
      assert.eq 5, layout.lineCount
      layout.toBitmap()

    test "lolcats", ->
      layout = new Layout "I IZ IN YOUR KIMI\nLIKING ALL UR PHOTOS", {fontFamily:"Impact", fontSize:64}, {layoutMode:"tight"}
      bitmap = layout.toBitmap()
      log bitmap
      assert.within bitmap.size, point(544, 133), point(550, 137)

    test "precision", ->
      layout = new Layout "hi", fontFamily:"Impact", fontSize:64, layoutMode:"tight"
      bitmap = layout.toBitmap()
      log bitmap

    test "toBitmap scale:2 textual", ->
      layout = new Layout oneLineText
      bitmap = layout.toBitmap scale:2
      log bitmap
      assert.within bitmap.size, point(606, 24), point(615, 24)

    test "toBitmap scale:2 tight", ->
      layout = new Layout oneLineText, null, layoutMode: "tight"
      bitmap = layout.toBitmap scale:2
      log bitmap
      assert.within bitmap.size, point(606, 24), point(615, 30)

    test "multi-lined", ->
      layout = new Layout "Testing multi-line layout.\nLine two."
      log layout.toBitmap()
      assert.eq (fragment.layoutArea.x for fragment in layout.fragments), [0, 0]

    test "center alignment", ->
      layout = new Layout "Testing center alignment.\ncentered", {}, align:"center", 200
      assert.eq
      log layout.toBitmap()
      for fragment in layout.fragments
        assert.eq fragment.alignedLayoutArea.hCenter, 100

    test "right alignment", ->
      layout = new Layout "Testing center alignment.\ncentered", {}, align:"right", 200
      log layout.toBitmap()
      for fragment in layout.fragments
        assert.eq fragment.alignedLayoutArea.right, 200

    test "layoutAreaWidth basic", ->
      layout = new Layout oneLineText + " " + oneLineText, {}, null, 200
      log layout.toBitmap()
      assert.within layout.size.x, 190, 200

    test "layoutAreaWidth with layoutMode: 'textualBaseline'", ->
      layout = new Layout oneLineText + " " + oneLineText, {fontSize: 16}, leading:1, layoutMode: 'textualBaseline', 200
      log layout.toBitmap()
      assert.eq layout.size.y, 16 * 4 - 4

    test "alignmentWidth basic", ->
      layout = new Layout oneLineText + " " + oneLineText, {}, {}, 200
      log layout.toBitmap()
      assert.within layout.size.x, 195, 196

    test "layoutAreaWidth and manual wrap have same height", ->
      wwLayout = new Layout oneLineText + " " + oneLineText, {}, null, 200
      log wordWrapedLayout: wwLayout.toBitmap()

      manualLayout = new Layout "Quickly the brown fox jumps\nover the lazy dog. Quickly the\nbrown fox jumps over the lazy\ndog", {}
      log manualWrappedLayout:manualLayout.toBitmap()
      assert.eq manualLayout.size.y, wwLayout.size.y

    test "layoutAreaWidth long word single", ->
      longWord = "abcdefghijklmnipqrstuvwxyz"
      layout = new Layout longWord, {}, null, 100
      log wordWrapWidthOneLongWord:layout.toBitmap(), layout.size.x
      assert.within layout.size.x, 90, 100

    test "layoutAreaWidth long word after short word", ->
      longWord = "foobar abcdefghijklmnipqrstuvwxyz"
      layout = new Layout longWord, {}, null, 100
      log wordWrapWidthLongWordAfterShortWord:layout.toBitmap(), layout.size.x
      assert.within layout.size.x, 90, 100

    test "layoutAreaWidth two paragraphs", ->
      paragraph1 = "   " + oneLineText + " " + oneLineText
      paragraph2 = "   I said, '" + oneLineText + " " + oneLineText + "'"
      layout = new Layout paragraph1 + "\n" + paragraph2, {}, null, 200
      log wordWrapWidthTwoParagraphs:layout.toBitmap()
      assert.within layout.size.x, 185, 200

    test "layoutAreaWidth centered", ->
      layout = new Layout oneLineText + " " + oneLineText, {}, align:"center", 200
      log wordWrapWidthCentered:layout.toBitmap()
      assert.within layout.size.x, 190, 200

    test "layoutAreaWidth one word centered", ->
      layout = new Layout "hi", {}, align:"center", 200
      log oneWordCentered:layout.toBitmap()
      assert.within layout.size.x, 10, 15

    test "layoutAreaWidth one word basic", ->
      layout = new Layout "Sing?!?"
      bitmap = layout.toBitmap()
      log oneWordBasic:bitmap, size: bitmap.size
      assert.within layout.drawArea.rounded,
        rect -8, -8, 64, 32
        rect -8, -8, 65, 32


    test "leading", ->
      layout = new Layout "Testing leading: 1.25 (default)\nneeds 2 lines"
      assert.eq (parseInt fragment.layoutArea.y for fragment in layout.fragments), [0, 20]
      log leading_1_25:layout.toBitmap()
      layout = new Layout "Testing leading: 2.0\nneeds 2 lines", {}, leading: 2
      log leading_2_00:layout.toBitmap()
      assert.eq (parseInt fragment.layoutArea.y for fragment in layout.fragments), [0, 32]

    test "paragraphLeading", ->
      layout = new Layout "Testing one two three!\nParagraph 2.", {}, null, 100
      log leading_1_25:layout.toBitmap()
      assert.eq (parseInt fragment.layoutArea.y for fragment in layout.fragments), [0, 20, 40]
      layout = new Layout "Testing one two three!\nParagraph 2.", {}, paragraphLeading: 2, 100
      log leading_2_00:layout.toBitmap()
      assert.eq (parseInt fragment.layoutArea.y for fragment in layout.fragments), [0, 20, 52]

    test "layoutAreaWidth, align:'center' and drawArea", ->
      layout = new Layout "hi", {}, align: "center", 300
      log "layout align center":layout.toBitmap()
      assert.eq layout.drawArea.rounded, rect 136, -8, 28, 32

    test "layoutAreaWidth, align:'right' and drawArea", ->
      layout = new Layout "hi", {}, align: "right", 300
      log "layoutAreaWidth, align:'right' and drawArea":layout.toBitmap()
      assert.eq layout.drawArea.rounded, rect 280, -8, 28, 32

    test "layoutAreaWidth && alignmentWidth, align:'center' and drawArea", ->
      layout = new Layout "hi", {}, align: "center", 300
      log "layoutAreaWidth && alignmentWidth, align:'center' and drawArea": layout.toBitmap()
      assert.eq layout.area.rounded.w, 12
      assert.eq layout.drawArea.rounded, rect 136, -8, 28, 32

    test "layoutAreaWidth && alignmentWidth, align:'right' and drawArea", ->
      layout = new Layout "hi", {}, align: "right", 300
      assert.eq layout.area.rounded.w, 12
      assert.within layout.drawArea.right, 300, 310

  maxLines: ->

    test "drawArea", ->
      layout1 = new Layout "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.",
        fontSize: 17.5
        {maxLines: 2}
        300

      layout2 = new Layout "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over",
        fontSize: 17.5
        {maxLines: 2}
        300

      log
        layout1: layout1.toBitmap()
        layout2: layout2.toBitmap()
      assert.eq layout1.drawArea.h, layout2.drawArea.h

  regressions: ->
    test "empty text", ->
      fontOptions =
        fontFamily: "Times"
        fontSize: 20
        fontStyle: "normal"
        fontVariant: "normal"
        fontWeight: "normal"

      layoutOptions =
        align: top
        layoutMode: "textualBaseline"
        leading: 1.25
        paragraphLeading: null
        maxLines: null
        overflow: "ellipsis"

      layout = new Layout "|", fontOptions, layoutOptions, 100
      assert.eq layout.getSize().y, 15, "baseline using text: '|'"

      layout = new Layout "", fontOptions, layoutOptions, 100
      assert.eq layout.getSize().y, 15, "actual using text: ''"