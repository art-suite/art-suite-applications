"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Filter"], [global, require('./StandardImport')], (Filter) => {let LinkFieldsFilter2Transition2BFilter; return LinkFieldsFilter2Transition2BFilter = Caf.defClass(class LinkFieldsFilter2Transition2BFilter extends Filter {}, function(LinkFieldsFilter2Transition2BFilter, classSuper, instanceSuper) {this.location("client"); this.before({all: function(response) {return response.withMergedProps({acceptLinkFieldsFilter2Encoding: true});}});});});});
//# sourceMappingURL=LinkFieldsFilter2Transition2BFilter.js.map
