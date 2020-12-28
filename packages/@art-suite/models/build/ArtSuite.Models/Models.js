"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {models: require('./ModelRegistry').models, fluxStore: require('./FluxStore').fluxStore, _reset: function() {require('./FluxStore').fluxStore._reset(); return require('./ModelRegistry')._reset();}};});
//# sourceMappingURL=Models.js.map
