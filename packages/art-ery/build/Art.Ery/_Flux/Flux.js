"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {let ArtEryFluxModel; ArtEryFluxModel = require('./ArtEryFluxModel'); ArtEryFluxModel.bindWithArtEry(); return {defineArtEryPipelineFluxModels: ArtEryFluxModel.defineModelsForAllPipelines};});
//# sourceMappingURL=Flux.js.map
