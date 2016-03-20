Foundation = require "art-foundation"
React = require "art-react"

{log} = Foundation
{
  createComponentFactory
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
} = React

module.exports = createComponentFactory class MyComponent extends Component
  module: module

  @stateFields location: ps: .5

  updateLocation: ({location}) ->
    @location = location

  render: ->
    {location} = @state

    Element
      on:
        pointerDown: @updateLocation
        pointerMove: @updateLocation

      RectangleElement color: "white"

      RectangleElement
        size: 50
        radius: 50
        axis: .5
        location: location
        color: "orange"
        animators: "location"
