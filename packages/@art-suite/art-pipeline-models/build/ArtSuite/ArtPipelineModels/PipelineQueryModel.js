"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["KeyFieldsMixin", "ArtModel", "Promise", "isArray", "arrayWith", "arrayWithout", "propsEq", "log", "arrayWithElementReplaced", "merge"], [global, require('./StandardImport')], (KeyFieldsMixin, ArtModel, Promise, isArray, arrayWith, arrayWithout, propsEq, log, arrayWithElementReplaced, merge) => {let PipelineQueryModel; return PipelineQueryModel = Caf.defClass(class PipelineQueryModel extends KeyFieldsMixin(ArtModel) {}, function(PipelineQueryModel, classSuper, instanceSuper) {this.abstractClass(); this.prototype.loadData = function(key) {return Promise.resolve(this.query(key, this.pipeline)).then((data) => this.localSort(data));}; this.getter("recordsModel pipeline queryName"); this.prototype.modelStoreEntryUpdated = function({key, subscribers}) {let temp; if (subscribers.length > 0) {this._pipeline.subscribe(key, ((temp = this._sharedSubscriptionFunction) != null ? temp : this._sharedSubscriptionFunction = (eventType, key, data, queryKey) => (() => {switch (eventType) {case "update": return this.dataUpdated(queryKey, data); case "delete": return this.dataDeleted(queryKey, data);};})()), this.queryName);}; return instanceSuper.modelStoreEntryUpdated.apply(this, arguments);}; this.prototype.modelStoreEntryRemoved = function({key}) {this._pipeline.unsubscribe(key, this._sharedSubscriptionFunction, this.queryName); return instanceSuper.modelStoreEntryRemoved.apply(this, arguments);}; this.prototype.query = function(key) {return this._pipeline[this.queryName]({key, props: {include: "auto"}});}; this.prototype.localSort = function(queryData) {return queryData;}; this.prototype.localMerge = function(previousQueryData, updatedRecordData, wasDeleted) {let updatedRecordDataKey, from, into, to, i1; previousQueryData != null ? previousQueryData : previousQueryData = []; if (!(updatedRecordData || wasDeleted)) {return previousQueryData;}; if (!(!(previousQueryData != null) || isArray(previousQueryData))) {return previousQueryData;}; if (!((Caf.exists(previousQueryData) && previousQueryData.length) > 0)) {if (wasDeleted) {return [];} else {return [updatedRecordData];};}; updatedRecordDataKey = this.recordsModel.toKeyString(updatedRecordData); from = previousQueryData; into = from; if (from != null) {to = from.length; i1 = 0; while (i1 < to) {let currentRecordData, i; currentRecordData = from[i1]; i = i1; if (updatedRecordDataKey === this.recordsModel.toKeyString(currentRecordData)) {if (wasDeleted) {return arrayWithout(previousQueryData, i);} else {if (propsEq(currentRecordData, updatedRecordData)) {log(`saved 1 ArtModelStore update due to no-change check! (model: ${Caf.toString(this.name)}, record-key: ${Caf.toString(updatedRecordDataKey)})`); return null;} else {return arrayWithElementReplaced(previousQueryData, updatedRecordData, i);};};}; i1++;};}; into; return wasDeleted ? previousQueryData : arrayWith(previousQueryData, updatedRecordData);}; this.prototype.dataUpdated = function(queryKey, singleRecordData) {return this._updateArtModelStoreIfExists(queryKey, singleRecordData);}; this.prototype.dataDeleted = function(queryKey, singleRecordData) {return this._updateArtModelStoreIfExists(queryKey, singleRecordData, true);}; this.prototype._updateArtModelStoreIfExists = function(queryKey, singleRecordData, wasDeleted) {return this.getModelRecord(queryKey) ? this.updateModelRecord(queryKey, (oldartModelRecord) => {let merged; return (merged = this.localMerge(oldartModelRecord.data, singleRecordData, wasDeleted)) ? merge(oldartModelRecord, {data: this.localSort(merged)}) : oldartModelRecord;}) : undefined;};});});});
//# sourceMappingURL=PipelineQueryModel.js.map