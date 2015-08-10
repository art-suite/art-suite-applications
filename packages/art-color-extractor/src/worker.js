// Gradify = require('./gradify');
ColorThief = require('./color_thief'),
   Vibrant = require('./vibrant'),
   Gradify = require('./gradify');

extract = function(imageData) {
  var thiefPaletteRaw = new ColorThief().getPalette(imageData);
  var vibrant = new Vibrant(imageData,4);
  var vibSwatches = vibrant.swatches();
  var vibColors = {};
  for (var swatch in vibSwatches) {
    if (vibSwatches.hasOwnProperty(swatch) && vibSwatches[swatch]) {
      vibColors[swatch] = vibSwatches[swatch].getRgb();
    }
  }
  var gradify = new Gradify(imageData);

  return {
    gradify: {
      dominantColor: gradify.rawColor,
      gradients: gradify.rawGradients
    },
    colorThief: {
      dominantColor: thiefPaletteRaw[0],
      palette: thiefPaletteRaw
    },
    vibrant: vibColors
  };
}

onmessage = function(msg) {
  var imageData = new Uint8ClampedArray(msg.data.imageDataBuffer);
  var colorInfo = extract(imageData);
  postMessage(colorInfo);
  // console.log(imageData);
  // console.log(self);
}
