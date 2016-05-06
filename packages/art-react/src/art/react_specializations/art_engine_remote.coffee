require 'art-engine-remote/remote'
module.exports = React = require "../react"

class React.VirtualElementArtEngineRemote extends React.VirtualElement

  constructor: ->
    super
    @_sendRemoteQueuePending = false

  _setElementChildren: (childElements) ->
    remote.updateElement @element, children: childElements
    @_sendRemoteQueue()

  _newElement: (elementClassName, props, childElements, newCanvasElementProps) ->
    remoteId = remote.newElement @elementClassName, merge(props, children: childElements), newCanvasElementProps
    @_sendRemoteQueue()
    remoteId

  _updateElementProps: (newProps) ->
    setProps = {}; resetProps = []
    addedOrChanged  = (k, v) => setProps[k] = v
    removed         = (k, v) => resetProps.push k
    if changed = @_updateElementPropsHelper newProps, addedOrChanged, removed
      remote.updateElement @element, setProps, resetProps
      @_sendRemoteQueue()

    changed

  _sendRemoteQueue: ->
    unless @_sendRemoteQueuePending
      @_sendRemoteQueuePending = true
      @onNextReady =>
        remote.sendRemoteQueue()
        @_sendRemoteQueuePending = false

  _newErrorElement: -> @_newElement "RectangleElement", key:"ART_REACT_ERROR_CREATING_CHILD_PLACEHOLDER", color:"orange"

  ###
  execute the function 'f' on the Art.Engine Element associated with this VirtualElement.
  NOTE: runs in the main thread. 'f' is serialized, so it loses all closure state.
  IN: f = (Art.Engine.Core.Element) -> x
  OUT: Promise returning x

  TODO: we could allow additional arguments to be passed which would in turn be
  passed to 'f' on when invoked on the main thread:

    withElement: (f, args...) -> remote.evalWithElement @element, f, args
  ###
  withElement: (f) -> remote.evalWithElement @element, f


React.includeInNamespace (require './aim').createVirtualElementFactories React.VirtualElementArtEngineRemote
