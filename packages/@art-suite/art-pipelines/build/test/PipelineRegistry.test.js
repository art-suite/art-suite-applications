"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "assert", "PipelineRegistry", "Lib"], [global, require('./StandardImport')], (describe, test, assert, PipelineRegistry, Lib) => {return describe({options: function() {test("default-name", () => assert.eq((new PipelineRegistry).name, "PipelineRegistry")); test("name", () => assert.eq((new PipelineRegistry({name: "Alice"})).name, "Alice")); test("default-defaultLocation", () => assert.eq((new PipelineRegistry).defaultLocation, Lib.getDefaultLocation())); return test("defaultLocation", () => assert.eq((new PipelineRegistry({defaultLocation: "client"})).defaultLocation, "client"));}});});});
//# sourceMappingURL=PipelineRegistry.test.js.map
