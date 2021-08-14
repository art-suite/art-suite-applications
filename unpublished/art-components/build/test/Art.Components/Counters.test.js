"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "Counters", "assert"], [global, require('./StandardImport')], (describe, test, Counters, assert) => {return describe({Counters: function() {test("reset", () => {Counters.reset(); return assert.eq(0, Counters.componentsInstantiated);}); return test("componentInstantiated", () => {Counters.reset(); Counters.componentInstantiated(); assert.eq(1, Counters.componentsInstantiated); Counters.reset(); return assert.eq(0, Counters.componentsInstantiated);});}});});});
//# sourceMappingURL=Counters.test.js.map
