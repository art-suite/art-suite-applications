"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseObject", "Session", "PrefetchedRecordsCache", "log", "Error", "formattedInspect"], [global, require('./StandardImport'), {Session: require('./Session'), PrefetchedRecordsCache: require('./PrefetchedRecordsCache')}], (BaseObject, Session, PrefetchedRecordsCache, log, Error, formattedInspect) => {let PipelineRegistry; return PipelineRegistry = Caf.defClass(class PipelineRegistry extends BaseObject {constructor(name) {super(...arguments); this._name = name != null ? name : this.class.name; this._pipelines = {}; this._registryRegistry();};}, function(PipelineRegistry, classSuper, instanceSuper) {let pipelineRegistries; this.singletonClass(); this.pipelineRegistries = pipelineRegistries = []; this.prototype._registryRegistry = function() {let registryNumber; registryNumber = pipelineRegistries.length; this._uniqueName = `${Caf.toString(this.name)}${Caf.toString(registryNumber)}`; return pipelineRegistries[registryNumber] = this;}; this.getter("name", "pipelines", "uniqueName"); this.getter({session: function() {let temp; return ((temp = this._session) != null ? temp : this._session = new Session(null, `ArtPipelines-${Caf.toString(this.name)}-Session`, this));}, prefetchedRecordsCache: function() {let temp; return ((temp = this._prefetchedRecordsCache) != null ? temp : this._prefetchedRecordsCache = new PrefetchedRecordsCache(this));}, inspectedObjects: function() {return {name: this.name, uniqueName: this.uniqueName, pipelines: this.pipelines};}}); this.prototype.register = function({singleton, _aliases, name}) {Caf.each2(_aliases, (_, alias) => {if (this.pipelines[alias]) {log({_aliases}); throw new Error(`Error registrying alias ${Caf.toString(formattedInspect(alias))} for Pipeline '${Caf.toString(name)}' - already exists: ${Caf.toString(formattedInspect(this.pipelines[alias]))}`);}; return this.pipelines[alias] = singleton;}); this.pipelines[name = singleton.name] = singleton; return singleton;};});});});
//# sourceMappingURL=PipelineRegistry.js.map