"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["KeyFieldsMixin", "Pipeline", "randomString", "merge"], [global, require('./StandardImport')], (KeyFieldsMixin, Pipeline, randomString, merge) => {let SimpleStore; return SimpleStore = Caf.defClass(class SimpleStore extends KeyFieldsMixin(Pipeline) {constructor() {super(...arguments); this.db = {};};}, function(SimpleStore, classSuper, instanceSuper) {this.abstractClass(); this.publicRequestTypes("reset", "get", "create", "update", "delete"); this.handlers({reset: function({data}) {this.db = data; return true;}, get: function({key}) {return this.db[key];}, create: function(request) {let key; key = (request.pipeline.keyFields.length > 1) ? request.pipeline.toKeyString(request.requestData) : randomString(8); return this.db[key] = merge(request.data, request.pipeline.toKeyObject(key));}, update: function(request) {let data, key; data = request.data; key = request.key; return this.db[key != null ? key : key = request.pipeline.toKeyString(data)] ? this.db[key] = merge(this.db[key], data) : undefined;}, delete: function(request) {let key, data, found; key = request.key; data = request.data; return (found = this.db[key != null ? key : key = request.pipeline.toKeyString(data)]) ? (delete this.db[key], found) : undefined;}});});});});
//# sourceMappingURL=SimpleStore.js.map