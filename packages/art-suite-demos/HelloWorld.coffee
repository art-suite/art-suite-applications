{
  Component
  RectangleElement
  TextElement
  CanvasElement
  initArtSuiteApp
} = require "art-suite"

initArtSuiteApp MainComponent: class MyHelloWorldComponent extends Component

  render: ->
    # The top-most Element, and only the top-most Element, should be a CanvasElement.
    CanvasElement null,

      # background color
      RectangleElement color: "pink"

      # show some text
      TextElement text: "Hello, world!"
