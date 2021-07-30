"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let MessageRemote2A; return MessageRemote2A = Caf.defClass(class MessageRemote2A extends require('../SimpleStore') {}, function(MessageRemote2A, classSuper, instanceSuper) {this.publicRequestTypes("create", "get", "update"); this.remoteServer("http://localhost:8085"); this.addDatabaseFiltersV2({linkFilterVersion: "transition2A", fields: {userRemote2A: ["autoCreate", "link", "prefetch"], message: "trimmedString"}});});})();});
//# sourceMappingURL=MessageRemote2A.js.map
