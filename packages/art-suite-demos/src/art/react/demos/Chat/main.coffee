ArtSuite = require 'art-suite'
{
  Element, RectangleElement, TextElement
  defineModule
  Component
} = ArtSuite

ChatModel = require './chat_model'
ChatView = require './chat_view'

defineModule module, class Main extends Component

  render: ->
    Element
      childrenLayout: "row"
      RectangleElement inFlow: false, color: "#eee"
      ChatView currentUser: "Alice"
      ChatView currentUser: "Bill"
