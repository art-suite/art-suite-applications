"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["config"], [global, require('art-standard-lib'), require('./Config')], (config) => {return {cacheSafeUrl: function(path) {let anchor; if (/#/.test(path)) {([path, anchor] = path.split("#")); anchor = "#" + anchor;}; return `/${Caf.toString(path)}?${Caf.toString(config.app.version)}${Caf.toString(anchor)}`;}};});});
//# sourceMappingURL=Lib.js.map
