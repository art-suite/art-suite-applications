"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseClass", "maxFixedPointValue", "point", "floatEq", "Matrix", "float32Eq", "float32Eq0", "merge", "CanvasPathTag", "rect", "max", "min", "Rectangle", "log", "noopCommand", "beginPathCommand", "closePathCommand", "moveToCommand", "lineToCommand", "quadraticCurveToCommand", "bezierCurveToCommand", "arcCommand", "antiArcCommand", "parseFloat", "commandArrayType", "valueArrayType", "XbdTag"], [global, require('./StandardImport')], (BaseClass, maxFixedPointValue, point, floatEq, Matrix, float32Eq, float32Eq0, merge, CanvasPathTag, rect, max, min, Rectangle, log, noopCommand, beginPathCommand, closePathCommand, moveToCommand, lineToCommand, quadraticCurveToCommand, bezierCurveToCommand, arcCommand, antiArcCommand, parseFloat, commandArrayType, valueArrayType, XbdTag) => {let CanvasPath; return CanvasPath = Caf.defClass(class CanvasPath extends BaseClass {constructor(a) {super(...arguments); if (a instanceof XbdTag) {this._initFromXbd(a);} else {this._initFromProps(a);};};}, function(CanvasPath, classSuper, instanceSuper) {let fixedPointScaler, extractStyleProps; this.property("styleProps", "points", "radii", "commands", "x", "y", "aspectRatio", "scale", "name"); this.getter({size: function() {return (this.aspectRatio > 1) ? point(1, 1 / this.aspectRatio) : point(1 * this.aspectRatio, 1);}, aspectRatioMatrix: function() {return (() => {switch (false) {case !floatEq(this.aspectRatio, 1): return Matrix.identifyMatrix; case !(this.aspectRatio > 1): return Matrix.scaleXY(1, 1 / this.aspectRatio); default: return Matrix.scaleXY(1 * this.aspectRatio, 1);};})();}, normalized: function() {return float32Eq(this.aspectRatio, 1) && float32Eq(this.scale, 1) && float32Eq0(this.x) && float32Eq0(this.y);}, props: function() {return merge(this.styleProps, {name: this.name, commands: this.commands, points: this.points, radii: this.radii, x: !float32Eq0(this.x) ? this.x : undefined, y: !float32Eq0(this.y) ? this.y : undefined, scale: !float32Eq(1, this.scale) ? this.scale : undefined, aspectRatio: !float32Eq(1, this.aspectRatio) ? this.aspectRatio : undefined});}, inspectedObjects: function() {return {CanvasPath: this.props};}, xbd: function() {return CanvasPathTag(this.props);}, drawArea: function() {let x, y, maxX, minX, maxY, minY, p; this._reset(); ({x, y} = this.nextPoint); maxX = minX = x; maxY = minY = y; p = null; while (p = this.nextPoint) {({x, y} = p); maxX = max(maxX, x); maxY = max(maxY, y); minX = min(minX, x); minY = min(minY, y);}; return rect(minX, minY, maxX - minX, maxY - minY);}, nextPoint: function() {let points, _scaleY, _scaleX, _addX, _addY, x, y; ({points, _scaleY, _scaleX, _addX, _addY} = this); return (this._pointIndex < points.length) ? (x = points[this._pointIndex++], y = points[this._pointIndex++], {x: x * _scaleX + _addX, y: y * _scaleY + _addY}) : undefined;}, nextRadii: function() {return this.radii[this._radiiIndex++];}}); fixedPointScaler = 1 / maxFixedPointValue; this.prototype.getNextX = function() {return this.points[this._pointIndex++] * fixedPointScaler;}; this.prototype.getNextY = function() {return this.points[this._pointIndex++] * fixedPointScaler;}; this.prototype.removeStyles = function() {return this.styleProps = null;}; this.prototype.normalize = function(drawArea = this.drawArea) {let points, writeIndex, writeXScaler, subX, writeYScaler, subY, p; if (this.x !== 0 || this.y !== 0 || this.scale !== 1 || this.aspectRatio !== 1 || drawArea.area !== 1) {this._reset(); points = this.points; writeIndex = 0; writeXScaler = maxFixedPointValue / drawArea.w; subX = drawArea.x; writeYScaler = maxFixedPointValue / drawArea.h; subY = drawArea.y; p = null; while (p = this.nextPoint) {let x, y, wx, wy; ({x, y} = p); points[writeIndex++] = wx = (x - subX) * writeXScaler + .5 | 0; points[writeIndex++] = wy = (y - subY) * writeYScaler + .5 | 0;}; this.x = this.y = 0; this.scale = 1; this.aspectRatio = 1;}; return this;}; this.prototype.applyPathFit = function(context, area, options) {let top, left, w, h, areaAspectRatio, aspectRatio, scale, w2, h2, ratioRatio; top = area.top; left = area.left; w = area.w; h = area.h; areaAspectRatio = area.aspectRatio; aspectRatio = this.aspectRatio; if (Caf.exists(options)) {scale = options.scale;}; scale != null ? scale : scale = 1; w2 = w; h2 = h; if (1 <= (ratioRatio = aspectRatio / areaAspectRatio)) {top += (h - (h2 = h / ratioRatio)) / 2;} else {left += (w - (w2 = w * ratioRatio)) / 2;}; if (scale != null) {left += w2 * (1 - scale) / 2; top += h2 * (1 - scale) / 2; w2 *= scale; h2 *= scale;}; return this.applyRawPath(context, Matrix.scaleXY(w2, h2).translateXY(left, top));}; this.prototype.applyRawPath = function(context, where) {let matrix, to, i1, by; matrix = (() => {switch (false) {case !(Caf.is(where, Matrix)): return where; case !(Caf.is(where, Rectangle)): return Matrix.scaleXY(where.w, where.h).translateXY(where.x, where.y); default: return Matrix.scale(point(where));};})(); this._reset(); return (to = this.commands.length, i1 = 0, by = (i1 < to) ? 1 : -1, (() => {while (by > 0 && i1 < to || by < 0 && i1 > to) {let i, commandPair; i = i1; commandPair = this.commands[i]; this._applyCommand(commandPair >> 4, context, matrix); this._applyCommand(commandPair & 0xf, context, matrix); i1 += by;};})(), to);}; this.prototype.applyPath = function(context, where) {log.warn("DEPRICATED: Art.CanvasPath.applyPath - use applyRawPath"); return this.applyRawPath(context, where);}; this.prototype.getNextTransformedPoint = function(matrix) {let x0, y0; x0 = this.getNextX(); y0 = this.getNextY(); return {x: matrix.transformX(x0, y0), y: matrix.transformY(x0, y0)};}; this.prototype._applyCommand = function(command, context, matrix) {let x, y, x1, y1, x2, y2, x3, y3; return (() => {switch (command) {case noopCommand: return null; case beginPathCommand: return null; case closePathCommand: return null; case moveToCommand: ({x, y} = this.getNextTransformedPoint(matrix)); return context.moveTo(x, y); case lineToCommand: ({x, y} = this.getNextTransformedPoint(matrix)); return context.lineTo(x, y); case quadraticCurveToCommand: ({x: x1, y: y1} = this.getNextTransformedPoint(matrix)); ({x: x2, y: y2} = this.getNextTransformedPoint(matrix)); return context.quadraticCurveTo(x1, y1, x2, y2); case bezierCurveToCommand: ({x: x1, y: y1} = this.getNextTransformedPoint(matrix)); ({x: x2, y: y2} = this.getNextTransformedPoint(matrix)); ({x: x3, y: y3} = this.getNextTransformedPoint(matrix)); return context.bezierCurveTo(x1, y1, x2, y2, x3, y3); case arcCommand: ({x, y} = this.getNextTransformedPoint(matrix)); return context.arcCommand(x, y, this.nextRadii, this.nextRadii, this.nextRadii); case antiArcCommand: ({x, y} = this.getNextTransformedPoint(matrix)); return context.arcCommand(x, y, this.nextRadii, this.nextRadii, this.nextRadii, true);};})();}; this.prototype._reset = function() {let x, y, aspectRatio, scale, temp; this._pointIndex = this._radiiIndex = this._commandIndex = 0; temp = this; x = temp.x; y = temp.y; aspectRatio = temp.aspectRatio; scale = temp.scale; this._scaleX = this._scaleY = scale; if (aspectRatio > 1) {this._scaleY /= aspectRatio;} else {this._scaleX *= aspectRatio;}; this._addX = x != null ? x : 0; this._addY = y != null ? y : 0; this._scaleX /= maxFixedPointValue; return this._scaleY /= maxFixedPointValue;}; this.prototype._initFromProps = function(props) {let temp, temp1, temp2, temp3; this.styleProps = extractStyleProps(props); this.points = props.points; this.radii = props.radii; this.commands = props.commands; this.x = parseFloat(((temp = props.x) != null ? temp : 0)); this.y = parseFloat(((temp1 = props.y) != null ? temp1 : 0)); this.aspectRatio = parseFloat(((temp2 = props.aspectRatio) != null ? temp2 : 1)); this.scale = parseFloat(((temp3 = props.scale) != null ? temp3 : 1)); this.name = props.name; return this._reset();}; this.prototype._initFromXbd = function(xbdTag) {let commands, radii, points, x, y, scale, aspectRatio, name, temp, temp1, temp2, temp3, temp4; temp = xbdTag.attrs; commands = temp.commands; radii = temp.radii; points = temp.points; x = temp.x; y = temp.y; scale = temp.scale; aspectRatio = temp.aspectRatio; name = temp.name; if (commands != null) {this.commands = new commandArrayType(commands.binaryString.buffer);}; if (points != null) {this.points = new valueArrayType(points.binaryString.buffer);}; if (radii != null) {this.radii = new valueArrayType(radii.binaryString.buffer);}; this.x = parseFloat(((temp1 = Caf.exists(x) && x.toString()) != null ? temp1 : 0)); this.y = parseFloat(((temp2 = Caf.exists(y) && y.toString()) != null ? temp2 : 0)); this.scale = parseFloat(((temp3 = Caf.exists(scale) && scale.toString()) != null ? temp3 : 1)); this.aspectRatio = parseFloat(((temp4 = Caf.exists(aspectRatio) && aspectRatio.toString()) != null ? temp4 : 1)); this.name = Caf.exists(name) && name.toString(); return this.styleProps = Caf.object(extractStyleProps(xbdTag.attrs), (v, k) => v.toString());}; extractStyleProps = function(props) {let fillStyle, strokeStyle, lineWidth, miterLimit, lineCap, lineJoin; return merge(({fillStyle, strokeStyle, lineWidth, miterLimit, lineCap, lineJoin} = props, {fillStyle, strokeStyle, lineWidth, miterLimit, lineCap, lineJoin}));};});});});
//# sourceMappingURL=CanvasPath.js.map