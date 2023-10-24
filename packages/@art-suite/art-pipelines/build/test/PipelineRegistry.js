"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "PipelineRegistry", "assert"], [global, require('./StandardImport')], (test, PipelineRegistry, assert) => {return test("options", function() {let pipelineRegistry; pipelineRegistry = new PipelineRegistry({name: "Alice"}); return assert.eq(pipelineRegistry.name, "Alice");});});});
//# sourceMappingURL=PipelineRegistry.js.map
