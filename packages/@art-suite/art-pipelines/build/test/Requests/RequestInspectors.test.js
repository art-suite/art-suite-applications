"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["describe", "Pipeline", "test", "Error", "assert", "simplifyFilterLog", "compactFlattenAll"], [global, require('../StandardImport')], (describe, Pipeline, test, Error, assert, simplifyFilterLog, compactFlattenAll) => {require('art-config').configure(); return describe({filterLogging: function() {let user, User; ({user} = User = Caf.defClass(class User extends Pipeline {}, function(User, classSuper, instanceSuper) {this.filter({name: "myServerFilter", before: {get: function(request) {let base; return ((Caf.exists(base = request.data) && base.fail) === "beforeServerFilter") ? (() => {throw new Error;})() : request;}}, after: {get: function(response) {let base; return ((Caf.exists(base = response.request.data) && base.fail) === "afterServerFilter") ? (() => {throw new Error;})() : response;}}}); this.filter({name: "myClientFilter", location: "client", before: {get: function(request) {let base; return ((Caf.exists(base = request.data) && base.fail) === "beforeClientFilter") ? (() => {throw new Error;})() : request;}}, after: {get: function(response) {let base; return ((Caf.exists(base = response.request.data) && base.fail) === "afterClientFilter") ? (() => {throw new Error;})() : response;}}}); this.publicHandler({get: function() {return "hi";}});})); test("server-only filterLog", () => user.get({returnResponse: true, location: "server", session: {}}).then((response) => {let beforeFilterLog, afterFilterLog; assert.eq(simplifyFilterLog(response.beforeFilterLog), beforeFilterLog = ["server-pending-created", "server-pending-beforeFilter-myServerFilter", "server-success-handler-user"]); assert.eq(simplifyFilterLog(response.afterFilterLog), afterFilterLog = ["server-success-afterFilter-myServerFilter", "server-success-completed"]); return assert.eq(simplifyFilterLog(response.filterLog), compactFlattenAll(beforeFilterLog, afterFilterLog));})); test("client-server filterLog", () => user.get({returnResponse: true, location: "client", session: {}}).then((response) => {let beforeFilterLog, afterFilterLog; assert.eq(simplifyFilterLog(response.beforeFilterLog), beforeFilterLog = ["client-pending-created", "client-pending-beforeFilter-myClientFilter", "client-pending-continueAtServerLocation", "server-pending-created", "server-pending-beforeFilter-myServerFilter", "server-success-handler-user"]); assert.eq(simplifyFilterLog(response.afterFilterLog), afterFilterLog = ["server-success-afterFilter-myServerFilter", "server-success-completed", "client-success-resumedAtClientLocation", "client-success-afterFilter-myClientFilter", "client-success-completed"]); return assert.eq(simplifyFilterLog(response.filterLog), compactFlattenAll(beforeFilterLog, afterFilterLog));})); test("fail in client-before", () => assert.rejects(user.get({returnResponse: true, location: "client", session: {}, data: {fail: "beforeClientFilter"}})).then(({props: {response}}) => assert.eq(simplifyFilterLog(response.beforeFilterLog), ["client-pending-created", "client-clientFailure-beforeFilter-myClientFilter"]))); test("fail in server-before", () => assert.rejects(user.get({returnResponse: true, location: "client", session: {}, data: {fail: "beforeServerFilter"}})).then(({props: {response}}) => assert.eq(simplifyFilterLog(response.beforeFilterLog), ["server-pending-created", "server-serverFailure-beforeFilter-myServerFilter"]))); test("fail in server-after", () => assert.rejects(user.get({returnResponse: true, location: "server", session: {}, data: {fail: "afterServerFilter"}})).then(({props: {response}}) => assert.eq(simplifyFilterLog(response.filterLog), ["server-pending-created", "server-pending-beforeFilter-myServerFilter", "server-success-handler-user", "server-serverFailure-afterFilter-myServerFilter", "server-serverFailure-completed"]))); return test("fail in client-after", () => assert.rejects(user.get({returnResponse: true, location: "client", session: {}, data: {fail: "afterClientFilter"}})).then(({props: {response}}) => assert.eq(simplifyFilterLog(response.filterLog), ["client-pending-created", "client-pending-beforeFilter-myClientFilter", "client-pending-continueAtServerLocation", "server-pending-created", "server-pending-beforeFilter-myServerFilter", "server-success-handler-user", "server-success-afterFilter-myServerFilter", "server-success-completed", "client-success-resumedAtClientLocation", "client-clientFailure-afterFilter-myClientFilter", "client-clientFailure-completed"])));}});});});
//# sourceMappingURL=RequestInspectors.test.js.map