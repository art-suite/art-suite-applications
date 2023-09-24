"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["test", "assert", "cleanStackTrace", "process"], [global, require('../StandardImport'), require('../../../build').Lib.Stack], (test, assert, cleanStackTrace, process) => {return test("cleanStackTrace", function() {return assert.eq(cleanStackTrace(`first-line\n  at ${Caf.toString(process.cwd())}/source/index.js:1:5\n  at Object.array (${Caf.toString(process.cwd())}/source/index.js:1:5)`), "  at source/index.js:1:5\n  at Object.array (source/index.js:1:5)\nNOTE: cleanStackTrace applied. Disable with: getEnv().ART_PIPELINES_CLEAN_STACK_TRACE=false");});});});
//# sourceMappingURL=Stack.test.js.map
