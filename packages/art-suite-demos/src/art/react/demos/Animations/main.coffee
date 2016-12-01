{
  defineModule
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
  compactFlatten
  object
  array
  OutlineElement
} = require "art-suite"

standardTextProps = textProps =
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

defineModule module, ->
  AbstractButton = createComponentFactory


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
        component @props,
          @state

  makeAnimatorComponents = (settings) ->
    array settings, ({buttonProps, rectangleProps, textProps, children}, name) ->
      createComponentFactory

        render: ->
          {willActivate, mouseIn, color} = @props
          Element
            axis: .5
            location: ps: .5
            buttonProps? @props
            RectangleElement color: @props.color, shadow: standardShadowProps, rectangleProps? @props
            children? @props
            Element
              clip: true
              TextElement standardTextProps, text: name, textProps? @props


  ContinuousButton = createComponentFactory

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

  class MyComponent extends Component

    render: ->

      # PagingScrollElement null,
        Element
          childrenLayout: "flow"
          padding: 10
          RectangleElement inFlow: false, color: "#ddd", padding: -10

          array a = compactFlatten([
            ContinuousButton
            makeAnimatorComponents
              Shadow:
                rectangleProps: ({willActivate, mouseIn}) ->
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

              Padding:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: "padding"
                  padding: if willActivate then 20 else if mouseIn then 5 else 0

              Angle:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: angle: easingFunction: "easeInElastic", duration: .5
                  angle: (Math.PI/180) * if willActivate then 45 else if mouseIn then -5 else 0

              Spin:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: angle:
                    easingFunction: "easeInElastic"
                    duration: if willActivate then 8 else 1
                  angle: (Math.PI/180) * if willActivate then 180 * 3 else if mouseIn then -10 else 0

              TextAlign:
                textProps: ({willActivate, mouseIn}) ->
                  animators: "align"
                  align: if willActivate then "centerLeft" else if mouseIn then "centerRight" else "centerCenter"
                  text: "Text\nAlignment"

              TextLeading:
                textProps: ({willActivate, mouseIn}) ->
                  animators: "leading"
                  leading: if willActivate then .25 else if mouseIn then 2 else 1.25
                  text: "▼▼▼       Text\n▲▲▲▲ Leading"

              Opacity:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: "opacity"
                  opacity: if willActivate then 0 else if mouseIn then .5 else 1

              Scale:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: scale: f: "easeInElastic", duration: .5
                  scale: if willActivate then .9 else if mouseIn then 1.05 else 1

              Squish:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: scale: f: "easeInElastic", duration: .5
                  scale: y:1, x: if willActivate then .5 else if mouseIn then 1.05 else 1

              SquishLeft:
                buttonProps: ({willActivate, mouseIn}) ->
                  axis: 0
                  location: 0
                  animators: scale: f: "easeInElastic", duration: .5
                  scale: y:1, x: if willActivate then .5 else if mouseIn then 1.05 else 1

              RotateAndScale:
                buttonProps: ({willActivate, mouseIn}) ->
                  animators: "scale angle"
                  scale: if willActivate then .5 else if mouseIn then 1.05 else 1
                  angle: if willActivate then Math.PI/2 else if mouseIn then -Math.PI/10 else 0

              Outline:
                children: ({willActivate, mouseIn}) ->
                  RectangleElement OutlineElement
                    lineWidth: if willActivate then 50 else if mouseIn then 1 else 6
                    animators: "lineWidth"
                    lineJoin: "round"
                    lineCap: "round"
                    colors: ["#fff0", "#fff"]

              FontSize:
                textProps: ({willActivate, mouseIn}) ->
                  size: cs: 1
                  location: ps: .5
                  axis: .5
                  animators: "fontSize"
                  fontSize: if willActivate then 4 else if mouseIn then 100 else textProps.fontSize

          ]), (component, i) ->
            AbstractButton {component, color: hslColor (i%a.length)/a.length, .8, .6}
