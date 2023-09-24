"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return {pipelines: require('./PipelineRegistry').pipelineRegistry.pipelines, session: require('./PipelineRegistry').pipelineRegistry.session, pipelineRegistries: require('./PipelineRegistry').pipelineRegistries, pipelineRegistry: require('./PipelineRegistry').pipelineRegistry};});
//# sourceMappingURL=ArtPipelines.js.map
