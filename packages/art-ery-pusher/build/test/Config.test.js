"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "Config"], [global, require('./StandardImport'), require('./Support')], (test, Config) => {return test("onConnected", function() {return Config.onConnected();});});});
//# sourceMappingURL=Config.test.js.map
