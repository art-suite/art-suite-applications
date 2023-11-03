"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["compactFlatten"], [global, require('art-standard-lib')], (compactFlatten) => {return [require('art-standard-lib'), require('art-class-system'), require('art-communication-status'), require('art-testbench'), require('../../build'), {simplifyFilterLog: function(filterLog) {return Caf.array(filterLog, ({name, context, location, status}) => compactFlatten([location, status, context, name]).join("-"));}}];});});
//# sourceMappingURL=StandardImport.js.map
