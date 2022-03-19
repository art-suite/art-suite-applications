/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./Server.caf":
/*!********************!*\
  !*** ./Server.caf ***!
  \********************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  __webpack_require__(/*! art-ery-pusher/Server */ "art-ery-pusher/Server");
  return (__webpack_require__(/*! art-suite-server */ "art-suite-server").start)({
    app: __webpack_require__(/*! ./source */ "./source/index.caf"),
    static: { root: "./public" },
  });
});


/***/ }),

/***/ "./artConfigsPrivate.caf":
/*!*******************************!*\
  !*** ./artConfigsPrivate.caf ***!
  \*******************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  return {
    Art: {
      Ery: {
        Pusher: {
          appId: "104902",
          key: "1454aa9845ff6471f86c",
          secret: "d80d4f703cefd740af8d",
          cluster: "mt1",
        },
      },
    },
  };
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
      class Development extends (__webpack_require__(/*! art-config */ "art-config").Config) {},
      function (Development, classSuper, instanceSuper) {
        this.prototype.Art = {
          Aws: {
            credentials: { accessKeyId: "blah", secretAccessKey: "blahblah" },
            region: "us-west-2",
            dynamoDb: { endpoint: "http://localhost:8011/proxy" },
          },
          EryExtensions: {
            Pusher: {
              appId: "1264953",
              key: "0ebfb9347ec2b3230ae5",
              cluster: "us3",
              verbose: true,
              verifyConnection: true,
            },
          },
          Ery: { tableNamePrefix: "art-chat-dev." },
        };
        this.deepMergeInConfig(
          __webpack_require__(/*! ../../../artConfigsPrivate */ "./artConfigsPrivate.caf")[this.name]
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
      class Production extends (__webpack_require__(/*! art-config */ "art-config").Config) {},
      function (Production, classSuper, instanceSuper) {
        this.prototype.Art = {
          Aws: {
            credentials: { accessKeyId: "blah", secretAccessKey: "blahblah" },
            region: "us-east-1",
          },
          EryExtensions: {
            Pusher: {
              appId: "1264953",
              key: "0ebfb9347ec2b3230ae5",
              cluster: "us3",
              verifyConnection: true,
            },
          },
          Ery: { tableNamePrefix: "art-chat-prod." },
        };
        this.deepMergeInConfig(
          __webpack_require__(/*! ../../../artConfigsPrivate */ "./artConfigsPrivate.caf")[this.name]
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

/***/ "./source/index.caf":
/*!**************************!*\
  !*** ./source/index.caf ***!
  \**************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

"use strict";
/* module decorator */ module = __webpack_require__.nmd(module);

let Caf = __webpack_require__(/*! caffeine-script-runtime */ "caffeine-script-runtime");
Caf.defMod(module, () => {
  return __webpack_require__(/*! ./Art.Chat */ "./source/Art.Chat/index.js");
});


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

/***/ "./source/Art.Chat/index.js":
/*!**********************************!*\
  !*** ./source/Art.Chat/index.js ***!
  \**********************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

// generated by Neptune Namespaces v4.x.x
// file: Art.Chat/index.js

module.exports = __webpack_require__(/*! ./namespace */ "./source/Art.Chat/namespace.js");
__webpack_require__(/*! ./Configurations */ "./source/Art.Chat/Configurations/index.js");
__webpack_require__(/*! ./Pipelines */ "./source/Art.Chat/Pipelines/index.js");

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

/***/ "art-suite-server":
/*!***********************************************************************************!*\
  !*** external "require('art-suite-server' /* ABC - not inlining fellow NPM *_/)" ***!
  \***********************************************************************************/
/***/ ((module) => {

"use strict";
module.exports = require('art-suite-server' /* ABC - not inlining fellow NPM */);

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
module.exports = JSON.parse('{"author":"Shane Brinkman-Davis Delamore, Imikimi LLC\\"","bugs":"https://github.com/art-suite/art-suite-applications/issues","dependencies":{"art-ery-pusher":"^0.12.0","art-suite":"^2.0.7"},"description":"Art.Chat","devDependencies":{"art-build-configurator":"^1.29.3","crypto-browserify":"^3.12.0","local-cors-proxy":"^1.1.0","stream-browserify":"^3.0.0"},"engines":{"node":"8.x"},"homepage":"https://github.com/art-suite/art-suite-applications","license":"ISC","name":"art-chat","repository":{"type":"git","url":"https://github.com/art-suite/art-suite-applications.git"},"scripts":{"build":"nn -s; webpack --progress","dynamodb":"docker run -p 8081:8000 amazon/dynamodb-local","init-dev":"nn -s\\n./tool initialize-pipelines","lcp":"lcp --proxyUrl http://localhost:8081 --port 8011","start":"npm run start-dev-web-server","start-db":"npm run dynamodb& npm run lcp","start-dev":"npm run start-db& sleep 2; npm run init-dev; npm run start-dev-web-server; wait","start-dev-web-server":"cafSourceMaps=true webpack serve --hot --progress --static .","start-server":"caf ./Server.caf","test":"cafSourceMaps=true webpack serve --progress"},"version":"0.0.1"}');

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
//# sourceMappingURL=data:application/json;charset=utf-8;base64,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Q25EO0FBQ0EsbUJBQU8sQ0FBQyxpRkFBNEI7QUFDcEMsbUJBQU8sQ0FBQyx1RUFBdUI7Ozs7Ozs7Ozs7O0FDVC9COzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7OztBQ0FBOzs7Ozs7Ozs7Ozs7Ozs7OztVQ0FBO1VBQ0E7O1VBRUE7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7VUFDQTtVQUNBO1VBQ0E7O1VBRUE7VUFDQTs7VUFFQTtVQUNBOztVQUVBO1VBQ0E7VUFDQTs7Ozs7V0N6QkE7V0FDQTtXQUNBO1dBQ0E7V0FDQTs7Ozs7VUVKQTtVQUNBO1VBQ0E7VUFDQSIsInNvdXJjZXMiOlsid2VicGFjazovL2FydC1jaGF0Ly4vU2VydmVyLmNhZiIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL2FydENvbmZpZ3NQcml2YXRlLmNhZiIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9Db25maWd1cmF0aW9ucy9EZXZlbG9wbWVudC5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvQ29uZmlndXJhdGlvbnMvUHJvZHVjdGlvbi5jYWYiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvUGlwZWxpbmVzL0NoYXQuY2FmIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL2luZGV4LmNhZiIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9Db25maWd1cmF0aW9ucy9pbmRleC5qcyIsIndlYnBhY2s6Ly9hcnQtY2hhdC8uL3NvdXJjZS9BcnQuQ2hhdC9Db25maWd1cmF0aW9ucy9uYW1lc3BhY2UuanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvUGlwZWxpbmVzL2luZGV4LmpzIiwid2VicGFjazovL2FydC1jaGF0Ly4vc291cmNlL0FydC5DaGF0L1BpcGVsaW5lcy9uYW1lc3BhY2UuanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvaW5kZXguanMiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvLi9zb3VyY2UvQXJ0LkNoYXQvbmFtZXNwYWNlLmpzIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtY29uZmlnJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnYXJ0LWVyeS1hd3MnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtZXJ5LXB1c2hlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2FydC1lcnktcHVzaGVyL1NlcnZlcicgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvZXh0ZXJuYWwgcm9vdCBcInJlcXVpcmUoJ2FydC1zdGFuZGFyZC1saWInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCdhcnQtc3VpdGUtc2VydmVyJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLylcIiIsIndlYnBhY2s6Ly9hcnQtY2hhdC9leHRlcm5hbCByb290IFwicmVxdWlyZSgnY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWUnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKVwiIiwid2VicGFjazovL2FydC1jaGF0L2V4dGVybmFsIHJvb3QgXCJyZXF1aXJlKCduZXB0dW5lLW5hbWVzcGFjZXMtcnVudGltZScgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pXCIiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvd2VicGFjay9ib290c3RyYXAiLCJ3ZWJwYWNrOi8vYXJ0LWNoYXQvd2VicGFjay9ydW50aW1lL25vZGUgbW9kdWxlIGRlY29yYXRvciIsIndlYnBhY2s6Ly9hcnQtY2hhdC93ZWJwYWNrL2JlZm9yZS1zdGFydHVwIiwid2VicGFjazovL2FydC1jaGF0L3dlYnBhY2svc3RhcnR1cCIsIndlYnBhY2s6Ly9hcnQtY2hhdC93ZWJwYWNrL2FmdGVyLXN0YXJ0dXAiXSwic291cmNlc0NvbnRlbnQiOlsiXCJ1c2Ugc3RyaWN0XCI7XG5sZXQgQ2FmID0gcmVxdWlyZShcImNhZmZlaW5lLXNjcmlwdC1ydW50aW1lXCIpO1xuQ2FmLmRlZk1vZChtb2R1bGUsICgpID0+IHtcbiAgcmVxdWlyZShcImFydC1lcnktcHVzaGVyL1NlcnZlclwiKTtcbiAgcmV0dXJuIHJlcXVpcmUoXCJhcnQtc3VpdGUtc2VydmVyXCIpLnN0YXJ0KHtcbiAgICBhcHA6IHJlcXVpcmUoXCIuL3NvdXJjZVwiKSxcbiAgICBzdGF0aWM6IHsgcm9vdDogXCIuL3B1YmxpY1wiIH0sXG4gIH0pO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4ge1xuICAgIEFydDoge1xuICAgICAgRXJ5OiB7XG4gICAgICAgIFB1c2hlcjoge1xuICAgICAgICAgIGFwcElkOiBcIjEwNDkwMlwiLFxuICAgICAgICAgIGtleTogXCIxNDU0YWE5ODQ1ZmY2NDcxZjg2Y1wiLFxuICAgICAgICAgIHNlY3JldDogXCJkODBkNGY3MDNjZWZkNzQwYWY4ZFwiLFxuICAgICAgICAgIGNsdXN0ZXI6IFwibXQxXCIsXG4gICAgICAgIH0sXG4gICAgICB9LFxuICAgIH0sXG4gIH07XG59KTtcbiIsIlwidXNlIHN0cmljdFwiO1xubGV0IENhZiA9IHJlcXVpcmUoXCJjYWZmZWluZS1zY3JpcHQtcnVudGltZVwiKTtcbkNhZi5kZWZNb2QobW9kdWxlLCAoKSA9PiB7XG4gIHJldHVybiAoKCkgPT4ge1xuICAgIGxldCBEZXZlbG9wbWVudDtcbiAgICByZXR1cm4gKERldmVsb3BtZW50ID0gQ2FmLmRlZkNsYXNzKFxuICAgICAgY2xhc3MgRGV2ZWxvcG1lbnQgZXh0ZW5kcyByZXF1aXJlKFwiYXJ0LWNvbmZpZ1wiKS5Db25maWcge30sXG4gICAgICBmdW5jdGlvbiAoRGV2ZWxvcG1lbnQsIGNsYXNzU3VwZXIsIGluc3RhbmNlU3VwZXIpIHtcbiAgICAgICAgdGhpcy5wcm90b3R5cGUuQXJ0ID0ge1xuICAgICAgICAgIEF3czoge1xuICAgICAgICAgICAgY3JlZGVudGlhbHM6IHsgYWNjZXNzS2V5SWQ6IFwiYmxhaFwiLCBzZWNyZXRBY2Nlc3NLZXk6IFwiYmxhaGJsYWhcIiB9LFxuICAgICAgICAgICAgcmVnaW9uOiBcInVzLXdlc3QtMlwiLFxuICAgICAgICAgICAgZHluYW1vRGI6IHsgZW5kcG9pbnQ6IFwiaHR0cDovL2xvY2FsaG9zdDo4MDExL3Byb3h5XCIgfSxcbiAgICAgICAgICB9LFxuICAgICAgICAgIEVyeUV4dGVuc2lvbnM6IHtcbiAgICAgICAgICAgIFB1c2hlcjoge1xuICAgICAgICAgICAgICBhcHBJZDogXCIxMjY0OTUzXCIsXG4gICAgICAgICAgICAgIGtleTogXCIwZWJmYjkzNDdlYzJiMzIzMGFlNVwiLFxuICAgICAgICAgICAgICBjbHVzdGVyOiBcInVzM1wiLFxuICAgICAgICAgICAgICB2ZXJib3NlOiB0cnVlLFxuICAgICAgICAgICAgICB2ZXJpZnlDb25uZWN0aW9uOiB0cnVlLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICB9LFxuICAgICAgICAgIEVyeTogeyB0YWJsZU5hbWVQcmVmaXg6IFwiYXJ0LWNoYXQtZGV2LlwiIH0sXG4gICAgICAgIH07XG4gICAgICAgIHRoaXMuZGVlcE1lcmdlSW5Db25maWcoXG4gICAgICAgICAgcmVxdWlyZShcIi4uLy4uLy4uL2FydENvbmZpZ3NQcml2YXRlXCIpW3RoaXMubmFtZV1cbiAgICAgICAgKTtcbiAgICAgIH1cbiAgICApKTtcbiAgfSkoKTtcbn0pO1xuIiwiXCJ1c2Ugc3RyaWN0XCI7XG5sZXQgQ2FmID0gcmVxdWlyZShcImNhZmZlaW5lLXNjcmlwdC1ydW50aW1lXCIpO1xuQ2FmLmRlZk1vZChtb2R1bGUsICgpID0+IHtcbiAgcmV0dXJuICgoKSA9PiB7XG4gICAgbGV0IFByb2R1Y3Rpb247XG4gICAgcmV0dXJuIChQcm9kdWN0aW9uID0gQ2FmLmRlZkNsYXNzKFxuICAgICAgY2xhc3MgUHJvZHVjdGlvbiBleHRlbmRzIHJlcXVpcmUoXCJhcnQtY29uZmlnXCIpLkNvbmZpZyB7fSxcbiAgICAgIGZ1bmN0aW9uIChQcm9kdWN0aW9uLCBjbGFzc1N1cGVyLCBpbnN0YW5jZVN1cGVyKSB7XG4gICAgICAgIHRoaXMucHJvdG90eXBlLkFydCA9IHtcbiAgICAgICAgICBBd3M6IHtcbiAgICAgICAgICAgIGNyZWRlbnRpYWxzOiB7IGFjY2Vzc0tleUlkOiBcImJsYWhcIiwgc2VjcmV0QWNjZXNzS2V5OiBcImJsYWhibGFoXCIgfSxcbiAgICAgICAgICAgIHJlZ2lvbjogXCJ1cy1lYXN0LTFcIixcbiAgICAgICAgICB9LFxuICAgICAgICAgIEVyeUV4dGVuc2lvbnM6IHtcbiAgICAgICAgICAgIFB1c2hlcjoge1xuICAgICAgICAgICAgICBhcHBJZDogXCIxMjY0OTUzXCIsXG4gICAgICAgICAgICAgIGtleTogXCIwZWJmYjkzNDdlYzJiMzIzMGFlNVwiLFxuICAgICAgICAgICAgICBjbHVzdGVyOiBcInVzM1wiLFxuICAgICAgICAgICAgICB2ZXJpZnlDb25uZWN0aW9uOiB0cnVlLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICB9LFxuICAgICAgICAgIEVyeTogeyB0YWJsZU5hbWVQcmVmaXg6IFwiYXJ0LWNoYXQtcHJvZC5cIiB9LFxuICAgICAgICB9O1xuICAgICAgICB0aGlzLmRlZXBNZXJnZUluQ29uZmlnKFxuICAgICAgICAgIHJlcXVpcmUoXCIuLi8uLi8uLi9hcnRDb25maWdzUHJpdmF0ZVwiKVt0aGlzLm5hbWVdXG4gICAgICAgICk7XG4gICAgICB9XG4gICAgKSk7XG4gIH0pKCk7XG59KTtcbiIsIlwidXNlIHN0cmljdFwiO1xubGV0IENhZiA9IHJlcXVpcmUoXCJjYWZmZWluZS1zY3JpcHQtcnVudGltZVwiKTtcbkNhZi5kZWZNb2QobW9kdWxlLCAoKSA9PiB7XG4gIHJldHVybiBDYWYuaW1wb3J0SW52b2tlKFxuICAgIFtcIlB1c2hlclBpcGVsaW5lTWl4aW5cIiwgXCJEeW5hbW9EYlBpcGVsaW5lXCJdLFxuICAgIFtcbiAgICAgIGdsb2JhbCxcbiAgICAgIHJlcXVpcmUoXCJhcnQtc3RhbmRhcmQtbGliXCIpLFxuICAgICAgcmVxdWlyZShcImFydC1lcnktcHVzaGVyXCIpLFxuICAgICAgcmVxdWlyZShcImFydC1lcnktYXdzXCIpLFxuICAgIF0sXG4gICAgKFB1c2hlclBpcGVsaW5lTWl4aW4sIER5bmFtb0RiUGlwZWxpbmUpID0+IHtcbiAgICAgIGxldCBDaGF0O1xuICAgICAgcmV0dXJuIChDaGF0ID0gQ2FmLmRlZkNsYXNzKFxuICAgICAgICBjbGFzcyBDaGF0IGV4dGVuZHMgUHVzaGVyUGlwZWxpbmVNaXhpbihEeW5hbW9EYlBpcGVsaW5lKSB7fSxcbiAgICAgICAgZnVuY3Rpb24gKENoYXQsIGNsYXNzU3VwZXIsIGluc3RhbmNlU3VwZXIpIHtcbiAgICAgICAgICB0aGlzLmdsb2JhbEluZGV4ZXMoeyBjaGF0c0J5Q2hhdFJvb206IFwiY2hhdFJvb20vY3JlYXRlZEF0XCIgfSk7XG4gICAgICAgICAgdGhpcy5hZGREYXRhYmFzZUZpbHRlcnMoe1xuICAgICAgICAgICAgZmllbGRzOiB7XG4gICAgICAgICAgICAgIHVzZXI6IFtcInJlcXVpcmVkXCIsIFwidHJpbW1lZFN0cmluZ1wiXSxcbiAgICAgICAgICAgICAgbWVzc2FnZTogW1wicmVxdWlyZWRcIiwgXCJ0cmltbWVkU3RyaW5nXCJdLFxuICAgICAgICAgICAgICBjaGF0Um9vbTogW1wicmVxdWlyZWRcIiwgXCJ0cmltbWVkU3RyaW5nXCJdLFxuICAgICAgICAgICAgfSxcbiAgICAgICAgICB9KTtcbiAgICAgICAgICB0aGlzLnB1YmxpY1JlcXVlc3RUeXBlcyhcImdldFwiLCBcImNyZWF0ZVwiLCBcImNoYXRzQnlDaGF0Um9vbVwiKTtcbiAgICAgICAgfVxuICAgICAgKSk7XG4gICAgfVxuICApO1xufSk7XG4iLCJcInVzZSBzdHJpY3RcIjtcbmxldCBDYWYgPSByZXF1aXJlKFwiY2FmZmVpbmUtc2NyaXB0LXJ1bnRpbWVcIik7XG5DYWYuZGVmTW9kKG1vZHVsZSwgKCkgPT4ge1xuICByZXR1cm4gcmVxdWlyZShcIi4vQXJ0LkNoYXRcIik7XG59KTtcbiIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9Db25maWd1cmF0aW9ucy9pbmRleC5qc1xuXG4obW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCcuL25hbWVzcGFjZScpKVxuXG4uYWRkTW9kdWxlcyh7XG4gIERldmVsb3BtZW50OiByZXF1aXJlKCcuL0RldmVsb3BtZW50JyksXG4gIFByb2R1Y3Rpb246ICByZXF1aXJlKCcuL1Byb2R1Y3Rpb24nKVxufSk7IiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L0NvbmZpZ3VyYXRpb25zL25hbWVzcGFjZS5qc1xuXG5tb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4uL25hbWVzcGFjZScpLmFkZE5hbWVzcGFjZShcbiAgJ0NvbmZpZ3VyYXRpb25zJyxcbiAgY2xhc3MgQ29uZmlndXJhdGlvbnMgZXh0ZW5kcyBOZXB0dW5lLlBhY2thZ2VOYW1lc3BhY2Uge31cbik7XG4iLCIvLyBnZW5lcmF0ZWQgYnkgTmVwdHVuZSBOYW1lc3BhY2VzIHY0LngueFxuLy8gZmlsZTogQXJ0LkNoYXQvUGlwZWxpbmVzL2luZGV4LmpzXG5cbihtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJy4vbmFtZXNwYWNlJykpXG5cbi5hZGRNb2R1bGVzKHtcbiAgQ2hhdDogcmVxdWlyZSgnLi9DaGF0Jylcbn0pOyIsIi8vIGdlbmVyYXRlZCBieSBOZXB0dW5lIE5hbWVzcGFjZXMgdjQueC54XG4vLyBmaWxlOiBBcnQuQ2hhdC9QaXBlbGluZXMvbmFtZXNwYWNlLmpzXG5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi4vbmFtZXNwYWNlJykuYWRkTmFtZXNwYWNlKFxuICAnUGlwZWxpbmVzJyxcbiAgY2xhc3MgUGlwZWxpbmVzIGV4dGVuZHMgTmVwdHVuZS5QYWNrYWdlTmFtZXNwYWNlIHt9XG4pO1xuIiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L2luZGV4LmpzXG5cbm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnLi9uYW1lc3BhY2UnKTtcbnJlcXVpcmUoJy4vQ29uZmlndXJhdGlvbnMnKTtcbnJlcXVpcmUoJy4vUGlwZWxpbmVzJyk7IiwiLy8gZ2VuZXJhdGVkIGJ5IE5lcHR1bmUgTmFtZXNwYWNlcyB2NC54Lnhcbi8vIGZpbGU6IEFydC5DaGF0L25hbWVzcGFjZS5qc1xuXG5tb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ25lcHR1bmUtbmFtZXNwYWNlcy1ydW50aW1lJykuYWRkTmFtZXNwYWNlKFxuICAnQXJ0LkNoYXQnLFxuICAoY2xhc3MgQ2hhdCBleHRlbmRzIE5lcHR1bmUuUGFja2FnZU5hbWVzcGFjZSB7fSlcbiAgLl9jb25maWd1cmVOYW1lc3BhY2UocmVxdWlyZSgnLi4vLi4vcGFja2FnZS5qc29uJykpXG4pO1xucmVxdWlyZSgnLi9Db25maWd1cmF0aW9ucy9uYW1lc3BhY2UnKTtcbnJlcXVpcmUoJy4vUGlwZWxpbmVzL25hbWVzcGFjZScpOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnYXJ0LWNvbmZpZycgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIm1vZHVsZS5leHBvcnRzID0gcmVxdWlyZSgnYXJ0LWVyeS1hd3MnIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2FydC1lcnktcHVzaGVyJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCdhcnQtZXJ5LXB1c2hlci9TZXJ2ZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2FydC1zdGFuZGFyZC1saWInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2FydC1zdWl0ZS1zZXJ2ZXInIC8qIEFCQyAtIG5vdCBpbmxpbmluZyBmZWxsb3cgTlBNICovKTsiLCJtb2R1bGUuZXhwb3J0cyA9IHJlcXVpcmUoJ2NhZmZlaW5lLXNjcmlwdC1ydW50aW1lJyAvKiBBQkMgLSBub3QgaW5saW5pbmcgZmVsbG93IE5QTSAqLyk7IiwibW9kdWxlLmV4cG9ydHMgPSByZXF1aXJlKCduZXB0dW5lLW5hbWVzcGFjZXMtcnVudGltZScgLyogQUJDIC0gbm90IGlubGluaW5nIGZlbGxvdyBOUE0gKi8pOyIsIi8vIFRoZSBtb2R1bGUgY2FjaGVcbnZhciBfX3dlYnBhY2tfbW9kdWxlX2NhY2hlX18gPSB7fTtcblxuLy8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbmZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblx0Ly8gQ2hlY2sgaWYgbW9kdWxlIGlzIGluIGNhY2hlXG5cdHZhciBjYWNoZWRNb2R1bGUgPSBfX3dlYnBhY2tfbW9kdWxlX2NhY2hlX19bbW9kdWxlSWRdO1xuXHRpZiAoY2FjaGVkTW9kdWxlICE9PSB1bmRlZmluZWQpIHtcblx0XHRyZXR1cm4gY2FjaGVkTW9kdWxlLmV4cG9ydHM7XG5cdH1cblx0Ly8gQ3JlYXRlIGEgbmV3IG1vZHVsZSAoYW5kIHB1dCBpdCBpbnRvIHRoZSBjYWNoZSlcblx0dmFyIG1vZHVsZSA9IF9fd2VicGFja19tb2R1bGVfY2FjaGVfX1ttb2R1bGVJZF0gPSB7XG5cdFx0aWQ6IG1vZHVsZUlkLFxuXHRcdGxvYWRlZDogZmFsc2UsXG5cdFx0ZXhwb3J0czoge31cblx0fTtcblxuXHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cblx0X193ZWJwYWNrX21vZHVsZXNfX1ttb2R1bGVJZF0obW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cblx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuXHRtb2R1bGUubG9hZGVkID0gdHJ1ZTtcblxuXHQvLyBSZXR1cm4gdGhlIGV4cG9ydHMgb2YgdGhlIG1vZHVsZVxuXHRyZXR1cm4gbW9kdWxlLmV4cG9ydHM7XG59XG5cbiIsIl9fd2VicGFja19yZXF1aXJlX18ubm1kID0gKG1vZHVsZSkgPT4ge1xuXHRtb2R1bGUucGF0aHMgPSBbXTtcblx0aWYgKCFtb2R1bGUuY2hpbGRyZW4pIG1vZHVsZS5jaGlsZHJlbiA9IFtdO1xuXHRyZXR1cm4gbW9kdWxlO1xufTsiLCIiLCIvLyBzdGFydHVwXG4vLyBMb2FkIGVudHJ5IG1vZHVsZSBhbmQgcmV0dXJuIGV4cG9ydHNcbi8vIFRoaXMgZW50cnkgbW9kdWxlIGlzIHJlZmVyZW5jZWQgYnkgb3RoZXIgbW9kdWxlcyBzbyBpdCBjYW4ndCBiZSBpbmxpbmVkXG52YXIgX193ZWJwYWNrX2V4cG9ydHNfXyA9IF9fd2VicGFja19yZXF1aXJlX18oXCIuL1NlcnZlci5jYWZcIik7XG4iLCIiXSwibmFtZXMiOltdLCJzb3VyY2VSb290IjoiIn0=