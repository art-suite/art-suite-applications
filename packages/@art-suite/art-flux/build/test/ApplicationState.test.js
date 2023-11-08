"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "test", "ApplicationState"], [global, require('./StandardImport')], (describe, test, ApplicationState) => {return describe({create: function() {return test("basic", () => {let MyState; return MyState = Caf.defClass(class MyState extends ApplicationState {}, function(MyState, classSuper, instanceSuper) {this.stateFields({foo: "bar"});});});}});});});
//# sourceMappingURL=ApplicationState.test.js.map
