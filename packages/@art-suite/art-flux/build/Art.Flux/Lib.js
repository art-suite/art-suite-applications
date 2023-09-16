"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["log"], [global, require('art-standard-lib')], (log) => {let warned, artFluxDeprecatedWarning; warned = {}; return {artFluxDeprecatedWarning: artFluxDeprecatedWarning = function(deprecated, useInstead) {return !warned[deprecated] ? log.warn(`ArtFlux >> ArtSuite/ArtModels transition -- DEPRICATED: model.${Caf.toString(deprecated)}. ` + (useInstead ? `Use model.${Caf.toString(useInstead)} instead.` : "No longer supported.")) : undefined;}};});});
//# sourceMappingURL=Lib.js.map
