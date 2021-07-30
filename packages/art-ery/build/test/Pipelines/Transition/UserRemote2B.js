"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let UserRemote2B; return UserRemote2B = Caf.defClass(class UserRemote2B extends require('../SimpleStore') {}, function(UserRemote2B, classSuper, instanceSuper) {this.publicRequestTypes("create", "get", "update"); this.remoteServer("http://localhost:8085"); this.addDatabaseFiltersV2({linkFilterVersion: "transition2B", fields: {name: "trimmedString"}});});})();});
//# sourceMappingURL=UserRemote2B.js.map
