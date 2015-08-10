/* @flow weak */
var events = require('events'),
    Q = require('q'),
    CanvasImage = require('./canvas_image');


function ColorExtractor(workerPath, maxWorkers) {
  this.workerPath = workerPath || 'worker.js';
  this.maxWorkers = maxWorkers || 4;
  events.EventEmitter.call(this);
  this.idleWorkers = [];
  this.activeWorkers = [];
  this.workerRequests = [];
}

ColorExtractor.prototype.checkOutWorker = function() {
  var worker = this.idleWorkers.shift();
  if (!worker && this.activeWorkers.length < this.maxWorkers) {
    // Make a new worker
    worker = new Worker(this.workerPath);
    this.activeWorkers.push(worker);
    return Promise.resolve(worker);
  }
  else {
    var deferred = Q.defer();
    this.workerRequests.push(deferred);
    return deferred.promise;
  }
}

ColorExtractor.prototype.checkInWorker = function(worker) {
  // Remove worker from active workers list
  this.activeWorkers = this.activeWorkers.filter(function(w) {
    return w !== worker;
  });

  // If a worker request is queued, dispatch
  var deferred = this.workerRequests.shift();
  if (deferred) {
    deferred.resolve(worker);
  }
  // Otherwise move this worker to idle
  else {
    this.idleWorkers.push(worker);
  }
}

/**
 * @param imageSource - Any CanvasImageSource - https://developer.mozilla.org/en-US/docs/Web/API/CanvasImageSource
 */
ColorExtractor.prototype.extract = function(imageSource) {
  return this.checkOutWorker().then(function(worker) {
    var imageDataBuffer = new CanvasImage(imageSource, 100, 100).getImageData().data.buffer;

    var deferredExtraction = Q.defer();
    worker.postMessage({command: 'extract', imageDataBuffer: imageDataBuffer}, [imageDataBuffer]);
    worker.onmessage = function(e) {
      this.checkInWorker(worker);
      deferredExtraction.resolve(e.data);
    }.bind(this);
    return deferredExtraction.promise;
  }.bind(this));
}



if (typeof exports === "object" && typeof module === "object") {
  module.exports = ColorExtractor;
}
else if (typeof window !== "undefined") {
  window.ColorExtractor = ColorExtractor;
}
