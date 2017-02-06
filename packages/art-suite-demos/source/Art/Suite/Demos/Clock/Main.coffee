{
  defineModule
  createWithPostCreate
  log, merge
  w
  point
  Element, RectangleElement, TextElement, OutlineElement, FillElement, PagingScrollElement, Component
  FluxComponent
} = require 'art-suite'

require './CurrentTime'

defineModule module, ->
  thinLength = 15

  Hand = createWithPostCreate class Hand extends FluxComponent

    render: ->
      {angle, length, width, radius, color} = @props
      Element
        size: yh: length, w:width
        axis: "bottomCenter"
        location: ps: .5
        animate:
          f: "easeInBounce"
          to: angle: angle

        RectangleElement
          color: color
          axis: "topCenter"
          size: h:thinLength, w: 1
          location: xw: .5, yh: 1, y: -thinLength

        RectangleElement
          color: color
          size: ps: 1, h:-thinLength
          radius: radius | 0

  DateComponent = createWithPostCreate class DateComponent extends FluxComponent

    render: ->
      months = w "January February March April May June July August September October November December"
      d = new Date
      Element
        size: xw: .45, hch:1
        location: ps: .5
        TextElement
          size: cs:1
          location: xw: .5
          axis: .5
          fontFamily: "'HelveticaNeue-Light', sans-serif"
          color: "#444"
          text: "#{months[d.getMonth()]} #{d.getDate()} #{d.getYear() + 1900}"
          RectangleElement
            padding: -10
            color: "#ddd"
            OutlineElement()
          FillElement()

  ClockFace = createWithPostCreate class ClockFace extends FluxComponent
    @subscriptions "currentTime.second"

    render: ->
      log "render clock"
      {total} = @models.currentTime
      Element
        size: (ps) -> ps.min()
        location: ps: .5
        axis: .5
        padding: 20

        DateComponent()

        for i in [1..12]
          RectangleElement
            size: ww:.05, h:2
            axis: point -9, .5
            location: ps: .5
            angle: Math.PI * 2 * i / 12

        Hand length: .475, color: "orange", width: 2, angle: Math.PI * 2 * total / 60
        Hand length: .4, width: 4, angle: Math.PI * 2 * total / (60 * 60)
        Hand length: .2, width: 4, angle: Math.PI * 2 * total / (60 * 60 * 12)

  class Clock extends Component

    render: ->

      Element null,
        RectangleElement color: "white"
        ClockFace()
