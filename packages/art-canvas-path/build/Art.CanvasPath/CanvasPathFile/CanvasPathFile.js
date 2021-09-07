"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["isBinary", "fromXbd"], [global, require('./StandardImport'), require('art-binary')], (isBinary, fromXbd) => {return {decodeCpf: function(cpf) {let rootTag; rootTag = isBinary(cpf) ? fromXbd(cpf) : cpf; return new (require("./namespace")[rootTag.name])(rootTag);}};});});
//# sourceMappingURL=CanvasPathFile.js.map
