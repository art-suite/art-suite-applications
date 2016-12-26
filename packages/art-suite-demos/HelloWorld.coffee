{
  Component
  RectangleElement
  TextElement
  CanvasElement
  InitArtSuiteApp
  Element
} = require "art-suite"

InitArtSuiteApp
  title: "My HelloWorld"

  class HelloWorld extends Component

    render: ->
      {go, hover} = @state

      # The top-most Element, and only the top-most Element, should be a CanvasElement.
      CanvasElement null,
        RectangleElement color: "pink"
        Element
          size: ww:1, hch: 1
          padding: 10
          childrenLayout: "row"
          on: pointerClick: => @setState go: !go

          RectangleElement inFlow: false, padding: -10

          !@state.go && Element
            size: cs: 1
            animators: size: toFrom: hch:1, w: 0
            clip: true
            RectangleElement
              color: if hover then "#999" else "#555"
              animators: "color"
              radius: 5

            TextElement
              text: "stop"
              padding: 10
              color: "white"


          TextElement
            size: ps: 1
            align: "centerLeft"
            margin: 10
            text: if go then "Hello, world!" else "hi"
            color: "white"
