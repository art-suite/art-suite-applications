"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseClass", "Object", "Error", "timeout"], [global, require('./StandardImport')], (BaseClass, Object, Error, timeout) => {let PrefetchedRecordsCache; return PrefetchedRecordsCache = Caf.defClass(class PrefetchedRecordsCache extends BaseClass {constructor() {super(...arguments); this._repository = [];};}, function(PrefetchedRecordsCache, classSuper, instanceSuper) {this._prefetchedRecordsCaches = {}; this.getPrefetchedRecordsCacheForPipeline = (pipeline) => {let temp, base; return ((temp = (base = this._prefetchedRecordsCaches)[pipeline.registry.uniqueName]) != null ? temp : base[pipeline.registry.uniqueName] = new PrefetchedRecordsCache);}; this.getPrefetchedRecord = (pipeline, key) => this.getPrefetchedRecordsCacheForPipeline(pipeline).get(pipeline.name, key); this.addPrefetchedRecords = (pipeline, recordsByPipelineNameAndKey, expirationSeconds) => this.getPrefetchedRecordsCacheForPipeline(pipeline).addPrefetchedRecords(recordsByPipelineNameAndKey, expirationSeconds); this.prototype.get = function(pipelineName, key) {return Caf.find(this._repository, (r) => {let base; return Caf.exists(base = r[pipelineName]) && base[key];});}; this.prototype.addPrefetchedRecords = function(recordsByPipelineNameAndKey, expirationSeconds = 1) {if (!(Caf.is(recordsByPipelineNameAndKey, Object))) {throw new Error("expecting Object");}; this._repository.push(recordsByPipelineNameAndKey); return timeout(expirationSeconds * 1000, () => this._repository = Caf.array(this._repository, null, (r) => r !== recordsByPipelineNameAndKey));};});});});
//# sourceMappingURL=PrefetchedRecordsCache.js.map