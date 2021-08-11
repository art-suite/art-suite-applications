Foundation = require '@art-suite/art-foundation'
Atomic = require 'art-atomic'
Engine = require 'art-engine'

{defineModule, inspect, log, bound, flatten, first, second, last} = Foundation
{point, point0, rect, Matrix, matrix} = Atomic
{Element, RectangleElement, PagingScrollElement} = require 'art-engine/Factories'

newPage = (pageNumber, height = 10) ->
  Element key:"page#{pageNumber}", size: ww:1, h:height

newPseWithPages = (heights = 10, numPages = 3)->
  Element
    size: containerHeight = 100
    self.pse = PagingScrollElement null,
      for i in [0...numPages] by 1
        newPage i, heights
  pse

defineModule module, suite:

  structure: ->
    test "basic structure", ->
      (pse = newPseWithPages())
      .onNextReady =>
        assert.eq 1, pse.children.length, "first"
        scrollElement = pse.children[0]
        assert.eq 2, scrollElement.children.length, "second"
        [before, after] = scrollElement.children
        assert.eq 0, before.children.length
        assert.eq 3, after.children.length

    test "basic locations and sizes", ->
      (pse = newPseWithPages())
      .onNextReady =>
        scrollElement = pse.children[0]
        [before, after] = scrollElement.children
        assert.eq point0, scrollElement.currentLocation
        assert.eq 0, pse.scrollPosition
        assert.eq point0, before.currentLocation
        assert.eq point0, after.currentLocation
        assert.eq point(100, 30), scrollElement.currentSize
        assert.eq point(100, 0) , before.currentSize
        assert.eq point(100, 30), after.currentSize

  referenceFrames: ->
    test "setReferenceFrame", ->
      (pse = newPseWithPages())
      .onNextReady =>
        [_, secondChild] = pse.pages
        pse.setReferenceFrame page: secondChild
        pse.onNextReady =>
          assert.eq pse.referenceFrame, page: secondChild
          assert.eq pse.children[0].currentLocation, point 0, 10
          assert.eq pse.scrollPosition, 10

    test "getScrollPositionInReferenceFrame", ->
      (pse = newPseWithPages())
      .onNextReady =>
        [page0, page1, page2] = pse.pages
        assert.eq [0, 10, 20], (pse.getScrollPositionInReferenceFrame page: page for page in pse.pages)

    test "in one epoch, setReferenceFrame then setScrollPositionInReferenceFrame, order shouldn't matter", ->
      (pse = newPseWithPages())
      .onNextReady =>
        [page0, page1] = pse.pages
        pse.setScrollPositionInReferenceFrame 5, page: page0
        pse.setReferenceFrame page: page1
        pse.onNextReady =>
          assert.eq pse.scrollPosition, 15
          assert.eq pse.referenceFrame, page: page1
          assert.eq 5, pse.getScrollPositionInReferenceFrame(page: page0), "page0 referenceFrame"
          assert.eq 15, pse.getScrollPositionInReferenceFrame(page: page1), "page1 referenceFrame"


    test "in one epoch, setScrollPositionInReferenceFrame then setReferenceFrame, order shouldn't matter", ->
      (pse = newPseWithPages())
      .onNextReady =>
        [page0, page1] = pse.pages
        pse.setReferenceFrame page: page1
        pse.setScrollPositionInReferenceFrame 5, page: page0
        pse.onNextReady =>
          assert.eq pse.scrollPosition, 15
          assert.eq pse.referenceFrame, page: page1
          assert.eq 5, pse.getScrollPositionInReferenceFrame(page: page0), "page0 referenceFrame"
          assert.eq 15, pse.getScrollPositionInReferenceFrame(page: page1), "page1 referenceFrame"


  _updateReferenceFrame: ->
    test "PSE - referenceFrame.page == first page", ->
      (pse = newPseWithPages(40))
      .onNextReady =>
        [page0, page1, page2] = pse.pages
        assert.eq page0, pse.getReferenceFrame().page


    test "one page, not quite atStart, should reference atEndEdge", ->
      pse = newPseWithPages 40, 1
      pse.onNextReady =>
        [page0] = pse.pages
        pse.setScrollPosition -1
        pse.onNextReady =>
          assert.eq [pse.scrollPosition, pse.referenceFrame], [-1, atEndEdge: false, page: page0]


    test "_atStart ensures first page is selected", ->
      (pse = newPseWithPages(40))
      .onNextReady =>
        assert.eq pse._atStart, true
        assert.eq pse._atEnd, false
        [page0, page1, page2] = pse.pages
        pse.onNextReady =>
          assert.eq pse.referenceFrame, atEndEdge: false, page: page0
          assert.eq 0, pse.getScrollPositionInReferenceFrame page: page0
          assert.eq 0, pse.getScrollPosition()


    test "_atEnd ensures last page is selected", ->
      pse = newPseWithPages 40
      pse.onNextReady =>
        [page0, page1, page2] = pse.pages
        pse.setScrollPositionInReferenceFrame -20, page:page0
        pse.onNextReady =>
          assert.eq pse._atStart, false
          assert.eq pse._atEnd, true
          pse.onNextReady =>
            assert.eq pse.referenceFrame, atEndEdge: true, page: page2
            assert.eq 100, pse.getScrollPosition()


    test "in the middle selects middle page", ->
      pse = newPseWithPages 40
      pse.onNextReady =>
        [page0, page1, page2] = pse.pages
        pse.setScrollPositionInReferenceFrame -5, page:page0
        pse.onNextReady =>
          assert.eq pse._atStart, false
          assert.eq pse._atEnd, false
          pse.onNextReady =>
            assert.eq pse.referenceFrame, atEndEdge: false, page: page1
            assert.eq -5, pse.getScrollPositionInReferenceFrame page: page0
            assert.eq 35, pse.getScrollPosition()


    test "in a different middle selects middle page, atEndEdge: true", ->
      pse = newPseWithPages 40
      pse.onNextReady =>
        [page0, page1, page2] = pse.pages
        pse.setScrollPositionInReferenceFrame -15, page:page0
        pse.onNextReady =>
          assert.eq pse._atStart, false
          assert.eq pse._atEnd, false
          pse.onNextReady =>
            assert.eq pse.referenceFrame, atEndEdge: true, page: page1
            assert.eq -15, pse.getScrollPositionInReferenceFrame page: page0
            assert.eq 65, pse.getScrollPosition()


  addingElements:
    atStart: ->

      test "adding page should not change referenceFrame or scrollPosition", ->
        (pse = newPseWithPages(40, 1))
        .onNextReady =>
          assert.eq true, pse.atStart
          assert.eq "page0", (page.key for page in pse.pages).join ', '

          {scrollPosition, referenceFrame} = pse
          assert.eq scrollPosition, 0
          assert.eq referenceFrame, atEndEdge: false, page: first pse.pages

          pse.pages = flatten pse.pages, newPage 1
          pse.onNextReady =>
            assert.eq "page0, page1", (page.key for page in pse.pages).join ', '
            assert.eq pse.scrollPosition, scrollPosition
            assert.eq pse.referenceFrame, referenceFrame


      test "adding page before should change referenceFrame to the page", ->
        pse = newPseWithPages 40
        pse.onNextReady =>
          assert.eq true, pse.atStart
          pse.pages = flatten newPage(-1), pse.pages
          assert.eq pse.referenceFrame, atEndEdge: false, page: first pse.pages
          assert.eq 0, pse.scrollPosition
          pse.onNextReady =>
            assert.eq "page-1, page0, page1, page2", (page.key for page in pse.pages).join ', '
            assert.eq pse.referenceFrame, atEndEdge: false, page: first pse.pages
            assert.eq 0, pse.scrollPosition


    inMiddle: ->
      suite "not atEndEdge", ->
        test "adding page before referenceFrame.page should not change referenceFrame or scrollPosition", ->
          pse = newPseWithPages 40
          pse.setScrollPosition -5
          pse.onNextReady =>
            pse._updateReferenceFrame()
            pse.onNextReady =>
              assert.eq true, pse.inMiddle
              assert.eq "page0, page1, page2", (page.key for page in pse.pages).join ', '

              {referenceFrame, scrollPosition, pages} = pse
              [page0, page1, page2] = pse.pages

              assert.eq 35, scrollPosition
              assert.eq referenceFrame, atEndEdge:false, page:page1

              pse.pages = flatten page0, newPage("A"), page1, page2

              pse.onNextReady =>
                assert.eq "page0, pageA, page1, page2", (page.key for page in pse.pages).join ', '
                assert.eq pse.referenceFrame, referenceFrame
                assert.eq pse.scrollPosition, scrollPosition


        test "adding page after referenceFrame.page should not change referenceFrame or scrollPosition", ->
          pse = newPseWithPages 40
          pse.setScrollPosition -5
          pse.onNextReady =>
            pse._updateReferenceFrame()
            pse.onNextReady =>
              assert.eq true, pse.inMiddle
              assert.eq "page0, page1, page2", (page.key for page in pse.pages).join ', '

              {referenceFrame, scrollPosition, pages} = pse
              [page0, page1, page2] = pse.pages

              assert.eq 35, scrollPosition
              assert.eq referenceFrame, atEndEdge:false, page:page1

              pse.pages = flatten page0, page1, newPage("A"), page2

              pse.onNextReady =>
                assert.eq "page0, page1, pageA, page2", (page.key for page in pse.pages).join ', '
                assert.eq pse.referenceFrame, referenceFrame
                assert.eq pse.scrollPosition, scrollPosition


      suite "and atEndEdge", ->
        test "adding page before referenceFrame.page should not change referenceFrame or scrollPosition", ->
          pse = newPseWithPages 40
          pse.setScrollPosition -15
          pse.onNextReady =>
            pse._updateReferenceFrame()
            pse.onNextReady =>
              assert.eq "page0, page1, page2", (page.key for page in pse.pages).join ', '

              {referenceFrame, scrollPosition, pages} = pse
              [page0, page1, page2] = pse.pages

              assert.eq referenceFrame, atEndEdge:true, page:page1
              assert.eq 65, scrollPosition
              assert.eq true, pse.inMiddle

              pse.pages = flatten page0, newPage("A"), page1, page2

              pse.onNextReady =>
                assert.eq "page0, pageA, page1, page2", (page.key for page in pse.pages).join ', '
                assert.eq pse.referenceFrame, referenceFrame
                assert.eq pse.scrollPosition, scrollPosition


        test "adding page after referenceFrame.page should not change referenceFrame or scrollPosition", ->
          pse = newPseWithPages 40
          pse.setScrollPosition -15
          pse.onNextReady =>
            pse._updateReferenceFrame()
            pse.onNextReady =>
              assert.eq "page0, page1, page2", (page.key for page in pse.pages).join ', '

              {referenceFrame, scrollPosition, pages} = pse
              [page0, page1, page2] = pse.pages

              assert.eq referenceFrame, atEndEdge:true, page:page1
              assert.eq 65, scrollPosition
              assert.eq true, pse.inMiddle

              pse.pages = flatten page0, page1, newPage("A"), page2

              pse.onNextReady =>
                assert.eq "page0, page1, pageA, page2", (page.key for page in pse.pages).join ', '
                assert.eq pse.referenceFrame, referenceFrame
                assert.eq pse.scrollPosition, scrollPosition


    atEnd: ->
      test "adding page after last should change referenceFrame to the page", ->
        pse = newPseWithPages 40
        pse.onNextReady =>
          pse.jumpToEnd()
          pse.onNextReady =>
            assert.eq true, pse.atEnd
            assert.eq false, pse.pagesFitInWindow
            pse.pages = flatten pse.pages, newPage "A"
            # assert.eq pse.referenceFrame, atEndEdge: false, page: first pse.pages
            pse.onNextReady =>
              assert.eq "page0, page1, page2, pageA", (page.key for page in pse.pages).join ', '
              assert.eq true, pse.atEnd
              assert.eq pse.referenceFrame, atEndEdge: true, page: last pse.pages

