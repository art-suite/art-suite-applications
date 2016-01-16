###
#TODO

refactor to an object you create
if either tight or tight0 are requested, calculate both
for textual, have two areas:
  textualArea - the current area we compute based on font-size and glyph width
  textualDrawArea - a pessimistic, but always true, area that covers all pixels
    since we have no concrete information on this, we'll just make it something like 2x textualArea - or more

###
define [
  'art.foundation'
  'art.atomic'
  'art.canvas'
], (Foundation, Atomic, Canvas) ->

  {point, rect, point0} = Atomic
  {log, BaseObject, inspect} = Foundation

  # layoutLocation - the upper-left corner of the layout area
  #   layout area is the exact area if using tight0 - otherwise it is the textual area
  # layoutSize
  # textLocationOffset - the offsets to add to layoutLocation to get the coordinates to pass to Canvas for drawing
  # drawAreaOffset - add to layoutLocation to get the drawArea location
  # drawAreaSize - size of the draw area
  class TextLayoutFragment extends BaseObject

    constructor: (
          @text
          @font
          @ascender
          @descender

          @textOffsetX
          @textOffsetY
          @layoutW
          @layoutH

          @drawAreaX
          @drawAreaY
          @drawAreaW
          @drawAreaH
        ) ->
      @layoutX = @layoutY = 0
      @alignmentOffsetX = 0
      @alignmentOffsetY = 0

    toString: ->
      inspect @toPlainObject()

    toPlainObject: ->
      text:@text
      font:@font
      ascender:@ascender
      descender:@descender
      textOffsetX:@textOffsetX
      textOffsetY:@textOffsetY

      layoutX:@layoutX
      layoutY:@layoutY

      layoutW:@layoutW
      layoutH:@layoutH
      drawAreaX:@drawAreaX
      drawAreaY:@drawAreaY
      drawAreaW:@drawAreaW
      drawAreaH:@drawAreaH
      alignmentOffsetX:@alignmentOffsetX
      alignmentOffsetY:@alignmentOffsetY

    clone: ->
      new TextLayoutFragment(
        @text
        @font
        @ascender
        @descender

        @textOffsetX
        @textOffsetY
        @layoutW
        @layoutH

        @drawAreaX
        @drawAreaY
        @drawAreaW
        @drawAreaH
      )

    move: (x, y) ->
      @moveX x
      @moveY y

    moveX: (x) ->
      @layoutX += x
      @drawAreaX += x

    moveY: (y) ->
      @layoutY += y
      @drawAreaY += y

    setLayoutLocationFrom: (fragment) ->
      @layoutX = fragment.layoutX
      @layoutY = fragment.layoutY

    @getter
      left:   -> @getAlignedLayoutX()
      top:    -> @getAlignedLayoutY()
      bottom: -> @getAlignedLayoutY() + @layoutH
      right:  -> @getAlignedLayoutX() + @layoutW

      alignedLayoutX:    -> @layoutX + @alignmentOffsetX
      alignedLayoutY:    -> @layoutY + @alignmentOffsetY
      alignedDrawAreaX:  -> @drawAreaX + @alignmentOffsetX
      alignedDrawAreaY:  -> @drawAreaY + @alignmentOffsetY
      layoutArea:        -> rect @layoutX, @layoutY, @layoutW, @layoutH
      alignedLayoutArea: -> rect @getAlignedLayoutX(),   @getAlignedLayoutY(),   @layoutW,   @layoutH
      alignedDrawArea:   -> rect @getAlignedDrawAreaX(), @getAlignedDrawAreaY(), @drawAreaW, @drawAreaH

      alignedDrawAreaLeft:   -> @getAlignedDrawAreaX()
      alignedDrawAreaTop:    -> @getAlignedDrawAreaY()
      alignedDrawAreaRight:  -> @getAlignedDrawAreaX() + @drawAreaW
      alignedDrawAreaBottom: -> @getAlignedDrawAreaY() + @drawAreaH

      # DEPRICATED
      area: ->
        console.error "TextLayoutFragment.area is DEPRICATED. Use: TextLayoutFragment#layoutArea"
        rect @layoutX - @textOffsetX, @layoutY - @textOffsetY, @layoutW, @layoutH
      textX: -> @layoutX + @textOffsetX + @alignmentOffsetX
      textY: -> @layoutY + @textOffsetY + @alignmentOffsetY
