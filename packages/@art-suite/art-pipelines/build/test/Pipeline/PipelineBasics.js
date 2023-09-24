"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "Pipeline", "assert"], [global, require('../StandardImport')], (test, Pipeline, assert) => {return {suite: {propsToKey: function() {return test("pipeline.propsToKey", () => {let user, User; ({user} = User = Caf.defClass(class User extends Pipeline {})); assert.eq("user1", user.propsToKey({user: {id: "user1"}})); assert.eq("user2", user.propsToKey({userId: "user2"})); assert.eq("user3", user.propsToKey({user: {id: "user3"}, userId: "user4"}), "whole object has precidence"); return assert.eq(undefined, user.propsToKey({}));});}}};});});
//# sourceMappingURL=PipelineBasics.js.map
