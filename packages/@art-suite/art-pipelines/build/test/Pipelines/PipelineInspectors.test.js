"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Pipeline", "test", "PipelineRegistry", "assert", "Object"], [global, require('../StandardImport')], (Pipeline, test, PipelineRegistry, assert, Object) => {let myPipeline, MyPipeline; ({myPipeline} = MyPipeline = Caf.defClass(class MyPipeline extends Pipeline {}, function(MyPipeline, classSuper, instanceSuper) {this.pipelineRegistry(new PipelineRegistry); this.filter({before: {get: function(request) {return request;}}}); this.filter({after: {all: function(response) {return response;}}}); this.fields({userId: "number"}); this.publicHandlers({get: function(request) {return this._myState;}, set: function(request) {return this._myState = request.data;}}); this.handlers({hiddenHandler: function() {return "bar";}});})); test("inspectedObjects", function() {let inspectedObjects; inspectedObjects = myPipeline.inspectedObjects; return assert.isPlainObject(inspectedObjects);}); return test("pipelineReport", function() {let pipelineReport; pipelineReport = myPipeline.pipelineReport; assert.eq(["userId"], Object.keys(pipelineReport.fields).sort()); assert.eq(["get", "hiddenHandler", "set"], Object.keys(pipelineReport.processing.client).sort()); return assert.eq(["get", "hiddenHandler", "set"], Object.keys(pipelineReport.processing.server).sort());});});});
//# sourceMappingURL=PipelineInspectors.test.js.map