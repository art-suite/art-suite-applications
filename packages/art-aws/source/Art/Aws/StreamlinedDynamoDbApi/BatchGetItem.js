"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["merge"], [global, require('art-standard-lib')], (merge) => {let BatchGetItem; return BatchGetItem = Caf.defClass(class BatchGetItem extends require('./TableApiBaseClass') {}, function(BatchGetItem, classSuper, instanceSuper) {this.prototype.translateParams = function(params) {this._translateSelect(params); this._target.RequestItems = {[this._getTableName(params)]: merge({Keys: Caf.array(params.keys, (preKey) => this._getTranslatedKey(preKey)), ProjectionExpression: this._target.ProjectionExpression})}; delete this._target.ProjectionExpression; return this._target;};});});});
//# sourceMappingURL=BatchGetItem.js.map
