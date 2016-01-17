console.log "HI THERE"
{log} = Foundation = require "art.foundation"
{
  createComponentFactory
  Component
  CanvasElement
  Element
  Rectangle
  TextElement
  arrayWithout
} = require "art.react"
{point} = require "art.atomic"

###
Hot reload notes!

Ok, this is getting close.

All this needs to go into Component.

I suspect module.hot is tied to the specific file, and if so, then we need to create a wrapper
function that each user-file where the user wants hot-reload support, can be something like this:

{reactHotReload} = require 'art.react'

# uses the current module.hot to bind all components declared in the passed-in function for hot-reload
reactHotReload module.hot, ->
  createComponentFactory class MyComponent extends Component
    ...

###
prototypesToUpdate = module.hot.data?.prototypesToUpdate || {}
if module.hot
  console.log "HOT DEMO"
  module.hot.accept()
  module.hot.dispose (data)->
    data.prototypesToUpdate = prototypesToUpdate
    console.log "dispose! #{__dirname}"
else
  console.log "COLD DEMO"

MyComponent = createComponentFactory class MyComponent extends Component

    @postCreate: ->
      if (oldPrototype = module.hot.data?.prototypesToUpdate?[@name]) && oldPrototype != @prototype
        # add/update new properties
        for k, v of @prototype when @prototype.hasOwnProperty k
          oldPrototype[k] = v

        # delete removed properties
        for k, v of oldPrototype when !@prototype.hasOwnProperty(k) && oldPrototype.hasOwnProperty k
          delete oldPrototype[k]

        console.log "updating instance bindings and hotReload them"
        # update all instances
        if hotInstances = self.hotInstances
          for instance in hotInstances
            instance._bindFunctions()
            try instance.componentDidHotReload()
        console.log "updating instance bindings done"

      prototypesToUpdate[@name] = oldPrototype || @prototype

      Component.postCreate.call @

    componentDidHotReload: ->
      console.log "componentDidHotReload !!!!!!!!!!!!!!!! HOT"
      @setState mode: "love"
      count = (@state._hotModuleReloadCount || 0) + 1
      @setState _hotModuleReloadCount: count

    componentWillMount: ->
      self.hotInstances ||= []
      self.hotInstances.push @

    componentWillUnmount: ->
      if 0 <= index = self.hotInstances.indexof @
        self.hotInstances = arrayWithout self.hotInstances index

    getInitialState: ->
      mode: "love"
      handlers:
        pointerDown: => @setState mode: "war"
        pointerUp:   => @setState mode: "love"

    render: ->
      console.log "render Love and War 1"
      {handlers, mode, _hotModuleReloadCount} = @state
      {clr, text} = if mode == "love"
        text: "Love",     clr: "pink"
      else
        text: "and War",  clr: "red"

      CanvasElement
        canvasId: "artCanvas"
        on:       handlers

        Rectangle color: "pink", animate: to: color: clr

        TextElement
          key: text
          location: ps: .5
          addedAnimation: from: opacity: 0, axis: point 1, .5
          removedAnimation: to: opacity: 0, axis: point 0, .5
          axis:     .5
          text:     text + " #{_hotModuleReloadCount}"
          color:    "white"
          fontSize: 50

module.exports = ->
  MyComponent.instantiateAsTopComponent()
