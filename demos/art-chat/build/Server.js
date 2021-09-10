/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./.artConfigs.private.caf":
/*!*********************************!*\
  !*** ./.artConfigs.private.caf ***!
  \*********************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  let pusherCreds;
  return {
    Production: {
      Art: {
        EryExtensions: {
          Pusher: (pusherCreds = { secret: "a4fe9579ecb75ab95d54" }),
        },
      },
    },
    Development: { Art: { EryExtensions: { Pusher: pusherCreds } } },
  };
});


/***/ }),

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
  return __webpack_require__(/*! art-ery */ "art-ery").pipelines;
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
  return __webpack_require__(/*! art-suite-app/Server */ "art-suite-app/Server").start({
    static: { root: "./public" },
  });
});


/***/ }),

/***/ "./source/Art.Chat/Configurations/Development.caf":
/*!********************************************************!*\
  !*** ./source/Art.Chat/Configurations/Development.caf ***!
  \********************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  return (() => {
    let Development;
    return (Development = Caf.defClass(
      class Development extends __webpack_require__(/*! art-config */ "art-config").Config {},
      function (Development, classSuper, instanceSuper) {
        this.prototype.Art = {
          Aws: {
            credentials: { accessKeyId: "blah", secretAccessKey: "blahblah" },
            region: "us-west-2",
            dynamoDb: { endpoint: "http://localhost:8011/proxy" },
          },
          EryExtensions: {
            Pusher: {
              appId: "297694",
              key: "24b226a55a36ba7d4e24",
              cluster: "mt1",
              verbose: true,
              verifyConnection: true,
            },
          },
          Ery: { tableNamePrefix: "art-chat-dev." },
        };
        this.deepMergeInConfig(
          __webpack_require__(/*! ../../../.artConfigs.private */ "./.artConfigs.private.caf")[this.name]
        );
      }
    ));
  })();
});


/***/ }),

