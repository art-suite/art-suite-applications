Foundation = require "art-foundation"
{Bitmap} = require "art-canvas"
Atomic = require 'art-atomic'
Metrics = require './metrics'
{rect, matrix, Matrix, Rectangle, point} = Atomic
{floor, ceil} = Math

{
  log, inspect, pureMerge, flatten, BaseObject, nearInfinity, nearInfinityResult, peek,
  min, max, merge, time, isNumber
  float32Eq
  float32Eq0
} = Foundation

{toFontCss} = Metrics
emptyOptions = {}

#options
#   text: "the text to layout"
#   align: "left" (default), "right", "center"
#   leading: 1.25 (default)
#
#These 'fontOptions' are passed directly to Metrics
#  fontStyle:   see standard CSS styles
#  fontVariant: see standard CSS styles
#  fontWeight:  see standard CSS styles
#  fontFamily:  see standard CSS styles
#  fontSize:    # in screen units (pixels == pixelsPerPoint * fontSize)
#  layoutMode:  "textual" (default), "tight", "tight0"
module.exports = class Layout extends BaseObject
  @defaultText: defaultText = ""
  @defaultLayoutOptions: defaultLayoutOptions =
    leading:    1.25
    align:      point "left"
    layoutMode: "textualBaseline"
    overflow:   "ellipsis" # "visible", "clipped" or "ellipsis"
    # vAlign:     "top" # "middle"/"center" or "bottom"
    maxLines:   undefined
    # TODO: paragraphLeading: 1.25 # multiple of fontSize - becomes the leading between lines separated by new-line

  wordStringToHash = (wordString) ->
    ret = {}
    for word in wordString.split /\s+/
      ret[word] = true
    ret

  @validLayoutOptions:
    layoutMode: wordStringToHash "textual textualBaseline tight tight0"
    overflow: wordStringToHash "ellipsis visible clipped"

  constructor: (text, fontOptions, layoutOptions, layoutAreaWidth = nearInfinity, layoutAreaHeight = nearInfinity) ->
    throw new Error "layoutAreaWidth, layoutAreaHeight must be numbers: #{inspect layoutAreaHeight}" unless isNumber(layoutAreaWidth) && isNumber(layoutAreaHeight)
    @_layoutAreaWidth = layoutAreaWidth
    @_layoutAreaHeight = layoutAreaHeight
    @_fontOptions = Metrics.normalizeFontOptions fontOptions || {}
    @_layoutOptions = layoutOptions = pureMerge defaultLayoutOptions, layoutOptions
    @_text = text || defaultText
    @_textLines = text.split "\n"
    if layoutOptions.wordWrapWidth
      console.error "Art.Text.Layout#wordWrapWidth is depricated. Pass layoutAreaWidth and layoutAreaHeight into constructor."

    # @_wordWrapWidth = layoutOptions.wordWrapWidth
    # @_wordWrapWidth = 0 if @_wordWrapWidth? && @_wordWrapWidth < 0
    @_maxHeight = layoutOptions.maxHeight
    @_overflow = layoutOptions.overflow
    @_clipped = @_overflow == "clipped"
    @_ellipsis = @_overflow == "ellipsis"
    @_align = point layoutOptions.align
    @_leading = layoutOptions.leading
    # @_vAlign = layoutOptions.vAlign
    @_maxLines = layoutOptions.maxLines
    @_layoutMode = layoutOptions.layoutMode
    @_resetLayout()

    @_left = @_right = @_top = @_bottom = 0

  @getter "text align leading"

  @getter
    fontStyle:      -> @_fontOptions.fontStyle
    fontVariant:    -> @_fontOptions.fontVariant
    fontWeight:     -> @_fontOptions.fontWeight
    fontFamily:     -> @_fontOptions.fontFamily
    fontSize:       -> @_fontOptions.fontSize

    leading:        -> @_leading
    align:          -> @_align
    layoutMode:     -> @_layoutMode

    fragments:      -> @_updateLayout(); @_fragments
    size:           -> @_updateLayout(); @_size ||= point @_right - @_left, @_bottom - @_top
    area:           -> @_updateLayout(); @_area ||= rect @_left, @_top, @_right - @_left, @_bottom - @_top
    drawArea:       -> @_updateLayout(); @_drawArea ||= @_computeDrawArea()
    fontCss:        -> @_fontCss ||= toFontCss @_fontOptions
    lineCount:      -> @_updateLayout(); @_fragments.length

  # used only for testing to get the actual location of all fragments
  _getFragmentLogicalAreas: (layoutHeight) ->
    layoutArea for {layoutArea} in @fragments

  # options:
  #   color: "black" # any acceptable Atomic.Color
  draw: (target, where, options=emptyOptions)->
    context = target.context2D
    return @drawToNonArtBitmap target, where, options unless context
    @_updateLayout()

    if target._setupDraw where, options

      context.font = @getFontCss()
      context.textAlign = 'left'
      context.textBaseline = 'alphabetic'

      if options.stroke
        @_strokeAllFragments context
      else
        @_fillAllFragments context

      target._cleanupDraw options

  stroke: (target, where, options=emptyOptions)->
    @draw target, where, merge options, stroke: true

  drawToNonArtBitmap: (target, where, options=emptyOptions)->
    scale = where.exactScale
    bitmap2D = new Bitmap @getSize().mul scale
    @draw bitmap2D, Matrix.scale(scale), options
    target.drawBitmap Matrix.scale(scale.inv).mul(where), bitmap2D

  newBitmap: (options=emptyOptions) ->
    size = options.size || @getSize()
    size = size.withX @_layoutAreaWidth if @_align.x > 0 && @_layoutAreaWidth < nearInfinityResult
    size = size.withY @_layoutAreaHeight if @_align.y > 0 && @_layoutAreaHeight < nearInfinityResult
    size = size.mul scale if scale = options.scale
    new Bitmap size

  #options:
  #  (all of draw's options)
  #  size: @getSize()            # bitmap's pixel size
  #  drawMatrix: matrix()   # custom draw matrix
  #  scale: 1               # number or Point - multiplies both size and drawMatrix
  toBitmap: (options=emptyOptions)->
    drawMatrix = options.drawMatrix || new Matrix
    if scale = options.scale
      drawMatrix = drawMatrix.mul Matrix.scale(scale)
    bitmap = @newBitmap options
    @draw bitmap, drawMatrix, options
    bitmap

  ####################
  # PRIVATE
  ####################
  _fillAllFragments: (context)->
    for frag in @fragments
      context.fillText frag.text, frag.getTextX(), frag.getTextY()

  _strokeAllFragments: (context)->
    for frag in @fragments
      context.strokeText frag.text, frag.getTextX(), frag.getTextY()

  _drawFragmentAreas: (context) ->
    fontSize = @getFontSize()
    for frag in @fragments
      {layoutArea} = frag
      context.fillRect layoutArea.x, layoutArea.y, layoutArea.w, layoutArea.h

  _computeDrawArea: ->
    {fragments} = @
    if fragments.length == 1
      fragments[0].alignedDrawArea
    else
      left = top = right = bottom = 0
      for fragment, i in fragments
        if i == 0
          left    = fragment.getAlignedDrawAreaLeft()
          top     = fragment.getAlignedDrawAreaTop()
          right   = fragment.getAlignedDrawAreaRight()
          bottom  = fragment.getAlignedDrawAreaBottom()
        else
          left    = min left  , fragment.getAlignedDrawAreaLeft()
          top     = min top   , fragment.getAlignedDrawAreaTop()
          right   = max right , fragment.getAlignedDrawAreaRight()
          bottom  = max bottom, fragment.getAlignedDrawAreaBottom()

      new Rectangle left, top, right-left, bottom-top

  _alignFragments: ->
    {_layoutAreaWidth, _layoutAreaHeight, _align, area} = @

    xAlign = _align.x
    yAlign = _align.y

    # log _alignFragments:
    #   _layoutAreaHeight: _layoutAreaHeight
    #   _layoutAreaWidth: _layoutAreaWidth
    #   _align: _align
    #   area: area

    xAlign = 0 if _layoutAreaWidth >= nearInfinityResult
    yAlign = 0 if _layoutAreaHeight >= nearInfinityResult

    offsetY = (_layoutAreaHeight - area.h) * yAlign

    return if float32Eq0(offsetY) && float32Eq0 xAlign

    # console.error "SHOULD ONLY ALIGN FRAGMENTS ONCE: #{_layoutAreaWidth}"
    for frag in @fragments
      frag.alignmentOffsetX = (_layoutAreaWidth - frag.layoutW) * xAlign
      frag.alignmentOffsetY = offsetY

  _setArea: (fragment) ->
    @_top     = fragment.getTop()
    @_left    = fragment.getLeft()
    @_bottom  = fragment.getBottom()
    @_right   = fragment.getRight()

  _expandArea: (fragment) ->
    @_top     = min @_top,    fragment.getTop()
    @_left    = min @_left,   fragment.getLeft()
    @_bottom  = max @_bottom, fragment.getBottom()
    @_right   = max @_right,  fragment.getRight()

  _generateFragments: ->
    {_fontOptions, _layoutAreaWidth, _layoutMode, _textLines, _fontOptions} = @
    fontCss = @getFontCss()

    @_fragments = if _layoutAreaWidth < nearInfinityResult && (_layoutMode == "textual" || _layoutMode == "textualBaseline")
      fragments = []
      for text in _textLines
        wrappedFragments = Metrics.wrap text, _fontOptions, _layoutAreaWidth, fontCss, _layoutMode
        for fragment in wrappedFragments
          fragments.push fragment
      fragments
    else
      for text in _textLines
        Metrics.get text, _fontOptions, _layoutMode, fontCss

  _layoutFragments: ->
    {_layoutAreaWidth, _layoutAreaHeight, _maxLines, _clipped, _ellipsis} = @

    offsetX = 0
    offsetY = 0
    effectiveLeading = @getFontSize() * @getLeading()

    allFragments = @_fragments

    if _maxLines && _maxLines < @_fragments.length
      @_fragments = @_fragments.slice 0, _maxLines

    for fragment, i in @_fragments

      fragment.move offsetX, offsetY

      # always include one line
      if i == 0
        @_setArea fragment
      else
        if _clipped
          # include last partial line
          # Why? So the last text line can be draw-clipped
          if fragment.getTop() - @_top > _layoutAreaHeight
            @_fragments = @_fragments.slice 0, i
            break
        else if _ellipsis
          # don't include last partial line
          if fragment.getBottom() - @_top > _layoutAreaHeight
            @_fragments = @_fragments.slice 0, i
            break

        @_expandArea fragment

      offsetY += effectiveLeading

    if _ellipsis && @_fragments.length < allFragments.length
      text = peek(@_fragments).text
      if text[text.length - 1] == "."
        text = text.slice 0, text.length - 1

      textWithEllipsis = text + "…"
      while text.length > 0 && (m = (Metrics.get textWithEllipsis, @_fontOptions, @_layoutMode, @getFontCss())).layoutW > _layoutAreaWidth
        text = text.slice 0, text.length - 1
        textWithEllipsis = text + "…"

      if m
        m.setLayoutLocationFrom peek @_fragments
        @_fragments[@_fragments.length - 1] = m
        @_expandArea m

  _resetLayout: ->
    @_fragments = @_area = @_size = @_drawArea = null

  _updateLayout: ->
    return if @_fragments

    @_resetLayout()
    @_generateFragments()
    @_layoutFragments()
    @_alignFragments()

  @setter
    width: (width)->
      @_updateLayout()
      if !float32Eq width, @_layoutAreaWidth
        @_layoutAreaWidth = width
        @_area = null
        @_size = null
        @_drawArea = null
        @_alignFragments()
      null

