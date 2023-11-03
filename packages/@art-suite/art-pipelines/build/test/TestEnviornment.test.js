"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "assert", "pipelineRegistry", "Pipeline"], [global, require('./StandardImport'), require('./getSimulatedTestingFromClientResources')()], (test, assert, pipelineRegistry, Pipeline) => {test("in tests, we default to the :client location", function() {return assert.eq(pipelineRegistry.location, "client");}); test("in tests, use a custom pipelineRegistry", function() {return assert.neq(pipelineRegistry, require('../../build').pipelineRegistry);}); return test("in tests, the Pipeline class was extended to use our custom pipelineRegistry", function() {return assert.eq(Pipeline.getRegistry(), pipelineRegistry);});});});
//# sourceMappingURL=TestEnviornment.test.js.map
