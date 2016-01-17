define [
  'art.foundation'
  'art.atomic'
  'art.engine'
  'art.engine_remote/receiver'
  'art.engine_remote/remote'
], (Foundation, Atomic, Engine, RemoteReceiver, Remote) ->
  {point, matrix, Matrix} = Atomic
  {inspect, nextTick, eq, log, Browser, startWorkerFromFunction} = Foundation
  {Element} = Engine.Core
  {remote} = Remote
  {remoteReceiver} = RemoteReceiver
  sendRemoteQueueLocal = (commands) ->
    remoteReceiver.applyUpdates commands

  "self.onmessage=function(e){postMessage('Worker: '+e.data);}"
  suite "Art.EngineRemote.Remote", ->
    suite "with worker", ->
      workerThread = null
      suiteSetup (done) ->
        workerThread = remoteReceiver.startWorker "/worker_for_remote_tests.js",
          main: ready: -> done()
        , worker: ["eval"]

      test "create CanvasElement", (done)->
        workerThread.register test: test: (remoteId) ->
          Element.onNextReady ->
            element = Element.getElementByInstanceId remoteId
            assert.eq true, !!element, "can get canvasElement from remoteId: #{remoteId}"
            assert.eq "CanvasElement", element.className
            done()

        f = ->
          remoteId = remote.newElement "CanvasElement"
          remote.sendRemoteQueue()
          self.workerRpc.test.test remoteId

        workerThread.worker.eval "(#{f})();"

      test "create simple", (done)->
        workerThread.register test: test: (remoteId) ->
          Element.onNextReady ->
            element = Element.getElementByInstanceId remoteId
            assert.eq true, !!element, "can get element from remoteId: #{remoteId}"
            assert.eq "myElement", element.name
            done()

        f = ->
          canvasElementId = remote.newElement "CanvasElement"
          remoteId        = remote.newElement "Element", name: "myElement"
          remote.updateElement canvasElementId, children: [remoteId]
          remote.sendRemoteQueue()
          self.workerRpc.test.test remoteId

        workerThread.worker.eval "(#{f})();"

      test "create with on: parentChanged handler", (done)->
        workerThread.register test: test: (remoteId) ->
          Element.onNextReady ->
            element = Element.getElementByInstanceId remoteId
            assert.eq true, !!element, "can get element from remoteId: #{remoteId}"
            assert.eq "myElement", element.name
            done()

        f = ->
          canvasElementId = remote.newElement "CanvasElement", children: [
            remoteId = remote.newElement "Element", name: "myElement", on: parentChanged: ->
              self.workerRpc.test.test remoteId
          ]

          remote.sendRemoteQueue()

        workerThread.worker.eval "(#{f})();"

      test "create with function props", (done)->
        workerThread.register test: test: (remoteId, canvasElementId) ->
          Element.onNextReady ->
            canvas = Element.getElementByInstanceId canvasElementId
            element = Element.getElementByInstanceId remoteId
            assert.eq true, !!element, "can get element from remoteId: #{remoteId}"
            assert.eq point(50), element.currentSize
            assert.eq point(100), canvas.currentSize
            assert.eq "myElement", element.name
            done()

        f = ->
          canvasElementId = remote.newElement "CanvasElement"
          remoteId        = remote.newElement "Element", name: "myElement", size: (ps) -> ps.x / 2
          remote.updateElement canvasElementId, children: [remoteId]
          remote.sendRemoteQueue()
          self.workerRpc.test.test remoteId, canvasElementId

        workerThread.worker.eval "(#{f})();"

      test "create with children", (done)->
        workerThread.register test: test: (remoteId) ->
          Element.onNextReady ->
            element = Element.getElementByInstanceId remoteId
            assert.eq true, !!element, "can get element from remoteId: #{remoteId}"
            assert.eq "myElement", element.name
            done()

        f = ->
          remote.newElement "CanvasElement",
            children: [remoteId = remote.newElement "Element", name: "myElement"]
          remote.sendRemoteQueue()
          self.workerRpc.test.test remoteId

        workerThread.worker.eval "(#{f})();"

      test "update", (done)->
        workerThread.register test: test: (remoteId) ->
          Element.onNextReady ->
            element = Element.getElementByInstanceId remoteId
            assert.eq "myUpdatedName", element.name
            done()

        f = ->
          remote.newElement "CanvasElement", children:[
            remoteId = remote.newElement "Element", {name: "myElement"}
          ]
          remote.updateElement remoteId, {name:"myUpdatedName"}
          remote.sendRemoteQueue()
          self.workerRpc.test.test remoteId

        workerThread.worker.eval "(#{f})();"

      test "create tree with updateElement", (done)->
        workerThread.register test: test: (parentRemoteId, childRemoteId) ->
          Element.onNextReady ->
            parent = Element.getElementByInstanceId parentRemoteId
            child = Element.getElementByInstanceId childRemoteId
            assert.eq parent, child.parent
            done()

        f = ->
          canvasRemoteId = remote.newElement "CanvasElement"
          parentRemoteId = remote.newElement "Element", {name: "parent"}, {name: "myCanvasElement"}
          childRemoteId = remote.newElement "Element", {name: "child"}
          remote.updateElement canvasRemoteId, children: [parentRemoteId]
          remote.updateElement parentRemoteId, children: [childRemoteId]
          remote.sendRemoteQueue()
          self.workerRpc.test.test parentRemoteId, childRemoteId

        workerThread.worker.eval "(#{f})();"

      test "create tree from tree", (done)->
        workerThread.register test: test: (parentRemoteId, childRemoteId) ->
          Element.onNextReady ->
            parent = Element.getElementByInstanceId parentRemoteId
            child = Element.getElementByInstanceId childRemoteId
            assert.eq parent, child.parent
            done()

        f = ->
          remote.newElement "CanvasElement",
            children: [
              parentRemoteId = remote.newElement "Element",
                name: "parent"
                children: [
                  childRemoteId = remote.newElement "Element", name: "child"
                ]
            ]
          remote.sendRemoteQueue()
          self.workerRpc.test.test parentRemoteId, childRemoteId

        workerThread.worker.eval "(#{f})();"

      test "unregister event", (done)->
        workerThread.register test: test: (remoteId, handlersForRemoteId) ->
          assert.eq false, handlersForRemoteId
          done()

        f = ->
          canvasElementId = remote.newElement "CanvasElement", children: [
            remoteId = remote.newElement "Element",
              name: "myElement"
              on:
                parentChanged: ->
                  remote.updateElement canvasElementId, children: []
                  remote.sendRemoteQueue()
                unregistered: ->
                  # use setTimeout because the element's handlers are unregistered AFTER the unregister event
                  # -- otherwise the unregister event handler would never be executed
                  setTimeout ->
                    handlersForRemoteId = !!remote.getHandlersForRemoteId remoteId
                    console.log "Element #{remoteId} unregistered hander. handlersForRemoteId:#{handlersForRemoteId}"
                    self.workerRpc.test.test remoteId, handlersForRemoteId
                  , 0
          ]

          remote.sendRemoteQueue()

        workerThread.worker.eval "(#{f})();"
