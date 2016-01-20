Atomic = require 'art-atomic'
Foundation = require 'art-foundation'
Text = require 'art-text'

{point, rect} = Atomic
{inspect, eq, log, isString} = Foundation
{Metrics} = Text

oneLineText = "Quickly the brown fox jumps over the lazy dog."

logBitmapTest = (name, testF) ->
  test name, ->
    log testF(), name

suite "Art.Text.Layout", ->
  test "new", ->
    layout = new Text.Layout oneLineText,
      textLayoutMode: "textual" # or "tight"
      fontFamily: "Arial"
      fontSize: 16

    assert.within layout.size, point(328, 12), point(331, 12)

  logBitmapTest "toBitmap basic", ->
    layout = new Text.Layout oneLineText
    layout.toBitmap()

  logBitmapTest "blank lines", ->
    layout = new Text.Layout "Hi\n\nthere."
    assert.eq 3, layout.lineCount
    layout.toBitmap()

  logBitmapTest "layoutMode: 'textualBaseline'", ->
    layout = new Text.Layout "Going somewhere?", {fontSize: 16}, layoutMode: 'textualBaseline'
    b = layout.toBitmap()
    # assert.eq layout.size.y, 10
    # assert.eq b.size.y, 10
    b

  logBitmapTest "blank lines with layoutAreaWidth", ->
    layout = new Text.Layout "Hi to the world of wonder.\n\nThere is so much fun!", {}, {}, 100
    assert.eq 5, layout.lineCount
    layout.toBitmap()

  test "lolcats", ->
    layout = new Text.Layout "I IZ IN YOUR KIMI\nLIKING ALL UR PHOTOS", {fontFamily:"Impact", fontSize:64}, {layoutMode:"tight"}
    bitmap = layout.toBitmap()
    log bitmap
    assert.within bitmap.size, point(544, 133), point(546, 133)

  test "layoutMode:tight", ->
    layout = new Text.Layout "song", {fontSize:64}, {layoutMode:"tight"}
    bitmap = layout.toBitmap()
    log bitmap
    assert.eq bitmap.size, point 116, 44

  test "layoutMode:tight areas", ->
    layout = new Text.Layout "song", {fontSize:64}, {layoutMode:"tight"}
    bitmap = layout.toBitmap()
    log bitmap
    assert.eq layout.area, rect 0, 0, 116, 44
    assert.eq layout.drawArea, rect -29, -29, 174, 122

  test "precision", ->
    layout = new Text.Layout "hi", fontFamily:"Impact", fontSize:64, layoutMode:"tight"
    bitmap = layout.toBitmap()
    log bitmap

  test "toBitmap scale:2", ->
    layout = new Text.Layout oneLineText
    bitmap = layout.toBitmap scale:2
    log bitmap
    assert.within bitmap.size, point(606, 24), point(614, 24)

  test "multi-lined", ->
    layout = new Text.Layout "Testing multi-line layout.\nLine two."
    log layout.toBitmap()
    assert.eq (fragment.layoutArea.x for fragment in layout.fragments), [0, 0]

  test "center alignment", ->
    layout = new Text.Layout "Testing center alignment.\ncentered", {}, align:"center", 200
    assert.eq
    log layout.toBitmap()
    for fragment in layout.fragments
      assert.eq fragment.alignedLayoutArea.hCenter, 100

  test "right alignment", ->
    layout = new Text.Layout "Testing center alignment.\ncentered", {}, align:"right", 200
    log layout.toBitmap()
    for fragment in layout.fragments
      assert.eq fragment.alignedLayoutArea.right, 200

  test "layoutAreaWidth basic", ->
    layout = new Text.Layout oneLineText + " " + oneLineText, {}, null, 200
    log layout.toBitmap()
    assert.within layout.size.x, 190, 200

  test "layoutAreaWidth with layoutMode: 'textualBaseline'", ->
    layout = new Text.Layout oneLineText + " " + oneLineText, {fontSize: 16}, leading:1, layoutMode: 'textualBaseline', 200
    log layout.toBitmap()
    assert.eq layout.size.y, 16 * 4 - 4

  test "alignmentWidth basic", ->
    layout = new Text.Layout oneLineText + " " + oneLineText, {}, {}, 200
    log layout.toBitmap()
    assert.within layout.size.x, 195, 196

  test "layoutAreaWidth and manual wrap have same height", ->
    wwLayout = new Text.Layout oneLineText + " " + oneLineText, {}, null, 200
    log wordWrapedLayout: wwLayout.toBitmap()

    manualLayout = new Text.Layout "Quickly the brown fox jumps\nover the lazy dog. Quickly the\nbrown fox jumps over the lazy\ndog", {}
    log manualWrappedLayout:manualLayout.toBitmap()
    assert.eq manualLayout.size.y, wwLayout.size.y

  test "layoutAreaWidth long word single", ->
    longWord = "abcdefghijklmnipqrstuvwxyz"
    layout = new Text.Layout longWord, {}, null, 100
    log wordWrapWidthOneLongWord:layout.toBitmap(), layout.size.x
    assert.within layout.size.x, 90, 100

  test "layoutAreaWidth long word after short word", ->
    longWord = "foobar abcdefghijklmnipqrstuvwxyz"
    layout = new Text.Layout longWord, {}, null, 100
    log wordWrapWidthLongWordAfterShortWord:layout.toBitmap(), layout.size.x
    assert.within layout.size.x, 90, 100

  test "layoutAreaWidth two paragraphs", ->
    paragraph1 = "   " + oneLineText + " " + oneLineText
    paragraph2 = "   I said, '" + oneLineText + " " + oneLineText + "'"
    layout = new Text.Layout paragraph1 + "\n" + paragraph2, {}, null, 200
    log wordWrapWidthTwoParagraphs:layout.toBitmap()
    assert.within layout.size.x, 185, 200

  test "layoutAreaWidth centered", ->
    layout = new Text.Layout oneLineText + " " + oneLineText, {}, align:"center", 200
    log wordWrapWidthCentered:layout.toBitmap()
    assert.within layout.size.x, 190, 200

  test "layoutAreaWidth one word centered", ->
    layout = new Text.Layout "hi", {}, align:"center", 200
    log oneWordCentered:layout.toBitmap()
    assert.within layout.size.x, 10, 15


  test "leading", ->
    layout = new Text.Layout "Testing leading: 1.25 (default)\nneeds 2 lines"
    assert.eq (parseInt fragment.layoutArea.y for fragment in layout.fragments), [0, 20]
    log leading_1_25:layout.toBitmap()
    layout = new Text.Layout "Testing leading: 2.0\nneeds 2 lines", {}, leading: 2
    log leading_2_00:layout.toBitmap()
    assert.eq (parseInt fragment.layoutArea.y for fragment in layout.fragments), [0, 32]

  test "layoutAreaWidth, align:'center' and drawArea", ->
    layout = new Text.Layout "hi", {}, align: "center", 300
    assert.eq layout.drawArea.rounded, rect 136, -8, 27, 31

  test "layoutAreaWidth, align:'right' and drawArea", ->
    layout = new Text.Layout "hi", {}, align: "right", 300
    assert.eq layout.drawArea.rounded, rect 280, -8, 27, 31

  test "layoutAreaWidth && alignmentWidth, align:'center' and drawArea", ->
    layout = new Text.Layout "hi", {}, align: "center", 300
    assert.eq layout.area.rounded.w, 12
    assert.eq layout.drawArea.rounded, rect 136, -8, 27, 31

  test "layoutAreaWidth && alignmentWidth, align:'right' and drawArea", ->
    layout = new Text.Layout "hi", {}, align: "right", 300
    assert.eq layout.area.rounded.w, 12
    assert.within layout.drawArea.right, 300, 310
