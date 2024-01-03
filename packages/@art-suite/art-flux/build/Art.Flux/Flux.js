"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["ModelRegistry", "Neptune", "ArtModelSubscriptionsMixin"], [global, require('@art-suite/art-models')], (ModelRegistry, Neptune, ArtModelSubscriptionsMixin) => {let modelRegistry, fluxStore, GlobalEpochCycle, base, base1; modelRegistry = ModelRegistry.singleton; fluxStore = modelRegistry.modelStore; if (GlobalEpochCycle = Caf.exists(base = Neptune.Art.Engine) && (Caf.exists(base1 = base.Core) && base1.GlobalEpochCycle)) {GlobalEpochCycle.singleton.includeFlux(fluxStore);}; return {ModelRegistry, models: ModelRegistry.models, modelRegistry, fluxStore, FluxStore: {fluxStore}, FluxSubscriptionsMixin: ArtModelSubscriptionsMixin};});});
//# sourceMappingURL=Flux.js.map
