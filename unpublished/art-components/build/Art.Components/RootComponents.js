"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Error", "arrayWithout"], [global, require('./StandardImport')], (Error, arrayWithout) => {let RootComponents; return RootComponents = Caf.defClass(class RootComponents extends Object {}, function(RootComponents, classSuper, instanceSuper) {this.rootComponents = []; this.mountRootComponent = (component) => {this.rootComponents.push(component); return component._instantiate();}; this.unmountRootComponent = (component) => {if (!(Caf.in(component, this.rootComponents))) {throw new Error("not a root component!");}; this.rootComponents = arrayWithout(this.rootComponents, component); return component._unmount();}; this.rerenderAllComponents = () => {let from, into, to, i, temp; return (from = this.rootComponents, into = from, (from != null) ? (to = from.length, i = 0, (() => {while (i < to) {let component; component = from[i]; component.rerenderAllComponents(); temp = i++;}; return temp;})()) : undefined, into);};});});});
//# sourceMappingURL=RootComponents.js.map
