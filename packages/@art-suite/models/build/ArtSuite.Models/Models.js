"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {models: require('./ModelRegistry').models, modelStore: require('./ModelStore').modelStore, _resetArtSuiteModels: function() {require('./ModelStore').modelStore._reset(); return require('./ModelRegistry')._reset();}};});
//# sourceMappingURL=Models.js.map
