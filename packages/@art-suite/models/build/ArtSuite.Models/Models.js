"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {models: require('./ModelRegistry').models, store: require('./Store').store, _reset: function() {require('./Store').store._reset(); return require('./ModelRegistry')._reset();}};});
//# sourceMappingURL=Models.js.map
