"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["log"], [global, require('./StandardImport')], (log) => {return {defineModelsForAllPipelines: require('./ArtEryModel').defineModelsForAllPipelines, defineArtEryPipelineFluxModels: function() {log.warn("DEPRECATED: defineArtEryPipelineFluxModels(). Use: defineModelsForAllPipelines()."); return require('./ArtEryModel').defineModelsForAllPipelines;}};});});
//# sourceMappingURL=Flux.js.map
