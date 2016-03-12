Foundation = require "art-foundation"
React = require 'art-react'
Atomic = require 'art-atomic'
Flux = require 'art-flux'

{Animator} = Neptune.Art.Engine.Animation

require './models'

{
  log, merge, clone, peek, inspect, timeout, Browser, intRand
  isNumber, shallowClone, iPart, min, max
} = Foundation

{point} = Atomic
{Element, Rectangle, TextElement, Outline, Fill, PagingScrollElement, Component, createComponentFactory} = React
{FluxComponent, createFluxComponentFactory} = Flux

StyleProps =
  numberStyle:
    fontFamily: "arial"
    fontWeight: "bold"
    fontSize: 20
    location: ps:.5
    size: cs: 1
    axis: .5

backgroundColor = "#eee"
colorMap=
  red:    "#E42030"
  green:  "#25B650"
  yellow: "#ff4"
  blue:   "#22489F"
  grey: backgroundColor

textColorMap=
  red:    "#E42030"
  green:  "#25B650"
  yellow: "#cc2"
  blue:   "#22489F"
  grey:   "#ccc"

boardNums =
  red:    [2,3,4,5,6,7,8,9,10,11,12,"L"]
  yellow: [2,3,4,5,6,7,8,9,10,11,12,"L"]
  green:  [12,11,10,9,8,7,6,5,4,3,2,"L"]
  blue:   [12,11,10,9,8,7,6,5,4,3,2,"L"]
  grey:   [-5, -5, -5, -5]

colors = Object.keys boardNums

ColorCheckBox = createFluxComponentFactory
  toggleCheckbox: ->
    @models.quixx.toggleCheckbox @props.color, @props.index
    # @props.boardComponent.toggleCheckbox @props.color, @props.index
  module: module

  render: ->
    Element
      size: 40
      padding: 1
      cursor: "pointer"
      on: pointerClick: @toggleCheckbox

      Rectangle

        radius: if @props.text != "L" then 5 else 1000
        color: "white"

      if @props.checked
        TextElement
          key: "x"
          location: ps:.5
          size: cs:1
          axis: .5
          addedAnimation:   duration: .25, f: "easeInQuad", from: opacity: 0
          removedAnimation: duration: .25, f: "easeInQuad", to: opacity: 0
          fontFamily: "arial"
          text: "╳"
          color: textColorMap[@props.color]
          layoutMode: "tight"
          fontSize: 38

      TextElement StyleProps.numberStyle,
        angle: if @props.text != "L" then 0 else Math.PI/12
        text: @props.text
        color: textColorMap[@props.color]

ColorRow = createFluxComponentFactory
  module: module

  render: ->
    {color, nums} = @props

    Element
      size: ww:1, hch:1
      padding: 2

      Rectangle color: colorMap[color], inFlow: false

      if color != "grey"
        TextElement
          size: cs:1
          location: y:24
          axis: point .66, .5
          fontSize: 28
          text: "►"
          layoutMode: "tight"
          inFlow: false
          color: "black"
          Outline color: backgroundColor, lineWidth:3
          Fill()

      Element
        location: xw:.5
        size:
          hch:1
          w: (ps, cs) -> min ps.w, cs.w
        axis: point .5, 0
        padding: 4
        childrenLayout: "flow"

        Rectangle
          radius: 7
          padding: -1

          inFlow: false
          color: "#0004"

        Element
          size: cs: 1
          childrenLayout: "flow"
          for i in [0...nums.length / 2] by 1
            ColorCheckBox
              color: color
              index: i
              checked: @props.checks[i]
              text: nums[i]
              boardComponent: @props.boardComponent
        Element
          size: cs: 1
          childrenLayout: "flow"
          for i in [nums.length / 2...nums.length] by 1
            ColorCheckBox
              color: color
              index: i
              checked: @props.checks[i]
              text: nums[i]
              boardComponent: @props.boardComponent

ColorScore = createComponentFactory class ColorScore extends Component
  module: module
  getInitialState: -> score: @props.score

  componentWillReceiveProps: (nextProps = {}) ->
    new Animator @,
      from: score: @props.score
      to: score: nextProps.score
      duration: .25
      f: "easeInQuad"

  @setter score: (score) -> @setState "score", iPart score

  render: ->
    Element
      size: w: @props.width || 45, h:35
      margin: 7

      Rectangle

        radius: 10
        Fill color: "white"
        Outline
          lineWidth: 4
          color: textColorMap[@props.color] || @props.color

      TextElement StyleProps.numberStyle,
        text: @state.score
        color: textColorMap[@props.color] || @props.color

Logo = createComponentFactory
  module: module
  render: ->
    Element
      key: "logo"
      size: ww:1, h: 80

      Rectangle colors: ["#002", "#369"], to: point 0, 1

      TextElement
        text: "Qwixx"
        location: ps:.5
        axis: .5
        color: "white"
        fontWeight: "bold"
        fontFamily: "Chewy"
        fontSize: 48
        Fill()
        Outline
          color: "#0247"
          lineWidth: 3
          compositeMode: "destover"
        Outline
          lineJoin: "round"
          color: "#48ca"
          lineWidth: 5
          compositeMode: "destover"

module.exports = createComponentFactory class Quixx extends FluxComponent
  module: module
  @subscriptions "quixx.board quixx.subScores quixx.score"

  reset: -> @models.quixx.reset()

  render: ->
    {board, subScores, score} = @state

    Element null,
      Rectangle color: backgroundColor, inFlow: false

      PagingScrollElement null,

        Element
          key: "qwixx"
          size: ww:1, hch:1
          childrenLayout: "flow"

          Logo()

          Element
            key: "board"
            size: ww:1, hch:1
            padding: 10
            childrenLayout: "flow"
            for c, nums of board
              ColorRow
                checks: board[c]
                color: c
                nums: boardNums[c]

          Element
            key: "scores"
            size: ww:1, hch:1
            childrenLayout: "flow"

            Rectangle color: "#999", inFlow: false

            Element
              size: ww:1, hch:1
              padding: 10
              childrenLayout: "flow"
              for c, i in colors
                [
                  ColorScore color: c, score: subScores[c]
                  TextElement
                    text: if i == colors.length-1 then "=" else "+"
                    color: "#777"
                    fontFamily: "Arial"
                    fontSize: 28
                    Fill()
                ]
              ColorScore width: 100, color: "black", score: score

          Element
            key: "reset"
            size: ww:1, h:60
            padding: 10
            cursor: "pointer"
            on: pointerClick: @reset

            Rectangle color: textColorMap["grey"], radius: 5

            TextElement StyleProps.numberStyle,
              text: "reset"
              color: colorMap["grey"]

