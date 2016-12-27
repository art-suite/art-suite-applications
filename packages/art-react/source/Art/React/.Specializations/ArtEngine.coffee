{log, isPlainObject} = require 'art-foundation'
Engine = require 'art-engine'
React = require "../index"
{ElementFactory, Element, CanvasElement, FullScreenApp} = Engine
module.exports = React
Aim = require './Aim'

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

# fullScreenReactAppInit should be called immediatly when the top-level JS is loaded from index.html
# However, MainComponent can be a Promise, so if you have async work to do, do it there and return the MainComponent
# when you are done
###
IN:
  options:
    MainComponent: the MainComponent-factory to start the app with. (required)
    prepare: null or promise (optional)
      Init will wait for the prepare-promise to finish before starting the app.

###
React.initArtReactApp = (options) ->
  {MainComponent, prepare} = options
  throw new Error "MainComponent required" unless MainComponent

  options.title ||= MainComponent.getName()

  FullScreenApp.init options
  .then -> Promise.resolve prepare
  .then -> MainComponent.instantiateAsTopComponent()
  .catch (error) ->
    log.error "Art.React.initArtReactApp failed", error

React.addElementFactories()
