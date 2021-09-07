"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Uint16Array", "Uint8Array"], [global, require('art-standard-lib')], (Uint16Array, Uint8Array) => {let out, commandMap; out = {commandMap: commandMap = {noop: 0, beginPath: 1, closePath: 2, moveTo: 3, lineTo: 4, quadraticCurveTo: 5, bezierCurveTo: 6, arc: 7, antiArc: 8}, commandIdsToNames: Caf.each2(commandMap, (id, name) => out[id] = name, null, out = []), maxFixedPointValue: 65535, valueArrayType: Uint16Array, commandArrayType: Uint8Array}; Caf.object(commandMap, (id, name) => id, null, out, (id, name) => name + "Command"); return out;});});
//# sourceMappingURL=EncodingLib.js.map
