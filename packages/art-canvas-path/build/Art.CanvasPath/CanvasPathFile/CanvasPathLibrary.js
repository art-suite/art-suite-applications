"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseClass", "rect", "CanvasPathLibraryTag", "toInspectedObjects", "XbdTag"], [global, require('./StandardImport')], (BaseClass, rect, CanvasPathLibraryTag, toInspectedObjects, XbdTag) => {let CanvasPathLibrary; return CanvasPathLibrary = Caf.defClass(class CanvasPathLibrary extends BaseClass {constructor(a) {super(...arguments); this._canvasPathSets = {}; if (a instanceof XbdTag) {this._initFromXbd(a);};};}, function(CanvasPathLibrary, classSuper, instanceSuper) {this.property("canvasPathSets"); this.getter({drawArea: function() {return Caf.reduce(this.canvasPathSets, (area, p) => p.drawArea.unionInto(area), null, rect());}, xbd: function() {return CanvasPathLibraryTag(Caf.array(this.canvasPathSets, (p, name) => p.xbd));}, inspectedObjects: function() {return {CanvasPathLibrary: toInspectedObjects(this._canvasPathSets)};}, library: function() {return this._canvasPathSets;}}); this.prototype.add = function(name, pathSet) {return (this.canvasPathSets[name] = pathSet).name = name;}; this.prototype.normalize = function() {return Caf.each2(this.canvasPathSets, (p) => p.normalize());}; this.prototype.flatten = function() {return this._canvasPathSets = Caf.object(this.canvasPathSets, (p) => p.flattened);}; this.prototype._initFromXbd = function(xbdTag) {return Caf.each2(xbdTag.tags, (pathTag) => {let TagType, tag; return (TagType = require('./namespace')[pathTag.name]) ? (tag = new TagType(pathTag), this._canvasPathSets[tag.name] = tag) : undefined;});};});});});
//# sourceMappingURL=CanvasPathLibrary.js.map