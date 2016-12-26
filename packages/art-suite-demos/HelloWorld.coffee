{
  Component
  RectangleElement
  TextElement
  CanvasElement
  InitArtSuiteApp
} = require "art-suite"

InitArtSuiteApp
  title: "My HelloWorld"

  class HelloWorld extends Component

    render: ->

      # The top-most Element, and only the top-most Element, should be a CanvasElement.
      CanvasElement null,
        RectangleElement color: "pink"
        TextElement text: "Hello, world!"
