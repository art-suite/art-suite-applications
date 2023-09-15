"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return (() => {let MockPusherClient; return MockPusherClient = Caf.defClass(class MockPusherClient extends Object {constructor(key, options) {super(...arguments); this.key = key; this.options = options; this.connection = {state: "connected", bind: (...args) => {}};};}, function(MockPusherClient, classSuper, instanceSuper) {this.prototype.subscribe = function(channelName) {return require('./MockPusherService').subscribe(channelName);}; this.prototype.unsubscribe = function(channelName) {return require('./MockPusherService').unsubscribe(channelName);};});})();});
//# sourceMappingURL=MockPusherClient.js.map
