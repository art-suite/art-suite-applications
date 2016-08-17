{log, capitalize, merge} = Foundation = require "art-foundation"
{
  createComponentFactory
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
} = require "art-react"
{point, hslColor, rgbColor} = require "art-atomic"

textProps =
  fontSize: 16
  fontFamily: "sans-serif"
  color: "#fffc"
  align: .5
  size: ps: 1
  padding: 10

standardShadowProps =
  color:    "#0007"
  blur:     20
  offset:   y: 5


AbstractButton = createComponentFactory
  module: module

  showWillActivate: -> @setState willActivate: true
  showWontActivate: -> @setState willActivate: false

  render: ->
    {willActivate} = @state
    {component} = @props

    Element
      margin: 10
      size: w: 200, h: 100
      cursor: "pointer"
      on:
        pointerDown: @showWillActivate
        pointerUp: @showWontActivate
      component @props, willActivate: willActivate

ShadowButton = createComponentFactory
  module: module
  render: ->
    {willActivate, color} = @props
    Element null,
      RectangleElement
        color:    color
        animators: shadow: duration: .1
        shadow: if willActivate
          merge standardShadowProps,
            blur:     5
            offset:   y: 5/4
        else
          standardShadowProps
      TextElement textProps,
        text: "Shadow"

TextAlignButton = createComponentFactory
  module: module
  render: ->
    {willActivate, color} = @props
    Element null,
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "align"
        align: if willActivate then y:.5 else .5
        text: "Text\nAlignment"

TextLeadingButton = createComponentFactory
  module: module
  render: ->
    {willActivate, color} = @props
    Element null,
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "leading"
        leading: if willActivate then 2 else 1.25
        text: "Text\nLeading"


FontSizeButton = createComponentFactory
  module: module
  render: ->
    {willActivate, color} = @props
    Element null,
      RectangleElement color: color, shadow: standardShadowProps
      Element
        clip: true
        TextElement textProps,
          size: cs: 1
          location: ps: .5
          axis: .5
          animators: "fontSize"
          fontSize: if willActivate then 100 else textProps.fontSize
          text: "Font Size"


ContinuousButton = createComponentFactory
  module: module
  render: ->
    {willActivate, color} = @props
    Element null,
      RectangleElement
        color: color
        shadow: standardShadowProps
        to: "bottomRight"
        animators: if willActivate
          colors:
            animate: ({animationPos, options:{color1, color2}}) ->
              out =
                0: endsColor = rgbColor(color1).interpolate color2, animationPos
                1: endsColor
              out[animationPos] = color1
              out[animationPos + .0001] = color2
              out
            period: 1
            color1: color
            color2: color.lightness * .5

      Element
        clip: true
        TextElement textProps,
          size: cs: 1
          location: ps: .5
          axis: .5
          text: "Continuous Animation"


Button1 = createComponentFactory
  module: module

  showWillActivate: -> @setState willActivate: true
  showWontActivate: -> @setState willActivate: false

  render: ->
    {willActivate} = @state
    {mode, clr} = @props
    mode ||= "rotate"

    Element
      margin: 10
      size: w: 200, h: 100
      cursor: "pointer"
      on:
        pointerDown: @showWillActivate
        pointerUp: @showWontActivate
      Element
        cacheDraw: true
        if mode != "squishLeft"
          axis: .5
          location: ps: .5
        else
          axis: 0
        animate:
          switch mode
            when "opacity"
              to: opacity: if willActivate then .5 else 1
            when "spin"
              duration: .5
              to: angle: if willActivate then 2*Math.PI else 0
            when "both"
              to: if willActivate
                scale: .5
                angle: -Math.PI / 2
              else
                scale: 1
                angle: 0
            else
              f: "easeInElastic"
              duration: .5
              to:
                switch mode
                  when "scale"
                    scale: if willActivate then .9 else 1
                  when "squish"
                    scale: if willActivate then point .8, 1 else 1
                  when "squishLeft"
                    scale: if willActivate then point .25, 1 else 1
                  when "angle"
                    angle: if willActivate then Math.PI/12 else 0
        RectangleElement color: clr, shadow: standardShadowProps
        TextElement textProps,
          text: capitalize mode

module.exports = createComponentFactory class MyComponent extends Component
  module: module

  render: ->

    Element
      childrenLayout: "flow"
      padding: 10
      RectangleElement inFlow: false, color: "#ddd", padding: -10

      Button1 mode: "angle",      clr: hslColor 6/10, .66, .6
      Button1 mode: "spin",       clr: hslColor 7/10, .66, .6
      Button1 mode: "scale",      clr: hslColor 4/10, .66, .6
      Button1 mode: "squish",     clr: hslColor 2/10, .66, .6
      Button1 mode: "squishLeft", clr: hslColor 3/10, .66, .6
      Button1 mode: "opacity",    clr: hslColor 0/10, .66, .6
      Button1 mode: "both",       clr: hslColor 8/10, .66, .6
      AbstractButton component: TextAlignButton, color: hslColor 1/10, .66, .6
      AbstractButton component: TextLeadingButton, color: hslColor 1/10, .66, .6
      AbstractButton component: FontSizeButton, color: hslColor 1/10, .66, .6
      AbstractButton component: ContinuousButton, color: hslColor 2/10, .66, .6
      AbstractButton
        component: ShadowButton, color: hslColor 5/10, .66, .6
