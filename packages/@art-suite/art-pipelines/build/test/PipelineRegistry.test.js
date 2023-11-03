"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "assert", "PipelineRegistry", "Lib"], [global, require('./StandardImport')], (describe, test, assert, PipelineRegistry, Lib) => {return describe({options: function() {test("default-name", () => assert.eq((new PipelineRegistry).name, "PipelineRegistry")); test("name", () => assert.eq((new PipelineRegistry({name: "Alice"})).name, "Alice")); test("default-location", () => assert.eq((new PipelineRegistry).location, Lib.getDefaultLocation())); return test("location", () => assert.eq((new PipelineRegistry({location: "client"})).location, "client"));}});});});
//# sourceMappingURL=PipelineRegistry.test.js.map
