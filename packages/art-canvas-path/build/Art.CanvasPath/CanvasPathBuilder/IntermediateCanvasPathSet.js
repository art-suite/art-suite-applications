"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseClass", "min", "max"], [global, require('./StandardImport')], (BaseClass, min, max) => {let IntermediateCanvasPathSet; return IntermediateCanvasPathSet = Caf.defClass(class IntermediateCanvasPathSet extends BaseClass {constructor(paths = []) {super(...arguments); this.paths = paths;};}, function(IntermediateCanvasPathSet, classSuper, instanceSuper) {this.property("paths"); this.prototype.normalize = function() {let minX, minY, maxX, maxY, firstPath; minX = minY = maxX = maxY = 0; firstPath = true; return Caf.each2(this.paths, (path) => {let originalMaxX, originalMaxY, originalMinX, originalMinY; path.resolveMatrix(); ({originalMaxX, originalMaxY, originalMinX, originalMinY} = path); if (firstPath) {maxX = originalMaxX; minX = originalMinX; maxY = originalMaxY; minY = originalMinY;}; minX = min(minX, originalMinX); minY = min(minY, originalMinY); maxX = max(maxX, originalMaxX); return maxY = max(maxY, originalMaxY);});};});});});
//# sourceMappingURL=IntermediateCanvasPathSet.js.map