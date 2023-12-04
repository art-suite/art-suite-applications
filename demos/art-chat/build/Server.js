/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./Configurations.caf":
/*!****************************!*\
  !*** ./Configurations.caf ***!
  \****************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  return __webpack_require__(/*! ./source/Art.Chat/Configurations */ "./source/Art.Chat/Configurations/index.js");
});


/***/ }),

/***/ "./Pipelines.caf":
/*!***********************!*\
  !*** ./Pipelines.caf ***!
  \***********************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  __webpack_require__(/*! ./source/Art.Chat/Pipelines */ "./source/Art.Chat/Pipelines/index.js");
  return (__webpack_require__(/*! art-ery */ "art-ery").pipelines);
});


/***/ }),

/***/ "./Server.caf":
/*!********************!*\
  !*** ./Server.caf ***!
  \********************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  __webpack_require__(/*! ./Configurations */ "./Configurations.caf");
  __webpack_require__(/*! ./Pipelines */ "./Pipelines.caf");
  __webpack_require__(/*! art-ery-pusher/Server */ "art-ery-pusher/Server");
  return (__webpack_require__(/*! art-suite-app/Server */ "art-suite-app/Server").start)({
    static: { root: "./public" },
  });
});


/***/ }),

/***/ "./source/Art.Chat/Configurations/Development.caf":
/*!********************************************************!*\
  !*** ./source/Art.Chat/Configurations/Development.caf ***!
  \********************************************************/
/***/ (() => {

throw new Error("Module build failed (from ../../node_modules/caffeine-mc/webpack-loader.js):\nErrorWithInfo: Validation error at /Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations/Development.caf:25:22\n\nSource:\n...\n      verifyConnection:   true\n\n    Ery: tableNamePrefix: :art-chat-dev.\n\n  @deepMergeInConfig <HERE>&artConfigsPrivate[@name]\n...\n\n\nModuleResolver: Could not find requested npm package: artConfigsPrivate\n\ninfo:\n  sourceFile:\n    :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations/Development.caf\n\n  failureIndex: 520\n  location:\n    :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations/Development.caf:25:22\n\n  column:                   21\n  line:                     24\n  npmPackageNamesAttempted: [] :artConfigsPrivate, :art-configs-private\n  sourceDir:\n    :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations\n\n  sourceRoot: :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat\n");

/***/ }),

/***/ "./source/Art.Chat/Configurations/Production.caf":
/*!*******************************************************!*\
  !*** ./source/Art.Chat/Configurations/Production.caf ***!
  \*******************************************************/
/***/ (() => {

throw new Error("Module build failed (from ../../node_modules/caffeine-mc/webpack-loader.js):\nErrorWithInfo: Validation error at /Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations/Production.caf:20:22\n\nSource:\n...\n      verifyConnection:   true\n\n    Ery: tableNamePrefix: :art-chat-prod.\n\n  @deepMergeInConfig <HERE>&artConfigsPrivate[@name]\n...\n\n\nModuleResolver: Could not find requested npm package: artConfigsPrivate\n\ninfo:\n  sourceFile:\n    :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations/Production.caf\n\n  failureIndex: 416\n  location:\n    :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations/Production.caf:20:22\n\n  column:                   21\n  line:                     19\n  npmPackageNamesAttempted: [] :artConfigsPrivate, :art-configs-private\n  sourceDir:\n    :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat/source/Art.Chat/Configurations\n\n  sourceRoot: :/Users/shanebdavis/dev/art-suite-applications/demos/art-chat\n");

/***/ }),

/***/ "./source/Art.Chat/Pipelines/Chat.caf":
/*!********************************************!*\
  !*** ./source/Art.Chat/Pipelines/Chat.caf ***!
  \********************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  return Caf.importInvoke(
    ["PusherPipelineMixin", "DynamoDbPipeline"],
    [
      global,
      __webpack_require__(/*! art-standard-lib */ "art-standard-lib"),
      __webpack_require__(/*! art-ery-pusher */ "art-ery-pusher"),
      __webpack_require__(/*! art-ery-aws */ "art-ery-aws"),
    ],
    (PusherPipelineMixin, DynamoDbPipeline) => {
      let Chat;
      return (Chat = Caf.defClass(
        class Chat extends PusherPipelineMixin(DynamoDbPipeline) {},
        function (Chat, classSuper, instanceSuper) {
          this.globalIndexes({ chatsByChatRoom: "chatRoom/createdAt" });
          this.addDatabaseFilters({
            fields: {
              user: ["required", "trimmedString"],
              message: ["required", "trimmedString"],
              chatRoom: ["required", "trimmedString"],
            },
          });
          this.publicRequestTypes("get", "create", "chatsByChatRoom");
        }
      ));
    }
  );
});


