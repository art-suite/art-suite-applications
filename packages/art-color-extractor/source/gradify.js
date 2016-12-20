/*
 * Gradify (https://github.com/fraser-hemp/gradify), modified as such:
 *   - Added pixelData argument
 *   - Added raw gradient and color results
 *   - Removed css generation stuff
 */
var Grad = function(pixelData, optNumColors) {
  this.pixelData = pixelData;

  // Colors which do not catch the eye
  this.ignoredColors = [[0,0,0,], [255,255,255]];

  // Sensitivity to ignored colors
  this.BWSensitivity = 4;

  // Overall sensitivity to closeness of colors.
  this.sensitivity = 7;

  // Max sensitivity of black/white in the gradient (0 is pure BW, 5 is none).
  this.maxBW = 2;

  this.width = this.height = Math.sqrt(pixelData.length / 4);

  // Element to apply grad to.
  // this.classname = classname;

  // Prefixes for grad rules (cross-browser).
  // this.browserPrexies = ["","-webkit-", "-moz-", "-o-", "-ms-"]

  // Safari being difficult and requiring special CSS rules
  // this.directionMap = {
  //   0: "right top",
  //   270: "right bottom",
  //   180: "left bottom",
  //   360: "right top",
  //   90: "left top"
  // }

  this.handleData();
  return
}

Grad.prototype.getColorDiff = function(first, second) {
  // *Very* rough approximation of a better color space than RGB.
  return Math.sqrt(Math.abs(1.4*Math.sqrt(Math.abs(first[0]-second[0])) +
      .8*Math.sqrt(Math.abs(first[1]-second[1])) + .8*Math.sqrt(Math.abs(first[2]-second[2]))));
}

Grad.prototype.createCSS = function(colors) {
  var s = [];
  var rawGradients = [];
  // for (var j = 0; j < this.browserPrexies.length; j++) {
    for (var i=0; i<colors.length; i++) {
      // oppDir = this.directionMap[(90 + colors[i][3] + 180)%360]
      var dir = (90 + colors[i][3] + 180)%360;
      s.push("linear-gradient(" + dir + "deg, rgba(" +
          colors[i][0] + "," + colors[i][1] + "," + colors[i][2] + ",0) 0%, rgba(" +
          colors[i][0] + "," + colors[i][1] + "," + colors[i][2] + ",1) 100%)");
      rawGradients.push([dir, [colors[i][0], colors[i][1], colors[i][2], 0], [colors[i][0], colors[i][1], colors[i][2], 1]]);
    }

  // }
  // this.cssBackgroundImage = this.browserPrexies.map(function(prefix) {
  //   return s.map(function (style) {
  //     return prefix + style;
  //   }).join(', ');
  // }).join(', ');
  this.cssBackgroundImage = s.join(', ');
  this.rawGradients = rawGradients;
  this.rawColor = colors[3].slice(0,3);
  this.singleColor = 'rgb(' + colors[3].slice(0,3).join(', ') + ')';
  //
  // var els = [].slice.call(document.querySelectorAll('.' + this.classname));
  // var css = s.reduce(function (previous, current) {
  //   return previous + "background:" + current + ";\n";
  // }, "");
  //
  // els.forEach(function(el) {
  //   var currentStyle = el.getAttribute('style');
  //   el.setAttribute('style', currentStyle + css);
  // });
}

// Grad.prototype.getCSSBackgroundImage = function(colors) {
//   var s = [];
//   for (var j = 0; j < this.browserPrexies.length; j++, s[j] = [""]) {
//     for (var i=0; i<colors.length; i++) {
//       oppDir = this.directionMap[(90 + colors[i][3] + 180)%360]
//       s[j] += this.browserPrexies[j]+"linear-gradient(" + oppDir + ", rgba(" +
//           colors[i][0] + "," + colors[i][1] + "," + colors[i][2] + ",0) 0%, rgba(" +
//           colors[i][0] + "," + colors[i][1] + "," + colors[i][2] + ",1) 100%),"
//     }
//     s[j] = s[j].slice(0, -1);
//   }
//
//   return s;
// }


