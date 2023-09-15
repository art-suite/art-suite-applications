"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let MockPusherServer; return MockPusherServer = Caf.defClass(class MockPusherServer extends Object {constructor(config) {super(...arguments);};}, function(MockPusherServer, classSuper, instanceSuper) {this.prototype.trigger = function(channelName, eventName, payload) {return require('./MockPusherService').trigger(channelName, eventName, payload);};});})();});
//# sourceMappingURL=MockPusherServer.js.map