/***/ }),

/***/ "./source/Art.Chat/Client/Components/namespace.js":
/*!********************************************************!*\
  !*** ./source/Art.Chat/Client/Components/namespace.js ***!
  \********************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/Client/Components/namespace.js

module.exports = (__webpack_require__(/*! ../namespace */ "./source/Art.Chat/Client/namespace.js").addNamespace)(
  'Components',
  class Components extends Neptune.PackageNamespace {}
);


/***/ }),

/***/ "./source/Art.Chat/Client/namespace.js":
/*!*********************************************!*\
  !*** ./source/Art.Chat/Client/namespace.js ***!
  \*********************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/Client/namespace.js

module.exports = (__webpack_require__(/*! ../namespace */ "./source/Art.Chat/namespace.js").addNamespace)(
  'Client',
  class Client extends Neptune.PackageNamespace {}
);
__webpack_require__(/*! ./Components/namespace */ "./source/Art.Chat/Client/Components/namespace.js");

/***/ }),

/***/ "./source/Art.Chat/Configurations/index.js":
/*!*************************************************!*\
  !*** ./source/Art.Chat/Configurations/index.js ***!
  \*************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/Configurations/index.js

(module.exports = __webpack_require__(/*! ./namespace */ "./source/Art.Chat/Configurations/namespace.js"))

.addModules({
  Development: __webpack_require__(/*! ./Development */ "./source/Art.Chat/Configurations/Development.caf"),
  Production:  __webpack_require__(/*! ./Production */ "./source/Art.Chat/Configurations/Production.caf")
});

/***/ }),

/***/ "./source/Art.Chat/Configurations/namespace.js":
/*!*****************************************************!*\
  !*** ./source/Art.Chat/Configurations/namespace.js ***!
  \*****************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/Configurations/namespace.js

module.exports = (__webpack_require__(/*! ../namespace */ "./source/Art.Chat/namespace.js").addNamespace)(
  'Configurations',
  class Configurations extends Neptune.PackageNamespace {}
);


/***/ }),

/***/ "./source/Art.Chat/Pipelines/index.js":
/*!********************************************!*\
  !*** ./source/Art.Chat/Pipelines/index.js ***!
  \********************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/Pipelines/index.js

(module.exports = __webpack_require__(/*! ./namespace */ "./source/Art.Chat/Pipelines/namespace.js"))

.addModules({
  Chat: __webpack_require__(/*! ./Chat */ "./source/Art.Chat/Pipelines/Chat.caf")
});

/***/ }),

/***/ "./source/Art.Chat/Pipelines/namespace.js":
/*!************************************************!*\
  !*** ./source/Art.Chat/Pipelines/namespace.js ***!
  \************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/Pipelines/namespace.js

module.exports = (__webpack_require__(/*! ../namespace */ "./source/Art.Chat/namespace.js").addNamespace)(
  'Pipelines',
  class Pipelines extends Neptune.PackageNamespace {}
);


/***/ }),

/***/ "./source/Art.Chat/namespace.js":
/*!**************************************!*\
  !*** ./source/Art.Chat/namespace.js ***!
  \**************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/namespace.js

module.exports = (__webpack_require__(/*! neptune-namespaces-runtime */ "neptune-namespaces-runtime").addNamespace)(
  'Art.Chat',
  (class Chat extends Neptune.PackageNamespace {})
  ._configureNamespace(__webpack_require__(/*! ../../package.json */ "./package.json"))
);
__webpack_require__(/*! ./Client/namespace */ "./source/Art.Chat/Client/namespace.js");
__webpack_require__(/*! ./Configurations/namespace */ "./source/Art.Chat/Configurations/namespace.js");
__webpack_require__(/*! ./Pipelines/namespace */ "./source/Art.Chat/Pipelines/namespace.js");

/***/ }),

