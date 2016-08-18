ArtSuite = require 'art-suite'
StyleProps = require './style_props'

{
  createComponentFactory, Element, RectangleElement, TextElement,
  TextInput
  log
  point
} = ArtSuite

module.exports = createComponentFactory
  module: module

  render: ->
    {currentUser, user, message} = @props
    {user} = @props
    currentUsersMessage = user == currentUser

    Element
      margin: 10
      size: ww:1, hch:1
      childrenLayout: "row"
      axis: 0
      animators:
        size: voidValue: ww:1, h: 0
        axis: voidValue: x: if currentUsersMessage then -1 else 1
      Element
        size: hch:1, ww:1
        childrenLayout: "column"
        childrenAlignment: if currentUsersMessage then "right" else "left"

        Element
          size: cs:1, max: ww:1
          if currentUsersMessage
            axis: x:1
            location: xw: 1

          RectangleElement
            inFlow: false
            color: if currentUsersMessage
                StyleProps.palette.lightPrimaryBackground
              else
                StyleProps.palette.grayBackground

          TextElement StyleProps.mediumText,
            padding: 10
            text: message
            size: cs:1, max: ww:1

        TextElement StyleProps.smallText,
          text: user
          margin: 5
          color: StyleProps.palette.text.black.secondary
