"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["RecyclableVirtualElement"], [global, require('../StandardImport')], (RecyclableVirtualElement) => {let TestSpecializationRecyclableVirtualElement; return TestSpecializationRecyclableVirtualElement = Caf.defClass(class TestSpecializationRecyclableVirtualElement extends RecyclableVirtualElement {}, function(TestSpecializationRecyclableVirtualElement, classSuper, instanceSuper) {this.prototype._newElement = function(elementType, props, children) {return new (require('./TestSpecializationElement'))(elementType, props, children, this);};});});});
//# sourceMappingURL=TestSpecializationRecyclableVirtualElement.js.map
