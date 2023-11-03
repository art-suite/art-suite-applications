"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let SimulatedClientServerTransportFilter; return SimulatedClientServerTransportFilter = Caf.defClass(class SimulatedClientServerTransportFilter extends require('./Filter') {}, function(SimulatedClientServerTransportFilter, classSuper, instanceSuper) {this.location("client"); this.group("handler"); this.before({all: function(request) {return request.pipeline.processClientToServerRequest(request);}});});})();});
//# sourceMappingURL=SimulatedClientServerTransportFilter.js.map
