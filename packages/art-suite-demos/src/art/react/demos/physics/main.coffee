Foundation = require "art-foundation"
React = require "art-react"
Atomic = require "art-atomic"

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
{point} = Atomic

animateLocationWithPhysics = ({toValue, element:{currentLocation}, frameSeconds, state, options}) ->
  targetLocation = toValue.layout()
  velocity = state.velocity || point()

  currentToTargetVector = targetLocation.sub currentLocation

  springConstant   = if options.spring? then options.spring else 100
  frictionConstant = if options.friction? then options.friction else 10

  frictionAcceleration = velocity.mul -frictionConstant
  springAcceleration = currentToTargetVector.mul springConstant
  acceleration = springAcceleration.add frictionAcceleration

  if 0 < gravityConstant = options.gravity || 0
    gravityConstant  = options.gravity || 0
    distanceSquared = currentToTargetVector.magnitudeSquared
    distanceSquared = 1 if distanceSquared < 1
    gravityAcceleration = if distanceSquared > 0 then currentToTargetVector.mul(1/distanceSquared).mul(gravityConstant) else point()
    acceleration = acceleration.add gravityAcceleration

  state.velocity = velocity = velocity.add acceleration.mul frameSeconds
  currentLocation.add velocity.mul frameSeconds

module.exports = createComponentFactory class MyComponent extends Component
  module: module

  @stateFields location: ps: .5

  updateLocation: ({location}) ->
    @location = location

  render: ->
    {location} = @state

    Element
      on: mouseMove: @updateLocation

      RectangleElement color: "white"

      RectangleElement
        size: 50
        radius: 50
        axis: .5
        location: location
        color: "orange"
        animators: location:
          animate: animateLocationWithPhysics
          spring: 200
