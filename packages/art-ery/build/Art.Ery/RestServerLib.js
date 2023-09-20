"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["getRestClientParamsForArtEryRequest"], [global, require('./StandardImport'), require('./RestClientLib')], (getRestClientParamsForArtEryRequest) => {return {apiReport: function(pipeline, options = {}) {let server, publicOnly; ({server, publicOnly} = options); return Caf.object(pipeline.requestTypes, (type) => {let method, url; ({method, url} = getRestClientParamsForArtEryRequest({server: pipeline.remoteServer || server, type, restPath: pipeline.restPath})); return {[method.toLocaleUpperCase()]: url};}, (type) => !publicOnly || pipeline.getPublicRequestTypes()[type]);}};});});
//# sourceMappingURL=RestServerLib.js.map
