"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let UserRemote2A; return UserRemote2A = Caf.defClass(class UserRemote2A extends require('../SimpleStore') {}, function(UserRemote2A, classSuper, instanceSuper) {this.publicRequestTypes("create", "get", "update"); this.remoteServer("http://localhost:8085"); this.addDatabaseFiltersV2({linkFilterVersion: "transition2A", fields: {name: "trimmedString"}});});})();});
//# sourceMappingURL=UserRemote2A.js.map
