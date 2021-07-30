"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {let fluxLog; fluxLog = []; return {getFluxLog: function() {return fluxLog;}, resetFluxLog: function() {return fluxLog = [];}};});
//# sourceMappingURL=FluxLog.js.map
