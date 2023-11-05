"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {models: require('./ModelRegistry').models, modelRegistry: require('./ModelRegistry').modelRegistry, ArtModelSubscriptionsMixin: require('./ModelSubscriptionsMixin')};});
//# sourceMappingURL=ArtModels.js.map
