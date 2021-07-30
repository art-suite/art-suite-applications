"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let UserRemote; return UserRemote = Caf.defClass(class UserRemote extends require('./SimpleStore') {}, function(UserRemote, classSuper, instanceSuper) {this.publicRequestTypes("create", "get", "update"); this.remoteServer("http://localhost:8085"); this.addDatabaseFiltersV2({linkFilterVersion: 2, fields: {name: "trimmedString"}});});})();});
//# sourceMappingURL=UserRemote.js.map
