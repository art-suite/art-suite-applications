"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let MessageRemote; return MessageRemote = Caf.defClass(class MessageRemote extends require('./SimpleStore') {}, function(MessageRemote, classSuper, instanceSuper) {this.publicRequestTypes("create", "get", "update"); this.remoteServer("http://localhost:8085"); this.addDatabaseFiltersV2({linkFilterVersion: 2, fields: {userRemote: ["autoCreate", "link", "prefetch"], message: "trimmedString"}});});})();});
//# sourceMappingURL=MessageRemote.js.map
