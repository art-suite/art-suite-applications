"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["BaseClass", "lowerCamelCase"], [global, require('./StandardImport')], (BaseClass, lowerCamelCase) => {let Counters; return Counters = Caf.defClass(class Counters extends BaseClass {}, function(Counters, classSuper, instanceSuper) {let counterNames, commonNames, methodNames, propNames; counterNames = {component: commonNames = ["created", "rendered", "updated", "instantiated", "released", "reused"], virtualElement: commonNames}; methodNames = []; propNames = []; Caf.each2(counterNames, (counters, category) => Caf.each2(counters, (counter) => {propNames.push(lowerCamelCase(`${Caf.toString(category)}s ${Caf.toString(counter)}`)); return methodNames.push(lowerCamelCase(`${Caf.toString(category)}  ${Caf.toString(counter)}`));})); this.classGetter({inspectedObjects: function() {return Caf.object(propNames, (name) => this[name], (name) => this[name] > 0);}}); Caf.object(propNames, (name, i) => eval(`(function() { this.${Caf.toString(name)}++; })`), null, this, (name, i) => methodNames[i]); this.reset = function() {return Caf.each2(propNames, (name) => this[name] = 0);}; this.reset();});});});
//# sourceMappingURL=Counters.js.map