"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Neptune", "ModelStore", "ModelRegistry", "ArtModelSubscriptionsMixin"], [global, require('@art-suite/art-models')], (Neptune, ModelStore, ModelRegistry, ArtModelSubscriptionsMixin) => {let GlobalEpochCycle, fluxStore, base, base1; if (GlobalEpochCycle = Caf.exists(base = Neptune.Art.Engine) && (Caf.exists(base1 = base.Core) && base1.GlobalEpochCycle)) {GlobalEpochCycle.singleton.includeFlux(ModelStore.singleton);}; return {ModelRegistry, models: ModelRegistry.models, fluxStore: fluxStore = ModelRegistry.singleton, FluxStore: {fluxStore}, FluxSubscriptionsMixin: ArtModelSubscriptionsMixin};});});
//# sourceMappingURL=Flux.js.map
