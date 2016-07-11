Foundation = require "art-foundation"
React = require "art-react"
Atomic = require "art-atomic"

{log} = Foundation
{
  createComponentFactory
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
} = React
{rgbColor, point} = Atomic

animateColors = ({animationSeconds, element, options:{color1, color2}}) ->
  animationPeriod = 3
  animationPos = (animationSeconds % animationPeriod) / animationPeriod
  out =
    0: endsColor = rgbColor(color1).interpolate color2, animationPos
    1: endsColor
  out[animationPos] = color1
  out[animationPos + .0001] = color2
  out

module.exports = createComponentFactory class MyComponent extends Component
  module: module

  render: ->
    {location} = @state

    Element null,

      RectangleElement color: "white"

      RectangleElement
        size: w:200, h: 20
        radius: 50
        axis: .5
        location: ps: .5
        to: (ps) -> ps.max()
        animators:
          colors:
            animate: animateColors
            continuous: true # animation starts immediately
            color1: "#af0"
            color2: "#ff0"

