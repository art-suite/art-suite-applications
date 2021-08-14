"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Promise", "mountRootComponent", "log"], [global, require('./StandardImport'), require('./RootComponents')], (Promise, mountRootComponent, log) => {let Init; return Init = Caf.defClass(class Init extends Object {}, function(Init, classSuper, instanceSuper) {this.init = function(options) {return Promise.then(() => mountRootComponent(options.render())).tapCatch((error) => log.error("Art.Components.init: failed", error));};});});});
//# sourceMappingURL=Init.js.map
