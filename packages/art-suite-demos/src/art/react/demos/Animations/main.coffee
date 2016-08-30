{
  log, capitalize, merge
  createComponentFactory
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
  PagingScrollElement
  point, hslColor, rgbColor
} = require "art-suite"

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
  mouseIn: -> @setState mouseIn: true
  mouseOut: -> @setState mouseIn: false

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
        pointerOut: @showWontActivate
        pointerIn: @showWillActivate
        mouseIn: @mouseIn
        mouseOut: @mouseOut
      component @props, @state

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

ShadowButton = createComponentFactory
  module: module
  render: ->
    {willActivate, color, mouseIn} = @props
    Element null,
      RectangleElement
        color:    color
        animators: shadow: duration: .1
        shadow: if willActivate
          merge standardShadowProps,
            blur:     5
            offset:   y: 5/4
        else if mouseIn
          standardShadowProps
        else
          merge standardShadowProps,
            blur:     standardShadowProps.blur * .5
            offset:   y: standardShadowProps.offset.y * .5
      TextElement textProps,
        text: "Shadow"

TextAlignButton = createComponentFactory
  module: module
  render: ->
    {willActivate, mouseIn, color} = @props
    Element null,
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "align"
        align: if willActivate then "centerLeft" else if mouseIn then "centerRight" else "centerCenter"
        text: "Text\nAlignment"

TextLeadingButton = createComponentFactory
  module: module
  render: ->
    {willActivate, mouseIn, color} = @props
    Element null,
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "leading"
        leading: if willActivate then .25 else if mouseIn then 2 else 1.25
        text: "Text\nLeading"

PaddingAnimation = createComponentFactory
  module: module
  render: ->
    {willActivate, mouseIn, color} = @props
    Element
      animators: "padding"
      padding: if willActivate then 20 else if mouseIn then 5 else 0
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "leading"
        text: "Padding"

AngleAnimation = createComponentFactory
  module: module
  render: ->
    {willActivate, mouseIn, color} = @props
    Element
      axis: .5
      location: ps: .5
      animators: angle: easingFunction: "easeInElastic", duration: .5
      angle: (Math.PI/180) * if willActivate then 45 else if mouseIn then -5 else 0
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "leading"
        text: "Angle"

SpinAnimation = createComponentFactory
  module: module
  render: ->
    {willActivate, mouseIn, color} = @props
    Element
      axis: .5
      location: ps: .5
      animators:
        angle:
          easingFunction: "easeInElastic"
          duration: if willActivate then 8 else 1
      angle: (Math.PI/180) * if willActivate then 180 * 3 else if mouseIn then -10 else 0
      RectangleElement color: color, shadow: standardShadowProps
      TextElement textProps,
        animators: "leading"
        text: "Spin"


FontSizeButton = createComponentFactory
  module: module
  render: ->
    {willActivate, mouseIn, color} = @props
    Element null,
      RectangleElement color: color, shadow: standardShadowProps
      Element
        clip: true
        TextElement textProps,
          size: cs: 1
          location: ps: .5
          axis: .5
          animators: "fontSize"
          fontSize: if willActivate then 4 else if mouseIn then 100 else textProps.fontSize
          text: "Font Size"


ContinuousButton = createComponentFactory
  module: module
  render: ->
    {mouseIn, color} = @props
    Element null,
      RectangleElement
        color: color
        shadow: standardShadowProps
        to: "bottomRight"
        animators: if mouseIn
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
            color2: color.withLightness .8

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

    # PagingScrollElement null,
      Element
        size: ww:1, hch:1
        childrenLayout: "flow"
        padding: 10
        RectangleElement inFlow: false, color: "#ddd", padding: -10

        AbstractButton component: ShadowButton, color: hslColor 5/10, .66, .6
        AbstractButton component: PaddingAnimation, color: hslColor 5/10, .66, .6
        AbstractButton component: AngleAnimation, color: hslColor 6/10, .66, .6
        AbstractButton component: SpinAnimation, color: hslColor 7/10, .66, .6
        Button1 mode: "scale",      clr: hslColor 4/10, .66, .6
        Button1 mode: "squish",     clr: hslColor 2/10, .66, .6
        Button1 mode: "squishLeft", clr: hslColor 3/10, .66, .6
        Button1 mode: "opacity",    clr: hslColor 0/10, .66, .6
        Button1 mode: "both",       clr: hslColor 8/10, .66, .6
        AbstractButton component: TextAlignButton, color: hslColor 1/10, .66, .6
        AbstractButton component: TextLeadingButton, color: hslColor 1/10, .66, .6
        AbstractButton component: FontSizeButton, color: hslColor 1/10, .66, .6
        AbstractButton component: ContinuousButton, color: hslColor 7/10, .66, .6
