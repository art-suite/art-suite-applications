"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Configurable"], [global, require('./StandardImport'), require('art-config')], (Configurable) => {let Config; return Config = Caf.defClass(class Config extends Configurable {}, function(Config, classSuper, instanceSuper) {this.defaults({verbose: false, returnProcessingInfoToClient: false, saveSessions: true});});});});
//# sourceMappingURL=Config.js.map
