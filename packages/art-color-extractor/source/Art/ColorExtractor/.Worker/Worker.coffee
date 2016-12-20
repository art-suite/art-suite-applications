{extractColors} = require '../'

onmessage = (msg) ->
  postMessage extractColors new Uint8ClampedArray msg.data.imageDataBuffer