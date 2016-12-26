{
  Component
  RectangleElement
  TextElement
  CanvasElement
  InitArtReactApp
} = require "art-suite"

InitArtReactApp
  title: "My HelloWorld"

  class HelloWorld extends Component

    render: ->

      # The top-most Element, and only the top-most Element, should be a CanvasElement.
      CanvasElement null,
        RectangleElement color: "pink"
        TextElement text: "Hello, world!"
