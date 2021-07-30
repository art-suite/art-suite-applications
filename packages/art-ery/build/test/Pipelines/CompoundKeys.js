"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let CompoundKeys; return CompoundKeys = Caf.defClass(class CompoundKeys extends require("./SimpleStore") {}, function(CompoundKeys, classSuper, instanceSuper) {this.remoteServer("http://localhost:8085"); this.keyFields("postId/userId");});})();});
//# sourceMappingURL=CompoundKeys.js.map
