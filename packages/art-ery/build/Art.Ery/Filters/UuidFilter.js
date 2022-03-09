"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Filter", "FieldTypes", "Uuid", "log"], [global, require('./StandardImport'), {Uuid: require('uuid')}], (Filter, FieldTypes, Uuid, log) => {let UuidFilter; return UuidFilter = Caf.defClass(class UuidFilter extends Filter {constructor() {super(...arguments); log.warn("DEPRICATED: UuidFilter. USE: UniqueIdFilter");};}, function(UuidFilter, classSuper, instanceSuper) {this.alwaysForceNewIds = true; this.before({create: function(request) {return request.withMergedData({id: UuidFilter.alwaysForceNewIds ? Uuid.v4() : request.data.id || Uuid.v4()});}}); this.fields({id: FieldTypes.id});});});});
//# sourceMappingURL=UuidFilter.js.map
