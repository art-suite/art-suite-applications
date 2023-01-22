"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {require('./ArtEryFluxModel').bindWithArtEry(); return {defineArtEryPipelineFluxModels: require('./ArtEryFluxModel').defineModelsForAllPipelines};});
//# sourceMappingURL=Flux.js.map
