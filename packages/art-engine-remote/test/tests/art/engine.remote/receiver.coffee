Foundation = require 'art.foundation'
{point} = require 'art.atomic'
{Core:{CanvasElement, Element}} = require 'art.engine'
{receiver} = require 'art.engine.remote/receiver'

suite "Art.EngineRemote.Receiver", ->
  uniqueIdCounter = 0
  nextUniqueId = -> "Art.EngineRemote.RemoteReceiver_test_remoteId_#{uniqueIdCounter++}"

  test 'applyUpdates - update an element', (done) ->
    receiver.applyUpdates null, [
      ["new", elementRemoteId = nextUniqueId(), "Element", name: elementName = "myName"]
      ["new", nextUniqueId(), "CanvasElement", children: [elementRemoteId]]
    ]
    Element.onNextReady ->
      element = Element.getElementByInstanceId elementRemoteId
      assert.eq true, !!element
      receiver.applyUpdates null, [["update", elementRemoteId, name: newElementName = "myNewName"]]
      assert.eq elementName, element.name
      element.onNextReady ->
        assert.eq newElementName, element.name
        done()

  test 'applyUpdates - create a small AIM tree', (done) ->
    receiver.applyUpdates null, [
      ["new", childId  = nextUniqueId(), "Element",        name: childName = "myChild"]
      ["new", parentId = nextUniqueId(), "Element",        name: parentName = "myParent", children: [childId]]
      ["new", canvasId = nextUniqueId(), "CanvasElement",  name: canvasElementName = "myCanvasElement", children:[parentId]]
    ]
    CanvasElement.onNextReady ->
      assert.eq parentName, CanvasElement.getElementByInstanceId(parentId).name
      assert.eq childName, CanvasElement.getElementByInstanceId(childId).name

      assert.eq canvasElementName, CanvasElement.getElementByInstanceId(parentId).parent.name
      assert.eq parentName, CanvasElement.getElementByInstanceId(childId).parent.name
      done()

  test 'applyUpdates - create a small AIM tree then release child', (done) ->
    receiver.applyUpdates null, [
      ["new", childId  = nextUniqueId(), "Element",        name: childName = "child"]
      ["new", parentId = nextUniqueId(), "Element",        name: parentName = "parent", children: [childId]]
      ["new", canvasId = nextUniqueId(), "CanvasElement",  name: canvasElementName = "myCanvasElement", children:[parentId]]
    ]
    CanvasElement.onNextReady ->
      assert.eq 1, CanvasElement.getElementByInstanceId(parentId).children.length
      receiver.applyUpdates null, [["update", parentId, children: []]]
      assert.eq true, !!CanvasElement.getElementByInstanceId(childId)
      CanvasElement.onNextReady ->
        assert.eq 0, CanvasElement.getElementByInstanceId(parentId).children.length
        assert.eq false, !!CanvasElement.getElementByInstanceId(childId)
        done()

  test 'applyUpdates - resetProps', (done) ->
    receiver.applyUpdates null, [
      ["new", elementId = nextUniqueId(), "Element", childrenAlignment:.5]
      ["new", canvasId  = nextUniqueId(), "CanvasElement",  name: canvasElementName = "myCanvasElement", children:[elementId]]
    ]
    CanvasElement.onNextReady ->
      assert.eq point(.5), CanvasElement.getElementByInstanceId(elementId).childrenAlignment
      receiver.applyUpdates null, [["update", elementId, null, ["childrenAlignment"]]]
      CanvasElement.onNextReady ->
        assert.eq point(0), CanvasElement.getElementByInstanceId(elementId).childrenAlignment
        done()