/***/ "art-ery":
/*!**************************************************************************!*\
  !*** external "require('art-ery' /* ABC - not inlining fellow NPM *_/)" ***!
  \**************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-ery' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "art-ery-aws":
/*!******************************************************************************!*\
  !*** external "require('art-ery-aws' /* ABC - not inlining fellow NPM *_/)" ***!
  \******************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-ery-aws' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "art-ery-pusher":
/*!*********************************************************************************!*\
  !*** external "require('art-ery-pusher' /* ABC - not inlining fellow NPM *_/)" ***!
  \*********************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-ery-pusher' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "art-ery-pusher/Server":
/*!****************************************************************************************!*\
  !*** external "require('art-ery-pusher/Server' /* ABC - not inlining fellow NPM *_/)" ***!
  \****************************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-ery-pusher/Server' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "art-standard-lib":
/*!***********************************************************************************!*\
  !*** external "require('art-standard-lib' /* ABC - not inlining fellow NPM *_/)" ***!
  \***********************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-standard-lib' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "art-suite-app/Server":
/*!***************************************************************************************!*\
  !*** external "require('art-suite-app/Server' /* ABC - not inlining fellow NPM *_/)" ***!
  \***************************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-suite-app/Server' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "caffeine-script-runtime":
/*!******************************************************************************************!*\
  !*** external "require('caffeine-script-runtime' /* ABC - not inlining fellow NPM *_/)" ***!
  \******************************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('caffeine-script-runtime' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "neptune-namespaces-runtime":
/*!*********************************************************************************************!*\
  !*** external "require('neptune-namespaces-runtime' /* ABC - not inlining fellow NPM *_/)" ***!
  \*********************************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('neptune-namespaces-runtime' /* ABC - not inlining fellow NPM */);

/***/ }),

/***/ "./package.json":
/*!**********************!*\
  !*** ./package.json ***!
  \**********************/
