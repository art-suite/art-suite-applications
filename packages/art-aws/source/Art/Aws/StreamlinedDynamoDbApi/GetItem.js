"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let GetItem; return GetItem = Caf.defClass(class GetItem extends require('./TableApiBaseClass') {}, function(GetItem, classSuper, instanceSuper) {this.prototype._translateParams = function(params) {this._translateKey(params); this._translateOptionalParams(params); return this._target;}; this.prototype._translateOptionalParams = function(params) {this._translateConsistentRead(params); this._translateConsumedCapacity(params); return this._translateSelect(params);};});})();});
//# sourceMappingURL=GetItem.js.map
