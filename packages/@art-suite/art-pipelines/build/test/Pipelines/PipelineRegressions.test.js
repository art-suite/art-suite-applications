"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["ArtConfig", "test", "Pipeline", "assert"], [global, require('../StandardImport')], (ArtConfig, test, Pipeline, assert) => {ArtConfig.configure(); return test("simple filter which didn't work in Browser-ReactJS land", function() {let user, User; ({user} = User = Caf.defClass(class User extends Pipeline {}, function(User, classSuper, instanceSuper) {this.publicRequestTypes("get"); this.filter({before: {get: function(request) {return request.with({key: request.key || "Alice"});}}, after: {get: function(response) {return response.withData({name: `${Caf.toString(response.data.name)} is Awesome`});}}}); this.handlers({get: function(request) {return {name: request.key};}});})); return user.get().then((result) => {assert.eq(result, {name: "Alice is Awesome"}); return user.get("Bob");}).then((result) => assert.eq(result, {name: "Bob is Awesome"}));});});});
//# sourceMappingURL=PipelineRegressions.test.js.map