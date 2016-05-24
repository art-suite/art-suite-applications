Engine = require 'art-engine'
React = require "../react"
{ElementFactory, Element, CanvasElement} = Engine
module.exports = React
Aim = require './aim'

React.addElementFactories = (elementClassNames) ->
  for k, v of factories = Aim.createVirtualElementFactories React.VirtualElementArtEngine, elementClassNames
    React[k] ||= v
  factories

class React.VirtualElementArtEngine extends React.VirtualElement

  _updateElementProps: (newProps) ->
    addedOrChanged  = (k, v) => @element.setProperty k, v
    removed         = (k, v) => @element.resetProperty k
    @_updateElementPropsHelper newProps, addedOrChanged, removed

  _setElementChildren: (childElements) -> @element.setChildren childElements

  _newElement: (elementClassName, props, childElements, bindToOrCreateNewParentElementProps)->
    element = ElementFactory.newElement @elementClassName, props, childElements

    if bindToOrCreateNewParentElementProps
      if bindToOrCreateNewParentElementProps instanceof Element
        bindToOrCreateNewParentElementProps.addChild element
      else
        props = merge bindToOrCreateNewParentElementProps,
          webgl: Browser.Parse.query().webgl == "true"
          children: [element]
        new CanvasElement props

    element.creator = @
    element

  _newErrorElement: -> @_newElement "RectangleElement", key:"ART_REACT_ERROR_CREATING_CHILD_PLACEHOLDER", color:"orange"

React.addElementFactories()
