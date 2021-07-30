"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let MessageRemote2B; return MessageRemote2B = Caf.defClass(class MessageRemote2B extends require('../SimpleStore') {}, function(MessageRemote2B, classSuper, instanceSuper) {this.publicRequestTypes("create", "get", "update"); this.remoteServer("http://localhost:8085"); this.addDatabaseFiltersV2({linkFilterVersion: "transition2B", fields: {userRemote2B: ["autoCreate", "link", "prefetch"], message: "trimmedString"}});});})();});
//# sourceMappingURL=MessageRemote2B.js.map
