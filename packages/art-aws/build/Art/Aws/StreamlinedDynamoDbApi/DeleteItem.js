"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let DeleteItem; return DeleteItem = Caf.defClass(class DeleteItem extends require('./TableApiBaseClass') {}, function(DeleteItem, classSuper, instanceSuper) {this.prototype._translateParams = function(params) {this._translateKey(params); this._translateOptionalParams(params); return this._target;}; this.prototype._translateOptionalParams = function(params) {this._translateConditionExpressionParam(params); this._translateConstantParam(params, "returnConsumedCapacity"); this._translateConstantParam(params, "returnItemCollectionMetrics"); return this._translateConstantParam(params, "returnValues");};});})();});
//# sourceMappingURL=DeleteItem.js.map
