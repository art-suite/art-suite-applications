events = require 'events'
defer = require 'p-promise'
CanvasImage = require './CanvasImage'

{defineModule} = require 'art-foundation'

defineModule module, class ColorExtractor
  constructor: (workerPath, maxWorkers) ->
    @workerPath = workerPath || 'worker.js'
    @maxWorkers = maxWorkers || 4
    events.EventEmitter.call this
    @idleWorkers = []
    @activeWorkers = []
    @workerRequests = []

  checkOutWorker: ->
    var worker = @idleWorkers.shift()
    if !worker && @activeWorkers.length < @maxWorkers
      worker = new Worker(@workerPath)
      @activeWorkers.push worker
      Promise.resolve worker
    else
      var deferred = defer()
      @workerRequests.push deferred
      deferred.promise

  checkInWorker: (worker) ->
    # Remove worker from active workers list
    @activeWorkers = @activeWorkers.filter (w) -> w != worker

    # If a worker request is queued, dispatch
    if deferred = @workerRequests.shift()
      deferred.resolve worker
    # Otherwise move this worker to idle
    else
      @idleWorkers.push worker

  # IN: imageSource - Any CanvasImageSource - https://developer.mozilla.org/en-US/docs/Web/API/CanvasImageSource
  extract: (imageSource) ->
    @checkOutWorker()
    .then (worker) =>
      {imageDataBuffer} = new CanvasImage imageSource, 100, 100

      deferredExtraction = defer()
      worker.postMessage
        command: 'extract'
        imageDataBuffer: imageDataBuffer
        [imageDataBuffer]

      worker.onmessage: (e) =>
        @checkInWorker worker
        deferredExtraction.resolve e.data

      deferredExtraction.promise