/***/ "./source/Art.Chat/Configurations/Production.caf":
/*!*******************************************************!*\
  !*** ./source/Art.Chat/Configurations/Production.caf ***!
  \*******************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  return (() => {
    let Production;
    return (Production = Caf.defClass(
      class Production extends __webpack_require__(/*! art-config */ "art-config").Config {},
      function (Production, classSuper, instanceSuper) {
        this.prototype.Art = {
          Aws: {
            credentials: { accessKeyId: "blah", secretAccessKey: "blahblah" },
            region: "us-east-1",
          },
          EryExtensions: {
            Pusher: {
              appId: "297694",
              key: "24b226a55a36ba7d4e24",
              cluster: "mt1",
              verifyConnection: true,
            },
          },
          Ery: { tableNamePrefix: "art-chat-prod." },
        };
        this.deepMergeInConfig(
          __webpack_require__(/*! ../../../.artConfigs.private */ "./.artConfigs.private.caf")[this.name]
        );
      }
    ));
  })();
});


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
    ["PusherPipelineMixin"],
    [global, __webpack_require__(/*! art-standard-lib */ "art-standard-lib"), __webpack_require__(/*! art-ery-pusher */ "art-ery-pusher")],
    (PusherPipelineMixin) => {
      let Chat;
      return (Chat = Caf.defClass(
        class Chat extends PusherPipelineMixin(
          __webpack_require__(/*! art-ery-aws */ "art-ery-aws").DynamoDbPipeline
        ) {},
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

module.exports = __webpack_require__(/*! ../namespace */ "./source/Art.Chat/Client/namespace.js").addNamespace(
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

module.exports = __webpack_require__(/*! ../namespace */ "./source/Art.Chat/namespace.js").addNamespace(
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

module.exports = __webpack_require__(/*! ../namespace */ "./source/Art.Chat/namespace.js").addNamespace(
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

module.exports = __webpack_require__(/*! ../namespace */ "./source/Art.Chat/namespace.js").addNamespace(
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

module.exports = __webpack_require__(/*! neptune-namespaces-runtime */ "neptune-namespaces-runtime").addNamespace(
  'Art.Chat',
  (class Chat extends Neptune.PackageNamespace {})
  ._configureNamespace(__webpack_require__(/*! ../../package.json */ "./package.json"))
);
__webpack_require__(/*! ./Client/namespace */ "./source/Art.Chat/Client/namespace.js");
__webpack_require__(/*! ./Configurations/namespace */ "./source/Art.Chat/Configurations/namespace.js");
__webpack_require__(/*! ./Pipelines/namespace */ "./source/Art.Chat/Pipelines/namespace.js");

/***/ }),

/***/ "art-config":
/*!*****************************************************************************!*\
  !*** external "require('art-config' /* ABC - not inlining fellow NPM *_/)" ***!
  \*****************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-config' /* ABC - not inlining fellow NPM */);

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
module.exports = JSON.parse('{"author":"Shane Brinkman-Davis Delamore, Imikimi LLC\\"","bugs":"https://github.com/art-suite/art-suite-applications/issues","dependencies":{"art-build-configurator":"^1.29.3","aws-sdk":"^2.809.0","aws4":"^1.6.0","bluebird":"^3.5.0","colors":"^1.1.2","compress":"^0.99.0","compression":"^1.7.2","crypto-browserify":"^3.12.0","detect-node":"^2.0.3","express":"^4.17.1","fs-extra":"^3.0.1","jsonwebtoken":"^8.5.1","pusher":"^1.5.1","querystring":"*","stream-browserify":"^3.0.0","throng":"^5.0.0","uuid":"^8.3.2","xhr2":"^0.1.4"},"description":"Art.Chat","devDependencies":{"lcp":"*"},"engines":{"node":"8.x"},"homepage":"https://github.com/art-suite/art-suite-applications","license":"ISC","name":"art-chat","repository":{"type":"git","url":"https://github.com/art-suite/art-suite-applications.git"},"scripts":{"build":"nn -s; webpack --progress","dynamodb":"./start-dynamo-db-local-server.sh","init-dev":"nn -s\\n./tool initialize-pipelines\\nnpm run seed","lcp":"lcp --proxyUrl http://localhost:8081 --port 8011","start":"webpack serve --hot --progress --static .","test":"webpack serve --progress"}}');

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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,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QUMsbUdBQXVDOztBQUV4QztBQUNBLFFBQVEsbUJBQU8sQ0FBQyxvREFBUTtBQUN4QixDQUFDOzs7Ozs7Ozs7O0FDUEQ7QUFDQTs7QUFFQSxpQkFBaUIsc0ZBQW9DO0FBQ3JEO0FBQ0E7QUFDQTs7Ozs7Ozs7Ozs7QUNOQTtBQUNBOztBQUVBLGlCQUFpQixnR0FBa0Q7QUFDbkU7QUFDQSxpREFBaUQ7QUFDakQsdUJBQXVCLG1CQUFPLENBQUMsMENBQW9CO0FBQ25EO0FBQ0EsbUJBQU8sQ0FBQyxpRUFBb0I7QUFDNUIsbUJBQU8sQ0FBQyxpRkFBNEI7QUFDcEMsbUJBQU8sQ0FBQyx1RUFBdUI7Ozs7Ozs7Ozs7O0FDVi9COzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7Ozs7Ozs7OztVQ0FBO1VBQ0E7O1VBRUE7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7O1VBRUE7VUFDQTs7VUFFQTtVQUNBOztVQUVBO1VBQ0E7VUFDQTs7Ozs7V0N6QkE7V0FDQTtXQUNBO1dBQ0E7V0FDQTs7Ozs7VUVKQTtVQUNBO1VBQ0E7VUFDQSIsInNvdXJjZXMiOlsid2VicGFjazovL2FydC1jaGF0Ly4vLmFydENvbmZpZ3MucHJpdmF0ZS5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9Db25maWd1cmF0aW9ucy5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9QaXBlbGluZXMuY2FmIiwid2VicGFjazovL2FydC1jaGF0Ly4vU2VydmVyLmNhZiIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9Db25maWd1cmF0aW9ucy9EZXZlbG9wbWVudC5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvQ29uZmlndXJhdGlvbnMvUHJvZHVjdGlvbi5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvUGlwZWxpbmVzL0NoYXQuY2FmIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L0NsaWVudC9Db21wb25lbnRzL25hbWVzcGFjZS5qcyIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9DbGllbnQvbmFtZXNwYWNlLmpzIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L0NvbmZpZ3VyYXRpb25zL2luZGV4LmpzIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L0NvbmZpZ3VyYXRpb25zL25hbWVzcGFjZS5qcyIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9QaXBlbGluZXMvaW5kZXguanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvUGlwZWxpbmVzL25hbWVzcGFjZS5qcyIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9uYW1lc3BhY2UuanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2FydC1jb25maWcnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtZXJ5JyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnYXJ0LWVyeS1hd3MnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtZXJ5LXB1c2hlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2FydC1lcnktcHVzaGVyL1NlcnZlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2FydC1zdGFuZGFyZC1saWInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtc3VpdGUtYXBwL1NlcnZlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2NhZmZlaW5lLXNjcmlwdC1ydW50aW1lJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnbmVwdHVuZS1uYW1lc3BhY2VzLXJ1bnRpbWUnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L3dlYnBhY2svYm9vdHN0cmFwIiwid2VicGFjazovL2FydC1jaGF0L3dlYnBhY2svcnVudGltZS9ub2RlIG1vZHVsZSBkZWNvcmF0b3IiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvd2VicGFjay9iZWZvcmUtc3RhcnR1cCIsIndlYnBhY2s6Ly9hcnQtY2hhdC93ZWJwYWNrL3N0YXJ0dXAiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvd2VicGFjay9hZnRlci1zdGFydHVwIl0sInNvdXJjZXNDb250ZW50IjpbIlwidXNlIHN0cmljdFwiO1xubGV0IENhZiA9IHJlcXVpcmUoXCJjYWZmZWluZS1zY3JpcHQtcnVudGltZVwiKTtcbkNhZi5kZWZNb2QobW9kdWxlLCAoKSA9PiB7XG4gIGxldCBwdXNoZXJDcmVkcztcbiAgcmV0dXJuIHtcbiAgICBQcm9kdWN0aW9uOiB7XG4gICAgICBBcnQ6IHtcbiAgICAgICAgRXJ5RXh0ZW5zaW9uczoge1xuICAgICAgICAgIFB1c2hlcjogKHB1c2hlckNyZWRzID0geyBzZWNyZXQ6IFwiYTRmZTk1NzllY2I3NWFiOTVkNTRcIiB9KSxcbiAgICAgICAgfSxcbiAgICAgIH0sXG4gICAgfSxcbiAgICBEZXZlbG9wbWVudDogeyBBcnQ6IHsgRXJ5RXh0ZW5zaW9uczogeyBQdXNoZXI6IHB1c2hlckNyZWRzIH0gfSB9LFxuICB9O1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4gcmVxdWlyZShcIi4vc291cmNlL0FydC5DaGF0L0NvbmZpZ3VyYXRpb25zXCIpO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXF1aXJlKFwiLi9zb3VyY2UvQXJ0LkNoYXQvUGlwZWxpbmVzXCIpO1xuICByZXR1cm4gcmVxdWlyZShcImFydC1lcnlcIikucGlwZWxpbmVzO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXF1aXJlKFwiLi9Db25maWd1cmF0aW9uc1wiKTtcbiAgcmVxdWlyZShcIi4vUGlwZWxpbmVzXCIpO1xuICByZXF1aXJlKFwiYXJ0LWVyeS1wdXNoZXIvU2VydmVyXCIpO1xuICByZXR1cm4gcmVxdWlyZShcImFydC1zdWl0ZS1hcHAvU2VydmVyXCIpLnN0YXJ0KHtcbiAgICBzdGF0aWM6IHsgcm9vdDogXCIuL3B1YmxpY1wiIH0sXG4gIH0pO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4gKCgpID0+IHtcbiAgICBsZXQgRGV2ZWxvcG1lbnQ7XG4gICAgcmV0dXJuIChEZXZlbG9wbWVudCA9IENhZi5kZWZDbGFzcyhcbiAgICAgIGNsYXNzIERldmVsb3BtZW50IGV4dGVuZHMgcmVxdWlyZShcImFydC1jb25maWdcIikuQ29uZmlnIHt9LFxuICAgICAgZnVuY3Rpb24gKERldmVsb3BtZW50LCBjbGFzc1N1cGVyLCBpbnN0YW5jZVN1cGVyKSB7XG4gICAgICAgIHRoaXMucHJvdG90eXBlLkFydCA9IHtcbiAgICAgICAgICBBd3M6IHtcbiAgICAgICAgICAgIGNyZWRlbnRpYWxzOiB7IGFjY2Vzc0tleUlkOiBcImJsYWhcIiwgc2VjcmV0QWNjZXNzS2V5OiBcImJsYWhibGFoXCIgfSxcbiAgICAgICAgICAgIHJlZ2lvbjogXCJ1cy13ZXN0LTJcIixcbiAgICAgICAgICAgIGR5bmFtb0RiOiB7IGVuZHBvaW50OiBcImh0dHA6Ly9sb2NhbGhvc3Q6ODAxMS9wcm94eVwiIH0sXG4gICAgICAgICAgfSxcbiAgICAgICAgICBFcnlFeHRlbnNpb25zOiB7XG4gICAgICAgICAgICBQdXNoZXI6IHtcbiAgICAgICAgICAgICAgYXBwSWQ6IFwiMjk3Njk0XCIsXG4gICAgICAgICAgICAgIGtleTogXCIyNGIyMjZhNTVhMzZiYTdkNGUyNFwiLFxuICAgICAgICAgICAgICBjbHVzdGVyOiBcIm10MVwiLFxuICAgICAgICAgICAgICB2ZXJib3NlOiB0cnVlLFxuICAgICAgICAgICAgICB2ZXJpZnlDb25uZWN0aW9uOiB0cnVlLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICB9LFxuICAgICAgICAgIEVyeTogeyB0YWJsZU5hbWVQcmVmaXg6IFwiYXJ0LWNoYXQtZGV2LlwiIH0sXG4gICAgICAgIH07XG4gICAgICAgIHRoaXMuZGVlcE1lcmdlSW5Db25maWcoXG4gICAgICAgICAgcmVxdWlyZShcIi4uLy4uLy4uLy5hcnRDb25maWdzLnByaXZhdGVcIilbdGhpcy5uYW1lXVxuICAgICAgICApO1xuICAgICAgfVxuICAgICkpO1xuICB9KSgpO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4gKCgpID0+IHtcbiAgICBsZXQgUHJvZHVjdGlvbjtcbiAgICByZXR1cm4gKFByb2R1Y3Rpb24gPSBDYWYuZGVmQ2xhc3MoXG4gICAgICBjbGFzcyBQcm9kdWN0aW9uIGV4dGVuZHMgcmVxdWlyZShcImFydC1jb25maWdcIikuQ29uZmlnIHt9LFxuICAgICAgZnVuY3Rpb24gKFByb2R1Y3Rpb24sIGNsYXNzU3VwZXIsIGluc3RhbmNlU3VwZXIpIHtcbiAgICAgICAgdGhpcy5wcm90b3R5cGUuQXJ0ID0ge1xuICAgICAgICAgIEF3czoge1xuICAgICAgICAgICAgY3JlZGVudGlhbHM6IHsgYWNjZXNzS2V5SWQ6IFwiYmxhaFwiLCBzZWNyZXRBY2Nlc3NLZXk6IFwiYmxhaGJsYWhcIiB9LFxuICAgICAgICAgICAgcmVnaW9uOiBcInVzLWVhc3QtMVwiLFxuICAgICAgICAgIH0sXG4gICAgICAgICAgRXJ5RXh0ZW5zaW9uczoge1xuICAgICAgICAgICAgUHVzaGVyOiB7XG4gICAgICAgICAgICAgIGFwcElkOiBcIjI5NzY5NFwiLFxuICAgICAgICAgICAgICBrZXk6IFwiMjRiMjI2YTU1YTM2YmE3ZDRlMjRcIixcbiAgICAgICAgICAgICAgY2x1c3RlcjogXCJtdDFcIixcbiAgICAgICAgICAgICAgdmVyaWZ5Q29ubmVjdGlvbjogdHJ1ZSxcbiAgICAgICAgICAgIH0sXG4gICAgICAgICAgfSxcbiAgICAgICAgICBFcnk6IHsgdGFibGVOYW1lUHJlZml4OiBcImFydC1jaGF0LXByb2QuXCIgfSxcbiAgICAgICAgfTtcbiAgICAgICAgdGhpcy5kZWVwTWVyZ2VJbkNvbmZpZyhcbiAgICAgICAgICByZXF1aXJlKFwiLi4vLi4vLi4vLmFydENvbmZpZ3MucHJpdmF0ZVwiKVt0aGlzLm5hbWVdXG4gICAgICAgICk7XG4gICAgICB9XG4gICAgKSk7XG4gIH0pKCk7XG59KTtcbiIsIlwidXNlIHN0cmljdFwiO1xubGV0IENhZiA9IHJlcXVpcmUoXCJjYWZmZWluZS1zY3JpcHQtcnVudGltZVwiKTtcbkNhZi5kZWZNb2QobW9kdWxlLCAoKSA9PiB7XG4gIHJldHVybiBDYWYuaW1wb3J0SW52b2tlKFxuICAgIFtcIlB1c2hlclBpcGVsaW5lTWl4aW5cIl0sXG4gICAgW2dsb2JhbCwgcmVxdWlyZShcImFydC1zdGFuZGFyZC1saWJcIiksIHJlcXVpcmUoXCJhcnQtZXJ5LXB1c2hlclwiKV0sXG4gICAgKFB1c2hlclBpcGVsaW5lTWl4aW4pID0+IHtcbiAgICAgIGxldCBDaGF0O1xuICAgICAgcmV0dXJuIChDaGF0ID0gQ2FmLmRlZkNsYXNzKFxuICAgICAgICBjbGFzcyBDaGF0IGV4dGVuZHMgUHVzaGVyUGlwZWxpbmVNaXhpbihcbiAgICAgICAgICByZXF1aXJlKFwiYXJ0LWVyeS1hd3NcIikuRHluYW1vRGJQaXBlbGluZVxuICAgICAgICApIHt9LFxuICAgICAgICBmdW5jdGlvbiAoQ2hhdCwgY2xhc3NTdXBlciwgaW5zdGFuY2VTdXBlcikge1xuICAgICAgICAgIHRoaXMuZ2xvYmFsSW5kZXhlcyh7IGNoYXRzQnlDaGF0Um9vbTogXCJjaGF0Um9vbS9jcmVhdGVkQXRcIiB9KTtcbiAgICAgICAgICB0aGlzLmFkZERhdGFiYXNlRmlsdGVycyh7XG4gICAgICAgICAgICBmaWVsZHM6IHtcbiAgICAgICAgICAgICAgdXNlcjogW1wicmVxdWlyZWRcIiwgXCJ0cmltbWVkU3RyaW5nXCJdLFxuICAgICAgICAgICAgICBtZXNzYWdlOiBbXCJyZXF1aXJlZFwiLCBcInRyaW1tZWRTdHJpbmdcIl0sXG4gICAgICAgICAgICAgIGNoYXRSb29tOiBbXCJyZXF1aXJlZFwiLCBcInRyaW1tZWRTdHJpbmdcIl0sXG4gICAgICAgICAgICB9LFxuICAgICAgICAgIH0pO1xuICAgICAgICAgIHRoaXMucHVibGljUmVxdWVzdFR5cGVzKFwiZ2V0XCIsIFwiY3JlYXRlXCIsIFwiY2hhdHNCeUNoYXRSb29tXCIpO1xuICAgICAgICB9XG4gICAgICApKTtcbiAgICB9XG4gICk7XG59KTtcbiIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9DbGllbnQvQ29tcG9uZW50cy9uYW1lc3BhY2UuanNcblxubW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCcuLi9uYW1lc3BhY2UnKS5hZGROYW1lc3BhY2UoXG4gICdDb21wb25lbnRzJyxcbiAgY2xhc3MgQ29tcG9uZW50cyBleHRlbmRzIE5lcHR1bmUuUGFja2FnZU5hbWVzcGFjZSB7fVxuKTtcbiIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9DbGllbnQvbmFtZXNwYWNlLmpzXG5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi4vbmFtZXNwYWNlJykuYWRkTmFtZXNwYWNlKFxuICAnQ2xpZW50JyxcbiAgY2xhc3MgQ2xpZW50IGV4dGVuZHMgTmVwdHVuZS5QYWNrYWdlTmFtZXNwYWNlIHt9XG4pO1xucmVxdWlyZSgnLi9Db21wb25lbnRzL25hbWVzcGFjZScpOyIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9Db25maWd1cmF0aW9ucy9pbmRleC5qc1xuXG4obW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCcuL25hbWVzcGFjZScpKVxuXG4uYWRkTW9kdWxlcyh7XG4gIERldmVsb3BtZW50OiByZXF1aXJlKCcuL0RldmVsb3BtZW50JyksXG4gIFByb2R1Y3Rpb246ICByZXF1aXJlKCcuL1Byb2R1Y3Rpb24nKVxufSk7IiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L0NvbmZpZ3VyYXRpb25zL25hbWVzcGFjZS5qc1xuXG5tb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4uL25hbWVzcGFjZScpLmFkZE5hbWVzcGFjZShcbiAgJ0NvbmZpZ3VyYXRpb25zJyxcbiAgY2xhc3MgQ29uZmlndXJhdGlvbnMgZXh0ZW5kcyBOZXB0dW5lLlBhY2thZ2VOYW1lc3BhY2Uge31cbik7XG4iLCIvLyBnZW5lcmF0ZWQgYnkgTmVwdHVuZSBOYW1lc3BhY2VzIHY0LngueFxuLy8gZmlsZTogQXJ0LkNoYXQvUGlwZWxpbmVzL2luZGV4LmpzXG5cbihtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4vbmFtZXNwYWNlJykpXG5cbi5hZGRNb2R1bGVzKHtcbiAgQ2hhdDogcmVxdWlyZSgnLi9DaGF0Jylcbn0pOyIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9QaXBlbGluZXMvbmFtZXNwYWNlLmpzXG5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi4vbmFtZXNwYWNlJykuYWRkTmFtZXNwYWNlKFxuICAnUGlwZWxpbmVzJyxcbiAgY2xhc3MgUGlwZWxpbmVzIGV4dGVuZHMgTmVwdHVuZS5QYWNrYWdlTmFtZXNwYWNlIHt9XG4pO1xuIiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L25hbWVzcGFjZS5qc1xuXG5tb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ25lcHR1bmUtbmFtZXNwYWNlcy1ydW50aW1lJykuYWRkTmFtZXNwYWNlKFxuICAnQXJ0LkNoYXQnLFxuICAoY2xhc3MgQ2hhdCBleHRlbmRzIE5lcHR1bmUuUGFja2FnZU5hbWVzcGFjZSB7fSlcbiAgLl9jb25maWd1cmVOYW1lc3BhY2UocmVxdWlyZSgnLi4vLi4vcGFja2FnZS5qc29uJykpXG4pO1xucmVxdWlyZSgnLi9DbGllbnQvbmFtZXNwYWNlJyk7XG5yZXF1aXJlKCcuL0NvbmZpZ3VyYXRpb25zL25hbWVzcGFjZScpO1xucmVxdWlyZSgnLi9QaXBlbGluZXMvbmFtZXNwYWNlJyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtY29uZmlnJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtZXJ5JyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtZXJ5LWF3cycgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnYXJ0LWVyeS1wdXNoZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2FydC1lcnktcHVzaGVyL1NlcnZlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnYXJ0LXN0YW5kYXJkLWxpYicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnYXJ0LXN1aXRlLWFwcC9TZXJ2ZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2NhZmZlaW5lLXNjcmlwdC1ydW50aW1lJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCduZXB0dW5lLW5hbWVzcGFjZXMtcnVudGltZScgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIi8vIFRoZSBtb2R1bGUgY2FjaGVcbnZhciBfX3dlYnBhY2tfbW9kdWxlX2NhY2hlX18gPSB7fTtcblxuLy8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbmZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblx0Ly8gQ2hlY2sgaWYgbW9kdWxlIGlzIGluIGNhY2hlXG5cdHZhciBjYWNoZWRNb2R1bGUgPSBfX3dlYnBhY2tfbW9kdWxlX2NhY2hlX19bbW9kdWxlSWRdO1xuXHRpZiAoY2FjaGVkTW9kdWxlICE9PSB1bmRlZmluZWQpIHtcblx0XHRyZXR1cm4gY2FjaGVkTW9kdWxlLmV4cG9ydHM7XG5cdH1cblx0Ly8gQ3JlYXRlIGEgbmV3IG1vZHVsZSAoYW5kIHB1dCBpdCBpbnRvIHRoZSBjYWNoZSlcblx0dmFyIG1vZHVsZSA9IF9fd2VicGFja19tb2R1bGVfY2FjaGVfX1ttb2R1bGVJZF0gPSB7XG5cdFx0aWQ6IG1vZHVsZUlkLFxuXHRcdGxvYWRlZDogZmFsc2UsXG5cdFx0ZXhwb3J0czoge31cblx0fTtcblxuXHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cblx0X193ZWJwYWNrX21vZHVsZXNfX1ttb2R1bGVJZF0obW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cblx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuXHRtb2R1bGUubG9hZGVkID0gdHJ1ZTtcblxuXHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuXHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG59XG5cbiIsIl9fd2VicGFja19yZXF1aXJlX18ubm1kID0gKG1vZHVsZSkgPT4ge1xuXHRtb2R1bGUucGF0aHMgPSBbXTtcblx0aWYgKCFtb2R1bGUuY2hpbGRyZW4pIG1vZHVsZS5jaGlsZHJlbiA9IFtdO1xuXHRyZXR1cm4gbW9kdWxlO1xufTsiLCIiLCIvLyBzdGFydHVwXG4vLyBMb2FkIGVudHJ5IG1vZHVsZSBhbmQgcmV0dXJuIGV4cG9ydHNcbi8vIFRoaXMgZW50cnkgbW9kdWxlIGlzIHJlZmVyZW5jZWQgYnkgb3RoZXIgbW9kdWxlcyBzbyBpdCBjYW4ndCBiZSBpbmxpbmVkXG52YXIgX193ZWJwYWNrX2V4cG9ydHNfXyA9IF9fd2VicGFja19yZXF1aXJlX18oXCIuL1NlcnZlci5jYWZcIik7XG4iLCIiXSwibmFtZXMiOltdLCJzb3VyY2VSb290IjoiIn0=