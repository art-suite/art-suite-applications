Foundation = require "art-foundation"
React = require "art-react"

{
  log, arrayWith
  intRand
} = Foundation

{
  createComponentFactory
  Component
  Element
  RectangleElement
  TextElement
} = React

module.exports = createComponentFactory class MyComponent extends Component
  module: module

  @stateField
    stars: []
    nextUniqueId: 0

  addClick: ({location})->
    @stars = arrayWith @stars,
      key: "#{@nextUniqueId}"
      location: location
      size: 30 + intRand 70
    @nextUniqueId = @nextUniqueId + 1

  removeClick: (event) ->
    {key} = event.target
    @stars = (star for star in @stars when star.key != key)

  render: ->
    Element null,

      RectangleElement color: "black", on: pointerClick: @addClick

      TextElement
        fontFamily: "arial"
        text: "click anywhere"
        padding: 10
        color: "#555"

      for props in @stars
        RectangleElement props,
          colors: ["#ff0", "#fa0"]
          on: pointerClick: @removeClick
          axis: .5
          radius: 100
          animators: size: easingFunction: "easeInElastic", duration: 1
          voidProps: size: 0
