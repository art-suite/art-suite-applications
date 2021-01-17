"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {models: require('./ModelRegistry').models, modelStore: require('./ModelStore').modelStore, _resetArtSuiteModels: function() {return require('./ModelStore').modelStore._reset().then(() => require('./ModelRegistry')._reset());}};});
//# sourceMappingURL=Models.js.map
