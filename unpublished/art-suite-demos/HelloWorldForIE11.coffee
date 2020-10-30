{
  initArtSuiteApp
  Component
  CanvasElement
  RectangleElement
  TextElement
} = require 'art-suite'

initArtSuiteApp MainComponent: class MyHelloWorldComponent extends Component

  render: ->
    # The top-most Element, and only the top-most Element, should be a CanvasElement.
    CanvasElement null,

      # background color
      RectangleElement
        color: "#eef"

      # show some text
      TextElement
        padding: 10
        text: "Hello, world!"
