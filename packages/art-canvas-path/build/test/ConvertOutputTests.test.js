"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {let parentImports; return Caf.importInvoke(["Extractor"], parentImports = [global, require('./StandardImport')], (Extractor) => {return Caf.importInvoke(["test", "svgToCanvasPath"], [parentImports, Extractor], (test, svgToCanvasPath) => {return test("nonzero fill - flourishBracket", function() {return svgToCanvasPath(require('./Data').flourishBracket);});});});});
//# sourceMappingURL=ConvertOutputTests.test.js.map