Grad.prototype.getQuads = function(colors) {
  // Second iteration of pix data is necessary because
  // now we have the base dominant colors, we have to check the
  // Surrounding color space for the average location.
  // This can/will be optimized a lot

  // Resultant array;
  quadCombo = [0,0,0,0];
  takenPos = [0,0,0,0];
  // Keep track of most dominated quads for each col.
  var quad = [
    [[0,0],[0,0]],
    [[0,0],[0,0]],
    [[0,0],[0,0]],
    [[0,0],[0,0]],
  ];

  for (var j = 0; j < this.pixelData.length; j+= 4) {
    // Iterate over each pixel, checking it's closeness to our colors.
    var r = this.pixelData[j]
    var g = this.pixelData[j+1]
    var b = this.pixelData[j+2]
    for (var i = 0; i < colors.length; i++) {
      var color = colors[i];
      diff = this.getColorDiff(color, [r,g,b]);
      if (diff < 4.3) {
        // If close enough, increment color's quad score.
        xq = (Math.floor(((j/4)%this.width)/ (this.height / 2)));
        yq = (Math.round((j/4)/(this.width * this.height)));

        quad[i][yq][xq] += 1;
      }
    }
  }
  for (var i = 0; i < colors.length; i++) {
    // For each col, try and find the best avail quad.
    var quadArr = []
    quadArr[0] = quad[i][0][0];
    quadArr[1] = quad[i][1][0];
    quadArr[2] = quad[i][1][1];
    quadArr[3] = quad[i][0][1];
    var found = false;
    for (var j = 0; !found; j++) {
      var best_choice = quadArr.indexOf(Math.max.apply(Math, quadArr));
      if (Math.max.apply(Math, quadArr)==0) {
        colors[i][3] = 90 * quadCombo.indexOf(0);
        quadCombo[quadCombo.indexOf(0)] = colors[i];
        found = true;
      }
      if (takenPos[best_choice]==0) {
        colors[i][3] = 90 * best_choice;
        quadCombo[i] = colors[i];
        takenPos[best_choice] = 1;
        found = true;
        break;
      } else {
        quadArr[best_choice] = 0;
      }
    }
  }
  // Create the rule.
  this.createCSS(quadCombo);
}

Grad.prototype.getColors = function(colors) {
  // Select for dominant but different colors.
  var selectedColors = [],
    flag = false,
    found = false,
    diff,
    old = [];
    sensitivity = this.sensitivity,
    bws = this.BWSensitivity
  while (selectedColors.length < 4 && !found) {
    selectedColors = []
    for (var j=0; j < colors.length; j++) {
      acceptableColor = false;
      // Check curr color isn't too black/white.
      for (var k = 0; k < this.ignoredColors.length; k++) {
        diff = this.getColorDiff(this.ignoredColors[k], colors[j][0])
        if (diff < bws) {
          acceptableColor = true;
          break;
        }
      }
      // Check curr color is not close to previous colors
      for (var g = 0; g < selectedColors.length; g++) {
        diff = this.getColorDiff(selectedColors[g], colors[j][0]);
        if (diff < sensitivity) {
          acceptableColor = true;
          break;
        }
      }
      if (acceptableColor) {
        continue;
      }
      // IF a good color, add to our selected colors!
      selectedColors.push(colors[j][0])
      if (selectedColors.length > 3) {
        found = true;
        break
      }
    }
    // Decrement both sensitivities.
    if (bws > 2) {
      bws -= 1;
    } else {
      sensitivity--;
      if (sensitivity < 0) found = 1;
      // Reset BW sensitivity for new iteration of lower overall sensitivity.
      bws = this.BWSensitivity;
    }
  }
  this.getQuads(selectedColors);
  //this.createCSS(selectedColors);
}

Grad.prototype.handleData = function() {
  // Count all colors and sort high to low.
  var r=0,
    b=0,
    g=0,
    max = 0,
    avg;
  colorMap = {};
  sortedColors = [];
  for (i=0;i<this.pixelData.length; i+=4) {
    r = this.pixelData[i]
    g = this.pixelData[i+1]
    b = this.pixelData[i+2]
    // Pad the rgb values with 0's to make parsing easier later.
    var newCol = ("0"+r.toString(16)).slice(-2) + ("00" + g.toString(16)).slice(-2) + ("0" + b.toString(16)).slice(-2);
    if (newCol in colorMap) {
      colorMap[newCol]+= 1;
    } else {
      colorMap[newCol] = 0;
    }
  }
  var items = Object.keys(colorMap).map(function(key) {
    return [[parseInt(key.slice(0, 2),16), parseInt(key.slice(2, 4),16), parseInt(key.slice(4, 6),16)], colorMap[key]];
  });
  items.sort(function(first, second) {
    return second[1] - first[1];
  });
  this.colMap = colorMap;
  this.getColors(items)
}

module.exports = Grad;
