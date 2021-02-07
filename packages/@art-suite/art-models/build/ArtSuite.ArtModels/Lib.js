"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Error", "formattedInspect", "compactFlatten"], [global, require('./StandardImport')], (Error, formattedInspect, compactFlatten) => {let hardDeprecatedFunction; return {validateInputs: function(valid, message, inputs) {return !valid ? (() => {throw new Error(`${Caf.toString(message)}\n${Caf.toString(formattedInspect({inputs}))}`);})() : undefined;}, hardDeprecatedFunction: hardDeprecatedFunction = function(message) {return () => (() => {throw new Error(`DEPRECATED: ${Caf.toString(message)}`);})();}, hardDeprecatedFunctionsAsMap: function(...names) {return Caf.object(compactFlatten(names), (name) => hardDeprecatedFunction(name));}};});});
//# sourceMappingURL=Lib.js.map
