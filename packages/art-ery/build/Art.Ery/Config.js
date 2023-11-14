"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Configurable"], [global, require('./StandardImport'), require('art-config')], (Configurable) => {let Config; return Config = Caf.defClass(class Config extends Configurable {}, function(Config, classSuper, instanceSuper) {this.defaults({tableNamePrefix: "", location: "both", apiRoot: "api", remoteServer: null, server: {privateSessionKey: "todo+generate+your+one+unique+key"}, saveSessions: true, verbose: false, returnProcessingInfoToClient: false}); this.getPrefixedTableName = (tableName) => `${Caf.toString(this.config.tableNamePrefix)}${Caf.toString(tableName)}`;});});});
//# sourceMappingURL=Config.js.map
