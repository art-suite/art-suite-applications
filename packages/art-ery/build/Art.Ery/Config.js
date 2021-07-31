"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let Config; return Config = Caf.defClass(class Config extends require('art-config').Configurable {}, function(Config, classSuper, instanceSuper) {this.defaults({tableNamePrefix: "", location: "both", saveSessions: true, apiRoot: "api", remoteServer: null, verbose: false, returnProcessingInfoToClient: false, server: {privateSessionKey: "todo+generate+your+one+unique+key"}}); this.getPrefixedTableName = (tableName) => `${Caf.toString(this.config.tableNamePrefix)}${Caf.toString(tableName)}`;});})();});
//# sourceMappingURL=Config.js.map
