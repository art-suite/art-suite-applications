"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Filter", "Array", "vivifyObjectPathAndSet"], [global, require('./StandardImport')], (Filter, Array, vivifyObjectPathAndSet) => {let DataUpdatesFilter; return DataUpdatesFilter = Caf.defClass(class DataUpdatesFilter extends Filter {}, function(DataUpdatesFilter, classSuper, instanceSuper) {this.location("both"); this.group("outer"); this.after({all: function(response) {let dataUpdates, dataDeletes, key, type, responseData, pipelineName, context, groupName, base; return response.isRootRequest ? (() => {switch (response.location) {case "client": return response.tap((response) => this.sendDataEvents(response)); case "server": case "both": return response.withMergedPropsWithoutNulls(({dataUpdates, dataDeletes} = response.context, {dataUpdates, dataDeletes}));};})() : ((key = response.key, type = response.type, responseData = response.responseData, pipelineName = response.pipelineName, context = response.context), groupName = response.isUpdateRequest ? "dataUpdates" : response.isDeleteRequest ? "dataDeletes" : undefined, groupName ? (() => {switch (false) {case !(Caf.is(responseData, Array)): return Caf.each2(responseData, (record) => {key = response.pipeline.toKeyString(record); return vivifyObjectPathAndSet(context, groupName, pipelineName, key, record);}); case !key: case !response.pipeline.isRecord(responseData): responseData != null ? responseData : responseData = Caf.isF((base = response.pipeline).toKeyObject) && base.toKeyObject(key || responseData) || {}; key != null ? key : key = response.pipeline.toKeyString(responseData); return vivifyObjectPathAndSet(context, groupName, pipelineName, key, responseData);};})() : undefined, response);}}); this.prototype.sendDataEvents = function(response) {let pipeline, key, data, pipelines, responseProps, dataUpdates, dataDeletes; pipeline = response.pipeline; key = response.key; data = response.data; pipelines = response.pipelines; responseProps = response.responseProps; dataUpdates = responseProps.dataUpdates; dataDeletes = responseProps.dataDeletes; if (response.isUpdateRequest) {pipeline.dataUpdated(key != null ? key : this.toKeyString(data), data);}; if (response.isDeleteRequest) {pipeline.dataDeleted(key != null ? key : this.toKeyString(data), data);}; this.sendDataUpdateEvents(pipelines, dataUpdates); return this.sendDataDeleteEvents(pipelines, dataDeletes);}; this.prototype.sendDataUpdateEvents = function(pipelines, dataUpdates) {return Caf.each2(dataUpdates || [], (dataUpdatesByKey, pipelineName) => Caf.each2(dataUpdatesByKey, (data, key) => pipelines[pipelineName].dataUpdated(key, data)));}; this.prototype.sendDataDeleteEvents = function(pipelines, dataDeletes) {return Caf.each2(dataDeletes || [], (dataDeletesByKey, pipelineName) => Caf.each2(dataDeletesByKey, (data, key) => pipelines[pipelineName].dataDeleted(key, data)));};});});});
//# sourceMappingURL=DataUpdatesFilter.js.map