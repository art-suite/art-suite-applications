"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "Pipeline", "assert"], [global, require('../StandardImport')], (describe, test, Pipeline, assert) => {return describe({basics: function() {return test("declare fields", () => {let MyPipeline; MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.fields({name: "string", age: "number"}); this.field({address: "string"});}); return assert.eq(MyPipeline.fields, {});});}});});});
//# sourceMappingURL=PipelineFields.js.map
