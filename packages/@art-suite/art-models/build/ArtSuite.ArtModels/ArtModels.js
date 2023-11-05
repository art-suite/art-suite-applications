"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {modelRegistry: require('./ModelRegistry').modelRegistry, models: require('./ModelRegistry').modelRegistry.models, artModelStore: require('./ModelRegistry').modelRegistry.modelStore, ArtModelSubscriptionsMixin: require('./ModelSubscriptionsMixin'), ArtModel: require('./Model')};});
//# sourceMappingURL=ArtModels.js.map
