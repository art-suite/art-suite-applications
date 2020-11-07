"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let Scan; return Scan = Caf.defClass(class Scan extends require('./TableApiBaseClass') {}, function(Scan, classSuper, instanceSuper) {this.prototype._translateParams = function(params) {this._translateOptionalParams(params); return this._target;}; this.prototype._translateOptionalParams = function(params) {this._translateLimit(params); return this._translateExclusiveStartKey(params);};});})();});
//# sourceMappingURL=Scan.js.map
