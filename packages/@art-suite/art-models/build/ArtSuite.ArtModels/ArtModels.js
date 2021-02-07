"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {models: require('./ArtModelRegistry').models, artModelStore: require('./ArtModelStore').artModelStore, _resetArtSuiteModels: function() {return require('./ArtModelStore').artModelStore._reset().then(() => require('./ArtModelRegistry')._reset());}};});
//# sourceMappingURL=ArtModels.js.map
