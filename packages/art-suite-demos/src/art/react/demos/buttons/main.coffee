{log, capitalize} = Foundation = require "art-foundation"
{
  createComponentFactory
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
} = require "art-react"
{point, hslColor} = require "art-atomic"

textProps =
  fontFamily: "sans-serif"
  color: "#fffc"

Button1 = createComponentFactory
  hotModule: module

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
                  else
                    angle: if willActivate then Math.PI/12 else 0
        RectangleElement color: clr, shadow: color: "#0007", blur: 20, offsetY:5
        TextElement textProps,
          axis: .5
          location: ps:.5

          text: "Button #{capitalize mode}"

module.exports = createComponentFactory class MyComponent extends Component
  hotModule: module

  render: ->

    Element
      childrenLayout: "flow"
      padding: 10
      RectangleElement inFlow: false, color: "#ddd", padding: -10

      Button1 mode: "angle",      clr: hslColor 3/5, .66, .6
      Button1 mode: "spin",       clr: hslColor 7/10, .66, .6
      Button1 mode: "scale",      clr: hslColor 2/5, .66, .6
      Button1 mode: "squish",     clr: hslColor 1/5, .66, .6
      Button1 mode: "squishLeft", clr: hslColor 3/10, .66, .6
      Button1 mode: "opacity",    clr: hslColor 0/5, .66, .6
      Button1 mode: "both",       clr: hslColor 4/5, .66, .6
