"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["isNode", "Math", "Filter", "randomString", "base62Characters", "Uint8Array", "FieldTypes", "Error", "ceil"], [global, require('./StandardImport')], (isNode, Math, Filter, randomString, base62Characters, Uint8Array, FieldTypes, Error, ceil) => {let getRandomValues, crypto, cryptoRandomBase62Id, log2_62, UniqueIdFilter; getRandomValues = isNode ? (crypto = eval("require")("crypto"), function(typedArray) {typedArray.set(crypto.randomBytes(typedArray.length)); return typedArray;}) : function(typedArray) {return global.crypto.getRandomValues(typedArray);}; cryptoRandomBase62Id = function(numChars) {return randomString(numChars, base62Characters, getRandomValues(new Uint8Array(numChars)));}; log2_62 = Math.log(62) / Math.log(2); return UniqueIdFilter = Caf.defClass(class UniqueIdFilter extends Filter {constructor(options) {super(...arguments); this.bits = Caf.exists(options) && options.bits || 70; if (!(this.bits <= 256)) {throw new Error(`too many bits: ${Caf.toString(this.bits)}. max = 256`);}; this.numChars = ceil(this.bits / log2_62);};}, function(UniqueIdFilter, classSuper, instanceSuper) {this.group("outer"); this.getter({compactUniqueId: function() {return cryptoRandomBase62Id(this.numChars);}}); this.before({create: function(request) {return request.require(!(request.key != null), "request.key not expected for create").then(() => {let base; return request.requireServerOriginIf((Caf.exists(base = request.data) && base.id) != null);}).then(() => {let base; return (Caf.exists(base = request.data) && base.id) ? request : request.withMergedData({id: this.compactUniqueId});});}}); this.fields({id: FieldTypes.id});});});});
//# sourceMappingURL=UniqueIdFilter.js.map