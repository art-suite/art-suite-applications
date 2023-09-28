"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["Error", "formattedInspect", "isBrowser"], [global, require('art-standard-lib')], (Error, formattedInspect, isBrowser) => {let validLocations, validLocationsRegexp; return {validLocations: validLocations = ["client", "server", "both"], validLocationsRegexp: validLocationsRegexp = /^client|server|both$/, validateLocation: function(location) {if (!validLocationsRegexp.test(location)) {throw new Error(`Invalid location: ${Caf.toString(formattedInspect(location))}. Valid locations: ${Caf.toString(validLocations.join(", "))}`);}; return location;}, getDefaultLocation: function() {return isBrowser ? "client" : "server";}};});});
//# sourceMappingURL=Location.js.map
