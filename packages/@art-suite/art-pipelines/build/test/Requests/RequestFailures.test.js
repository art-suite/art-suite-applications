"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "Pipeline", "assert"], [global, require('../StandardImport')], (describe, test, Pipeline, assert) => {require('art-config').configure(); return describe({failures: function() {return test("no handler", () => {let myPipeline, MyPipeline; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.publicRequestTypes("get");})); return assert.rejects(myPipeline.get("bar"));});}});});});
//# sourceMappingURL=RequestFailures.test.js.map
