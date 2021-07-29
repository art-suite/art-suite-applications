"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["config", "compactFlatten"], [global, require('./StandardImport')], (config, compactFlatten) => {return {signSession: require('./ArtErySessionManager').signSession, start: (options = {}) => {config.location = "server"; return require('art-express-server').start({verbose: config.verbose, allowAllCors: true}, options, {handlers: compactFlatten([require('./ArtEryHandler'), require('./ArtEryInfoHandler'), options.handlers])});}};});});
//# sourceMappingURL=Server.js.map
