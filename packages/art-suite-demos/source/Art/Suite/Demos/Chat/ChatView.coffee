ArtSuite = require 'art-suite'

{
  Element
  RectangleElement
  TextInput
  TextElement
  PagingScrollElement

  defineModule
  FluxComponent
} = ArtSuite

StyleProps = require './StyleProps'
ChatMessage = require './ChatMessage'

defineModule module, class ChatView extends FluxComponent
  subscriptions: "chat.history"

  postMessage: ({target}) ->
    {currentUser} = @props
    @models.chat.postMessage currentUser, target.value
    target.value = ""

  render: ->
    {currentUser} = @props
    {history} = @state

    Element
      padding: 10
      childrenLayout: "column"
      RectangleElement inFlow: false, color:"white", shadow: blur: 10, offsetY: 3, color: "#0007"
      Element
        size: ww:1, hch:1
        RectangleElement color: StyleProps.palette.primaryBackground
        TextElement StyleProps.titleText, padding: 10, text: currentUser

      PagingScrollElement
        clip: true
        childrenAlignment: "bottomLeft"
        Element
          padding: 10
          size: hch: 1, ww: 1
          childrenLayout: "column"
          Element inFlow: false, size: 0 # hack ensures first added message animates in
          for postMessage in history || []
            ChatMessage currentUser: currentUser, postMessage

      Element
        size: ww:1, h:45
        RectangleElement color: StyleProps.palette.grayBackground
        TextInput StyleProps.mediumText,
          on: enter: @postMessage
          padding: 10
          placeholder: "new message from #{currentUser}"
