"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {let Neptune = global.Neptune, startFrameTimer, endFrameTimer, temp, base; if (Caf.exists(temp = Caf.exists(base = Neptune.Art) && base.FrameStats)) {startFrameTimer = temp.startFrameTimer; endFrameTimer = temp.endFrameTimer;}; return [require('art-standard-lib'), require('art-class-system'), {startFrameTimer: startFrameTimer != null ? startFrameTimer : function() {return 0;}, endFrameTimer: endFrameTimer != null ? endFrameTimer : function() {return 0;}}];});
//# sourceMappingURL=StandardImport.js.map
