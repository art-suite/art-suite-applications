"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {return function(superClass) {let PusherPipelineMixin; return PusherPipelineMixin = Caf.defClass(class PusherPipelineMixin extends superClass {}, function(PusherPipelineMixin, classSuper, instanceSuper) {Caf.isF(this.abstractClass) && this.abstractClass(); this.prototype.getChannelsAndKeysToUpdateOnRecordChange = function(updatedRecord) {return Caf.object(this.queries, (pipelineQuery) => pipelineQuery.toKeyString(updatedRecord));}; this.filter(require('./PusherFilter')); this.fluxModelMixin(require('./PusherArtModelMixin'));});};})();});
//# sourceMappingURL=PusherPipelineMixin.js.map
