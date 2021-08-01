"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let Pipeline; return Pipeline = Caf.defClass(class Pipeline extends require('./PipelineArtModelsMixin')(require('./PipelineDbCoreMixin')(require('./PipelineRemoteCoreMixin')(require('./PipelinePublicRequestsMixin')(require('./PipelineCore'))))) {}, function(Pipeline, classSuper, instanceSuper) {this.abstractClass();});})();});
//# sourceMappingURL=Pipeline.js.map
