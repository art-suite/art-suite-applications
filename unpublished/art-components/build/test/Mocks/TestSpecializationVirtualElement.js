"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["VirtualElement"], [global, require('../StandardImport')], (VirtualElement) => {let TestSpecializationVirtualElement; return TestSpecializationVirtualElement = Caf.defClass(class TestSpecializationVirtualElement extends VirtualElement {}, function(TestSpecializationVirtualElement, classSuper, instanceSuper) {this.prototype._newElement = function(elementType, props, children) {return new (require('./TestSpecializationElement'))(elementType, props, children, this);};});});});
//# sourceMappingURL=TestSpecializationVirtualElement.js.map