/***/ ((module) => {

"use strict";
module.exports = JSON.parse('{"author":"Shane Brinkman-Davis Delamore, Imikimi LLC\\"","bugs":"https://github.com/art-suite/art-suite-applications/issues","dependencies":{"art-ery-pusher":"^0.12.0","art-suite":"^2.0.7"},"description":"Art.Chat","devDependencies":{"art-build-configurator":"^1.29.3","crypto-browserify":"^3.12.0","local-cors-proxy":"^1.1.0","stream-browserify":"^3.0.0"},"engines":{"node":"8.x"},"homepage":"https://github.com/art-suite/art-suite-applications","license":"ISC","name":"art-chat","repository":{"type":"git","url":"https://github.com/art-suite/art-suite-applications.git"},"scripts":{"build":"nn -s; webpack --progress","dynamodb":"./start-dynamo-db-local-server.sh","init-dev":"nn -s\\n./tool initialize-pipelines\\nnpm run seed","lcp":"lcp --proxyUrl http://localhost:8081 --port 8011","start":"cafSourceMaps=true webpack serve --hot --progress --static .","test":"cafSourceMaps=true webpack serve --progress"}}');

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			id: moduleId,
/******/ 			loaded: false,
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/node module decorator */
/******/ 	(() => {
/******/ 		__webpack_require__.nmd = (module) => {
/******/ 			module.paths = [];
/******/ 			if (!module.children) module.children = [];
/******/ 			return module;
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module is referenced by other modules so it can't be inlined
/******/ 	var __webpack_exports__ = __webpack_require__("./Server.caf");
/******/ 	module.exports = __webpack_exports__;
/******/ 	
/******/ })()
;
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiU2VydmVyLmpzIiwibWFwcGluZ3MiOiI7Ozs7Ozs7Ozs7O0FBQWE7QUFDYixVQUFVLG1CQUFPLENBQUMsd0RBQXlCO0FBQzNDO0FBQ0EsU0FBUyxtQkFBTyxDQUFDLG1GQUFrQztBQUNuRCxDQUFDOzs7Ozs7Ozs7Ozs7O0FDSlk7QUFDYixVQUFVLG1CQUFPLENBQUMsd0RBQXlCO0FBQzNDO0FBQ0EsRUFBRSxtQkFBTyxDQUFDLHlFQUE2QjtBQUN2QyxTQUFTLHlEQUE0QjtBQUNyQyxDQUFDOzs7Ozs7Ozs7Ozs7O0FDTFk7QUFDYixVQUFVLG1CQUFPLENBQUMsd0RBQXlCO0FBQzNDO0FBQ0EsRUFBRSxtQkFBTyxDQUFDLDhDQUFrQjtBQUM1QixFQUFFLG1CQUFPLENBQUMsb0NBQWE7QUFDdkIsRUFBRSxtQkFBTyxDQUFDLG9EQUF1QjtBQUNqQyxTQUFTLCtFQUFxQztBQUM5QyxjQUFjLGtCQUFrQjtBQUNoQyxHQUFHO0FBQ0gsQ0FBQzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7O0FDVFk7QUFDYixVQUFVLG1CQUFPLENBQUMsd0RBQXlCO0FBQzNDO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxNQUFNLG1CQUFPLENBQUMsMENBQWtCO0FBQ2hDLE1BQU0sbUJBQU8sQ0FBQyxzQ0FBZ0I7QUFDOUIsTUFBTSxtQkFBTyxDQUFDLGdDQUFhO0FBQzNCO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsbUVBQW1FO0FBQ25FO0FBQ0EsK0JBQStCLHVDQUF1QztBQUN0RTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsYUFBYTtBQUNiLFdBQVc7QUFDWDtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsQ0FBQzs7Ozs7Ozs7Ozs7QUM3QkQ7QUFDQTs7QUFFQSxpQkFBaUIsK0ZBQW9DO0FBQ3JEO0FBQ0E7QUFDQTs7Ozs7Ozs7Ozs7QUNOQTtBQUNBOztBQUVBLGlCQUFpQix3RkFBb0M7QUFDckQ7QUFDQTtBQUNBO0FBQ0EsbUJBQU8sQ0FBQyxnRkFBd0I7Ozs7Ozs7Ozs7QUNQaEM7QUFDQTs7QUFFQSxDQUFDLHdHQUF1Qzs7QUFFeEM7QUFDQSxlQUFlLG1CQUFPLENBQUMsdUVBQWU7QUFDdEMsZUFBZSxtQkFBTyxDQUFDLHFFQUFjO0FBQ3JDLENBQUM7Ozs7Ozs7Ozs7QUNSRDtBQUNBOztBQUVBLGlCQUFpQix3RkFBb0M7QUFDckQ7QUFDQTtBQUNBOzs7Ozs7Ozs7OztBQ05BO0FBQ0E7O0FBRUEsQ0FBQyxtR0FBdUM7O0FBRXhDO0FBQ0EsUUFBUSxtQkFBTyxDQUFDLG9EQUFRO0FBQ3hCLENBQUM7Ozs7Ozs7Ozs7QUNQRDtBQUNBOztBQUVBLGlCQUFpQix3RkFBb0M7QUFDckQ7QUFDQTtBQUNBOzs7Ozs7Ozs7OztBQ05BO0FBQ0E7O0FBRUEsaUJBQWlCLGtHQUFrRDtBQUNuRTtBQUNBLGlEQUFpRDtBQUNqRCx1QkFBdUIsbUJBQU8sQ0FBQywwQ0FBb0I7QUFDbkQ7QUFDQSxtQkFBTyxDQUFDLGlFQUFvQjtBQUM1QixtQkFBTyxDQUFDLGlGQUE0QjtBQUNwQyxtQkFBTyxDQUFDLHVFQUF1Qjs7Ozs7Ozs7Ozs7QUNWL0I7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7O0FDQUE7Ozs7Ozs7Ozs7Ozs7Ozs7O1VDQUE7VUFDQTs7VUFFQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTs7VUFFQTtVQUNBOztVQUVBO1VBQ0E7O1VBRUE7VUFDQTtVQUNBOzs7OztXQ3pCQTtXQUNBO1dBQ0E7V0FDQTtXQUNBOzs7OztVRUpBO1VBQ0E7VUFDQTtVQUNBIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9Db25maWd1cmF0aW9ucy5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9QaXBlbGluZXMuY2FmIiwid2VicGFjazovL2FydC1jaGF0Ly4vU2VydmVyLmNhZiIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9QaXBlbGluZXMvQ2hhdC5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvQ2xpZW50L0NvbXBvbmVudHMvbmFtZXNwYWNlLmpzIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L0NsaWVudC9uYW1lc3BhY2UuanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvQ29uZmlndXJhdGlvbnMvaW5kZXguanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvQ29uZmlndXJhdGlvbnMvbmFtZXNwYWNlLmpzIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L1BpcGVsaW5lcy9pbmRleC5qcyIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9QaXBlbGluZXMvbmFtZXNwYWNlLmpzIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L25hbWVzcGFjZS5qcyIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnYXJ0LWVyeScgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2FydC1lcnktYXdzJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnYXJ0LWVyeS1wdXNoZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtZXJ5LXB1c2hlci9TZXJ2ZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtc3RhbmRhcmQtbGliJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnYXJ0LXN1aXRlLWFwcC9TZXJ2ZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdjYWZmZWluZS1zY3JpcHQtcnVudGltZScgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ25lcHR1bmUtbmFtZXNwYWNlcy1ydW50aW1lJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC93ZWJwYWNrL2Jvb3RzdHJhcCIsIndlYnBhY2s6Ly9hcnQtY2hhdC93ZWJwYWNrL3J1bnRpbWUvbm9kZSBtb2R1bGUgZGVjb3JhdG9yIiwid2VicGFjazovL2FydC1jaGF0L3dlYnBhY2svYmVmb3JlLXN0YXJ0dXAiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvd2VicGFjay9zdGFydHVwIiwid2VicGFjazovL2FydC1jaGF0L3dlYnBhY2svYWZ0ZXItc3RhcnR1cCJdLCJzb3VyY2VzQ29udGVudCI6WyJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4gcmVxdWlyZShcIi4vc291cmNlL0FydC5DaGF0L0NvbmZpZ3VyYXRpb25zXCIpO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXF1aXJlKFwiLi9zb3VyY2UvQXJ0LkNoYXQvUGlwZWxpbmVzXCIpO1xuICByZXR1cm4gcmVxdWlyZShcImFydC1lcnlcIikucGlwZWxpbmVzO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXF1aXJlKFwiLi9Db25maWd1cmF0aW9uc1wiKTtcbiAgcmVxdWlyZShcIi4vUGlwZWxpbmVzXCIpO1xuICByZXF1aXJlKFwiYXJ0LWVyeS1wdXNoZXIvU2VydmVyXCIpO1xuICByZXR1cm4gcmVxdWlyZShcImFydC1zdWl0ZS1hcHAvU2VydmVyXCIpLnN0YXJ0KHtcbiAgICBzdGF0aWM6IHsgcm9vdDogXCIuL3B1YmxpY1wiIH0sXG4gIH0pO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4gQ2FmLmltcG9ydEludm9rZShcbiAgICBbXCJQdXNoZXJQaXBlbGluZU1peGluXCIsIFwiRHluYW1vRGJQaXBlbGluZVwiXSxcbiAgICBbXG4gICAgICBnbG9iYWwsXG4gICAgICByZXF1aXJlKFwiYXJ0LXN0YW5kYXJkLWxpYlwiKSxcbiAgICAgIHJlcXVpcmUoXCJhcnQtZXJ5LXB1c2hlclwiKSxcbiAgICAgIHJlcXVpcmUoXCJhcnQtZXJ5LWF3c1wiKSxcbiAgICBdLFxuICAgIChQdXNoZXJQaXBlbGluZU1peGluLCBEeW5hbW9EYlBpcGVsaW5lKSA9PiB7XG4gICAgICBsZXQgQ2hhdDtcbiAgICAgIHJldHVybiAoQ2hhdCA9IENhZi5kZWZDbGFzcyhcbiAgICAgICAgY2xhc3MgQ2hhdCBleHRlbmRzIFB1c2hlclBpcGVsaW5lTWl4aW4oRHluYW1vRGJQaXBlbGluZSkge30sXG4gICAgICAgIGZ1bmN0aW9uIChDaGF0LCBjbGFzc1N1cGVyLCBpbnN0YW5jZVN1cGVyKSB7XG4gICAgICAgICAgdGhpcy5nbG9iYWxJbmRleGVzKHsgY2hhdHNCeUNoYXRSb29tOiBcImNoYXRSb29tL2NyZWF0ZWRBdFwiIH0pO1xuICAgICAgICAgIHRoaXMuYWRkRGF0YWJhc2VGaWx0ZXJzKHtcbiAgICAgICAgICAgIGZpZWxkczoge1xuICAgICAgICAgICAgICB1c2VyOiBbXCJyZXF1aXJlZFwiLCBcInRyaW1tZWRTdHJpbmdcIl0sXG4gICAgICAgICAgICAgIG1lc3NhZ2U6IFtcInJlcXVpcmVkXCIsIFwidHJpbW1lZFN0cmluZ1wiXSxcbiAgICAgICAgICAgICAgY2hhdFJvb206IFtcInJlcXVpcmVkXCIsIFwidHJpbW1lZFN0cmluZ1wiXSxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgfSk7XG4gICAgICAgICAgdGhpcy5wdWJsaWNSZXF1ZXN0VHlwZXMoXCJnZXRcIiwgXCJjcmVhdGVcIiwgXCJjaGF0c0J5Q2hhdFJvb21cIik7XG4gICAgICAgIH1cbiAgICAgICkpO1xuICAgIH1cbiAgKTtcbn0pO1xuIiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L0NsaWVudC9Db21wb25lbnRzL25hbWVzcGFjZS5qc1xuXG5tb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4uL25hbWVzcGFjZScpLmFkZE5hbWVzcGFjZShcbiAgJ0NvbXBvbmVudHMnLFxuICBjbGFzcyBDb21wb25lbnRzIGV4dGVuZHMgTmVwdHVuZS5QYWNrYWdlTmFtZXNwYWNlIHt9XG4pO1xuIiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L0NsaWVudC9uYW1lc3BhY2UuanNcblxubW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCcuLi9uYW1lc3BhY2UnKS5hZGROYW1lc3BhY2UoXG4gICdDbGllbnQnLFxuICBjbGFzcyBDbGllbnQgZXh0ZW5kcyBOZXB0dW5lLlBhY2thZ2VOYW1lc3BhY2Uge31cbik7XG5yZXF1aXJlKCcuL0NvbXBvbmVudHMvbmFtZXNwYWNlJyk7IiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L0NvbmZpZ3VyYXRpb25zL2luZGV4LmpzXG5cbihtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4vbmFtZXNwYWNlJykpXG5cbi5hZGRNb2R1bGVzKHtcbiAgRGV2ZWxvcG1lbnQ6IHJlcXVpcmUoJy4vRGV2ZWxvcG1lbnQnKSxcbiAgUHJvZHVjdGlvbjogIHJlcXVpcmUoJy4vUHJvZHVjdGlvbicpXG59KTsiLCIvLyBnZW5lcmF0ZWQgYnkgTmVwdHVuZSBOYW1lc3BhY2VzIHY0LngueFxuLy8gZmlsZTogQXJ0LkNoYXQvQ29uZmlndXJhdGlvbnMvbmFtZXNwYWNlLmpzXG5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi4vbmFtZXNwYWNlJykuYWRkTmFtZXNwYWNlKFxuICAnQ29uZmlndXJhdGlvbnMnLFxuICBjbGFzcyBDb25maWd1cmF0aW9ucyBleHRlbmRzIE5lcHR1bmUuUGFja2FnZU5hbWVzcGFjZSB7fVxuKTtcbiIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9QaXBlbGluZXMvaW5kZXguanNcblxuKG1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi9uYW1lc3BhY2UnKSlcblxuLmFkZE1vZHVsZXMoe1xuICBDaGF0OiByZXF1aXJlKCcuL0NoYXQnKVxufSk7IiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L1BpcGVsaW5lcy9uYW1lc3BhY2UuanNcblxubW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCcuLi9uYW1lc3BhY2UnKS5hZGROYW1lc3BhY2UoXG4gICdQaXBlbGluZXMnLFxuICBjbGFzcyBQaXBlbGluZXMgZXh0ZW5kcyBOZXB0dW5lLlBhY2thZ2VOYW1lc3BhY2Uge31cbik7XG4iLCIvLyBnZW5lcmF0ZWQgYnkgTmVwdHVuZSBOYW1lc3BhY2VzIHY0LngueFxuLy8gZmlsZTogQXJ0LkNoYXQvbmFtZXNwYWNlLmpzXG5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnbmVwdHVuZS1uYW1lc3BhY2VzLXJ1bnRpbWUnKS5hZGROYW1lc3BhY2UoXG4gICdBcnQuQ2hhdCcsXG4gIChjbGFzcyBDaGF0IGV4dGVuZHMgTmVwdHVuZS5QYWNrYWdlTmFtZXNwYWNlIHt9KVxuICAuX2NvbmZpZ3VyZU5hbWVzcGFjZShyZXF1aXJlKCcuLi8uLi9wYWNrYWdlLmpzb24nKSlcbik7XG5yZXF1aXJlKCcuL0NsaWVudC9uYW1lc3BhY2UnKTtcbnJlcXVpcmUoJy4vQ29uZmlndXJhdGlvbnMvbmFtZXNwYWNlJyk7XG5yZXF1aXJlKCcuL1BpcGVsaW5lcy9uYW1lc3BhY2UnKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2FydC1lcnknIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2FydC1lcnktYXdzJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtZXJ5LXB1c2hlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnYXJ0LWVyeS1wdXNoZXIvU2VydmVyJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtc3RhbmRhcmQtbGliJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtc3VpdGUtYXBwL1NlcnZlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWUnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ25lcHR1bmUtbmFtZXNwYWNlcy1ydW50aW1lJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwiLy8gVGhlIG1vZHVsZSBjYWNoZVxudmFyIF9fd2VicGFja19tb2R1bGVfY2FjaGVfXyA9IHt9O1xuXG4vLyBUaGUgcmVxdWlyZSBmdW5jdGlvblxuZnVuY3Rpb24gX193ZWJwYWNrX3JlcXVpcmVfXyhtb2R1bGVJZCkge1xuXHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcblx0dmFyIGNhY2hlZE1vZHVsZSA9IF9fd2VicGFja19tb2R1bGVfY2FjaGVfX1ttb2R1bGVJZF07XG5cdGlmIChjYWNoZWRNb2R1bGUgIT09IHVuZGVmaW5lZCkge1xuXHRcdHJldHVybiBjYWNoZWRNb2R1bGUuZXhwb3J0cztcblx0fVxuXHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuXHR2YXIgbW9kdWxlID0gX193ZWJwYWNrX21vZHVsZV9jYWNoZV9fW21vZHVsZUlkXSA9IHtcblx0XHRpZDogbW9kdWxlSWQsXG5cdFx0bG9hZGVkOiBmYWxzZSxcblx0XHRleHBvcnRzOiB7fVxuXHR9O1xuXG5cdC8vIEV4ZWN1dGUgdGhlIG1vZHVsZSBmdW5jdGlvblxuXHRfX3dlYnBhY2tfbW9kdWxlc19fW21vZHVsZUlkXShtb2R1bGUsIG1vZHVsZS5leHBvcnRzLCBfX3dlYnBhY2tfcmVxdWlyZV9fKTtcblxuXHQvLyBGbGFnIHRoZSBtb2R1bGUgYXMgbG9hZGVkXG5cdG1vZHVsZS5sb2FkZWQgPSB0cnVlO1xuXG5cdC8vIFJldHVybiB0aGUgZXhwb3J0cyBvZiB0aGUgbW9kdWxlXG5cdHJldHVybiBtb2R1bGUuZXhwb3J0cztcbn1cblxuIiwiX193ZWJwYWNrX3JlcXVpcmVfXy5ubWQgPSAobW9kdWxlKSA9PiB7XG5cdG1vZHVsZS5wYXRocyA9IFtdO1xuXHRpZiAoIW1vZHVsZS5jaGlsZHJlbikgbW9kdWxlLmNoaWxkcmVuID0gW107XG5cdHJldHVybiBtb2R1bGU7XG59OyIsIiIsIi8vIHN0YXJ0dXBcbi8vIExvYWQgZW50cnkgbW9kdWxlIGFuZCByZXR1cm4gZXhwb3J0c1xuLy8gVGhpcyBlbnRyeSBtb2R1bGUgaXMgcmVmZXJlbmNlZCBieSBvdGhlciBtb2R1bGVzIHNvIGl0IGNhbid0IGJlIGlubGluZWRcbnZhciBfX3dlYnBhY2tfZXhwb3J0c19fID0gX193ZWJwYWNrX3JlcXVpcmVfXyhcIi4vU2VydmVyLmNhZlwiKTtcbiIsIiJdLCJuYW1lcyI6W10sInNvdXJjZVJvb3QiOiIifQ==