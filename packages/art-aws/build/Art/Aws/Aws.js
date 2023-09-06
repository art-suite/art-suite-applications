"use strict"
let Caf = require('caffeine-script-runtime');
Caf.defMod(module, () => {return Caf.importInvoke(["isNode", "Error"], [global, require('art-standard-lib')], (isNode, Error) => {let nodeOnlyRequire; if (isNode) {nodeOnlyRequire = eval("require"); global.AWS = nodeOnlyRequire("aws-sdk");} else {require('../../../Client');}; if (!global.AWS) {throw new Error("Art.Aws: global.AWS required\n\nPlease use one of the following:\n\n  > require 'art-aws/Client'\n  > require 'art-aws/Server'");}; return [{config: require("./Config").config}, require("./DynamoDb")];});});
//# sourceMappingURL=Aws.js.map
