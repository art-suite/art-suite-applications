"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "Lib", "assert"], [global, require('./StandardImport')], (test, Lib, assert) => {test("validateInputs", function() {Lib.validateInputs(true); return assert.rejects(() => Lib.validateInputs(false));}); return test("hardDeprecatedFunction", function() {let f; f = Lib.hardDeprecatedFunction("my message"); return assert.rejects(() => f());});});});
//# sourceMappingURL=Lib.test.js.map
