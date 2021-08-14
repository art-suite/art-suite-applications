"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["merge"], [global, require('../StandardImport')], (merge) => {return merge(require('./TestSpecializationVirtualElement').createVirtualElementFactories(["TestElement", "TestOtherElement", "TestTextElement"]), require('./TestSpecializationRecyclableVirtualElement').createVirtualElementFactories(["TestElementR", "TestOtherElementR", "TestTextElementR"]));});});
//# sourceMappingURL=Mocks.js.map
