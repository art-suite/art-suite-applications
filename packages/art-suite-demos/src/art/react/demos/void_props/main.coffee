Foundation = require "art-foundation"
Atomic = require 'art-atomic'
React = require "art-react"

{
  log, arrayWith
  intRand
  defineModule
} = Foundation

{
  point
} = Atomic

{
  Component
  Element
  RectangleElement
  TextElement
} = React

defineModule module, class MyComponent extends Component

  @stateField
    stars: []
    nextUniqueId: 0

  addClick: ({location})->
    @stars = arrayWith @stars,
      key: "#{@nextUniqueId}"
      location: location
    @nextUniqueId = @nextUniqueId + 1

  removeClick: (event) ->
    {key} = event.target
    @stars = (star for star in @stars when star.key != key)

  render: ->
    Element null,

      RectangleElement color: "black"

      Element
        childrenLayout: "column"
        cacheDraw: true
        padding: 10
        TextElement
          margin: 10
          size: ww:1, hch:1
          fontFamily: "arial"
          color: "#777"
          text: """
            Elements can be automatically animated when added "from the void" or removed "to the void."

            ❧ Click background to add an element.
            ❧ Click element to remove it.

            Example code:
            """

        TextElement
          fontFamily: "courier"
          color: "#557"
          padding: 10
          text: """
            RectangleElement
              animators: size: toFrom: 0

            """

      Element on: pointerClick: @addClick

      for props in @stars
        RectangleElement props,
          size: 100
          colors: ["#ff0", "#fa0"]
          on: pointerClick: @removeClick
          axis: .5
          radius: 100
          animators:
            size:
              toFromVoid: 0
              easingFunction: "easeInElastic"
              duration: 1
