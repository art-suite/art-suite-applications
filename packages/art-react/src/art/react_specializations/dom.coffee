Foundation = require 'art-foundation'
module.exports = React = require "../react"
{setDomElementProps, setDomElementProp, allDomElementNames} =  Foundation

VirtualElementDom = class React.VirtualElementDom extends React.VirtualElement

  setDomElementChildren = (newChildrenElements) ->

    for oldChild, i in @element.childNodes
      break if i >= newChildrenElements.length
      if oldChild != newChild = newChildrenElements[i]
        @element.replaceChild newChild, oldChild

    oldChildrenLength = @element.childNodes.length
    newChildrenLength = newChildrenElements.length

    while oldChildrenLength > newChildrenLength
      oldChildrenLength--
      @element.removeChild @element.lastChild

    while newChildrenLength > oldChildrenLength
      @element.appendChild newChildrenElements[oldChildrenLength++]

  _setElementChildren: (newChildrenElements) ->
    setDomElementChildren @element, newChildrenElements

  _newElement: (elementClassName, props, childElements, newCanvasElementProps) ->
    element = document.createElement elementClassName
    setDomElementProps element, props
    setDomElementChildren element, newChildrenElements
    element

  _updateElementProps: (newProps) ->
    addedOrChanged  = (k, v, oldV) => setDomElementProp @element, k, v, oldV
    removed         = (k, oldV) => setDomElementProp @element, k, null, oldV
    @_updateElementPropsHelper newProps, addedOrChanged, removed

  _newErrorElement: ->
    element = document.createElement elementClassName
    element.style.backgroundColor = "orange"
    element.innerHTML = "ART_REACT_ERROR_CREATING_CHILD_PLACEHOLDER"

React.includeInNamespace createObjectTreeFactories allDomElementNames, (elementClassName) ->
  (props, children) -> new VirtualElementDom elementClassName, props, children

