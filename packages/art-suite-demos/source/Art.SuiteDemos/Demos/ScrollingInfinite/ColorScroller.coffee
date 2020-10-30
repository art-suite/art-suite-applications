{
  log, max, modulo, round
  hslColor
  Component
  Element
  RectangleElement
  PagingScrollElement
  TextElement
  defineModule
  createWithPostCreate
} = require 'art-suite'

defineModule module, ->

  ColorElement = createWithPostCreate class ColorElement extends Component

    getInitialState: -> height: 160

    click: -> {height} = @state; @setState height: if height == 320 then 160 else 320

    render: ->
      {hue, key} = @props
      {height} = @state

      Element
        size:     ww:1, h:160
        key:      key
        on:       pointerClick: @click

        RectangleElement color: hslColor hue, 1, 1
        TextElement
          location: ps: .5
          axis:     .5
          fontSize: 128
          color:    "#0007"
          text:     "#{round hue * 360}°"

  ColorScrollerContents = createWithPostCreate class ColorScrollerContents extends Component

    getInitialState: ->
      focusedPageIndex: 0
      pageSpread: 0
      handlers:
        preprocess:
          scrollUpdate: ({props}) ->
            {focusedPage, currentGeometry} = props
            focusedPageIndex: focusedPage.key | 0
            pageSpread:       currentGeometry.suggestedPageSpread
        scrollUpdate:   (stateUpdate) => @setState stateUpdate

    render: ->
      {focusedPageIndex, pageSpread, handlers} = @state
      firstPageIndex = max(0, focusedPageIndex - pageSpread)
      lastPageIndex = focusedPageIndex + pageSpread

      PagingScrollElement
        padding:  5
        scroll:   "vertical"
        on:       handlers
        for pageIndex in [firstPageIndex .. lastPageIndex] by 1
          ColorElement key: pageIndex, hue: modulo pageIndex / 24, 1

  class ColorScroller extends Component

    render: ->
      Element null,

        RectangleElement color: "#333"

        ColorScrollerContents()
