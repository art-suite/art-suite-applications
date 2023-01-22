"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Promise"], [global, require('./StandardImport')], (Promise) => {let jsonwebtoken, PromiseJsonWebToken; jsonwebtoken = require('jsonwebtoken'); return PromiseJsonWebToken = Caf.defClass(class PromiseJsonWebToken extends Object {}, function(PromiseJsonWebToken, classSuper, instanceSuper) {this.sign = function(payload, secretOrPrivateKey, options) {return Promise.withCallback((callback) => jsonwebtoken.sign(payload, secretOrPrivateKey, options, callback));}; this.verify = function(token, secretOrPrivateKey, options) {return Promise.withCallback((callback) => jsonwebtoken.verify(token, secretOrPrivateKey, options, callback));};});});});
//# sourceMappingURL=PromiseJsonWebToken.js.map
