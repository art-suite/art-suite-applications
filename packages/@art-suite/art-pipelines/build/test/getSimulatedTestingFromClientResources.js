"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return function() {let pipelineRegistry, Pipeline; pipelineRegistry = new (require('../../build').PipelineRegistry)({location: "client"}); Pipeline = Caf.defClass(class Pipeline extends require('../../build').Pipeline {}, function(Pipeline, classSuper, instanceSuper) {this.registry(pipelineRegistry);}); return {Pipeline, pipelineRegistry, pipelines: pipelineRegistry.pipelines, session: pipelineRegistry.session};};});
//# sourceMappingURL=getSimulatedTestingFromClientResources.js.map
