"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseClass"], [global, require('./StandardImport')], (BaseClass) => {let VirtualElementPool; return VirtualElementPool = Caf.defClass(class VirtualElementPool extends BaseClass {constructor(virtualElementClass) {super(...arguments); this.virtualElementClass = virtualElementClass; this._pool = [];};}, function(VirtualElementPool, classSuper, instanceSuper) {this.prototype.checkout = function(elementClassName, props, children) {return (this._pool.length > 0) ? this._pool.pop().init(elementClassName, props, children) : new this.virtualElementClass(elementClassName, props, children);}; this.prototype.checkin = function(virtualElement) {return this._pool.push(virtualElement);};});});});
//# sourceMappingURL=VirtualElementPool.js.map