module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 13);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = function(module) {
	if(!module.webpackPolyfill) {
		module.deprecate = function() {};
		module.paths = [];
		// module.parent = undefined by default
		if(!module.children) module.children = [];
		Object.defineProperty(module, "loaded", {
			enumerable: true,
			get: function() {
				return module.l;
			}
		});
		Object.defineProperty(module, "id", {
			enumerable: true,
			get: function() {
				return module.i;
			}
		});
		module.webpackPolyfill = 1;
	}
	return module;
};


/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = require("caffeine-script-runtime");

/***/ }),
/* 2 */
/***/ (function(module, exports) {

module.exports = require("art-standard-lib");

/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  return (() => {
    let method, AllowAllCorsHandler;
    return (
      (method = null),
      (AllowAllCorsHandler = Caf.defClass(
        class AllowAllCorsHandler extends __webpack_require__(5) {},
        function(AllowAllCorsHandler, classSuper, instanceSuper) {
          this.commonResponseHeaders = { "Access-Control-Allow-Origin": "*" };
          this.prototype.canHandleRequest = function({ method }) {
            return method === "OPTIONS";
          };
          this.prototype.handleRequest = function(request) {
            return {
              status: "success",
              headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods":
                  request.headers["access-control-request-method"] ||
                  "GET, POST, PUT, UPDATE, DELETE",
                "Access-Control-Allow-Headers":
                  request.headers["access-control-request-headers"] || "",
                "Content-Type": "text/html; charset=utf-8"
              }
            };
          };
        }
      ))
    );
  })();
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  return Caf.importInvoke(
    ["String", "log", "dateFormat", "compactFlatten", "pad"],
    [global, __webpack_require__(2)],
    (String, log, dateFormat, compactFlatten, pad) => {
      return function(superClass) {
        let LoggingMixin;
        return (LoggingMixin = Caf.defClass(
          class LoggingMixin extends superClass {},
          function(LoggingMixin, classSuper, instanceSuper) {
            this.prototype.log = function(toLog) {
              return Caf.is(toLog, String)
                ? log(`${Caf.toString(this.logHeader)}: ${Caf.toString(toLog)}`)
                : log.withOptions({ color: true }, this.preprocessLog(toLog));
            };
            this.prototype.logError = function(toLog) {
              return log.error(this.preprocessLog(toLog));
            };
            this.prototype.logVerbose = function(toLog) {
              return this.verbose ? this.log(toLog) : undefined;
            };
            this.prototype.preprocessLog = function(toLog) {
              return { [`${Caf.toString(this.logHeader)}`]: toLog };
            };
            this.setter("verbose");
            this.getter({
              logTime: function() {
                return dateFormat("UTC:yyyy-mm-dd_HH-MM-ss");
              },
              verbose: function() {
                let cafBase;
                return (
                  this._verbose ||
                  (Caf.exists((cafBase = this.options)) && cafBase.verbose)
                );
              },
              logHeader: function() {
                return compactFlatten([
                  this.logTime,
                  this.workerId &&
                    `worker${Caf.toString(pad(this.workerId, 4, "0", true))}`,
                  this.class.getName()
                ]).join(" ");
              }
            });
          }
        ));
      };
    }
  );
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  return Caf.importInvoke(
    [
      "Promise",
      "serverFailure",
      "Error",
      "formattedInspect",
      "encodeHttpStatus",
      "JSON",
      "isString",
      "findUrlRegexp",
      "merge",
      "missing",
      "isPlainObject"
    ],
    [global, __webpack_require__(2), __webpack_require__(7)],
    (
      Promise,
      serverFailure,
      Error,
      formattedInspect,
      encodeHttpStatus,
      JSON,
      isString,
      findUrlRegexp,
      merge,
      missing,
      isPlainObject
    ) => {
      let querystring, PromiseHandler;
      return (
        (querystring = __webpack_require__(25)),
        (PromiseHandler = Caf.defClass(
          class PromiseHandler extends __webpack_require__(4)(
            __webpack_require__(9).BaseClass
          ) {
            constructor(options = {}) {
              super(...arguments);
              this.options = options;
              this.logVerbose("initialized");
              this._commonResponseHeaders = this.options.commonResponseHeaders;
            }
          },
          function(PromiseHandler, classSuper, instanceSuper) {
            this.getMiddleware = function(options) {
              return new this(options).middleware;
            };
            this.getter({
              handleUrlRegex: function() {
                return null;
              }
            });
            this.prototype.canHandleRequest = function(request) {
              return this.handleUrlRegex
                ? this.handleUrlRegex.test(request.url)
                : true;
            };
            this.prototype.handleApiRequest = null;
            this.prototype.handleHtmlRequest = null;
            this.prototype.handleRequest = function(request, requestData) {
              return Promise.then(() => {
                return (() => {
                  switch (false) {
                    case !this.handleApiRequest:
                      return this._handleApiRequestWrapper(
                        request,
                        requestData
                      );
                    case !this.handleHtmlRequest:
                      return this._handleHtmlRequestWrapper(
                        request,
                        requestData
                      );
                    default:
                      return null;
                  }
                })();
              });
            };
            this.getter({
              middleware: function() {
                return (request, response, next) => {
                  let dataChunks, requestData;
                  return this.canHandleRequest(request)
                    ? (this.logVerbose({
                        start: { method: request.method, url: request.url }
                      }),
                      (dataChunks = []),
                      (requestData = null),
                      request.on("data", chunk => {
                        return dataChunks.push(chunk);
                      }),
                      request.on("end", () => {
                        return Promise.then(() => {
                          return this.handleRequest(
                            request,
                            (requestData = dataChunks.join(""))
                          );
                        })
                          .catch(error => {
                            this.logError({
                              internalError: { request, error }
                            });
                            return { status: serverFailure };
                          })
                          .then(plainResponse => {
                            let headers, data, status, statusCode, responseData;
                            if (plainResponse) {
                              ({
                                headers,
                                data,
                                status,
                                statusCode
                              } = plainResponse);
                              if (
                                !(
                                  data != null ||
                                  status != null ||
                                  statusCode != null
                                )
                              ) {
                                throw new Error(
                                  `expected data, status or statusCode in response: ${Caf.toString(
                                    formattedInspect(plainResponse)
                                  )}`
                                );
                              }
                            }
                            responseData = data;
                            response.statusCode =
                              statusCode ||
                              (status && (statusCode = encodeHttpStatus(status))
                                ? statusCode
                                : (statusCode = data ? 200 : 404));
                            if (((statusCode / 100) | 0) === 5) {
                              this.logError({
                                url: request.url,
                                requestData:
                                  (() => {
                                    try {
                                      return JSON.parse(requestData);
                                    } catch (cafError) {}
                                  })() || requestData,
                                responseData:
                                  (() => {
                                    try {
                                      return JSON.parse(responseData);
                                    } catch (cafError) {}
                                  })() || responseData
                              });
                            }
                            return ((statusCode / 100) | 0) === 3
                              ? response.redirect(statusCode, data)
                              : this._encodeOutput(
                                  request,
                                  response,
                                  headers,
                                  responseData
                                );
                          });
                      }))
                    : next();
                };
              }
            });
            this.prototype._encodeJson = function(
              responseHeaders,
              responseData
            ) {
              responseHeaders["Content-Type"] =
                "application/json; charset=UTF-8";
              return JSON.stringify(responseData);
            };
            this.prototype._encodeHtml = function(
              responseHeaders,
              responseData
            ) {
              responseHeaders["Content-Type"] = "text/html; charset=UTF-8";
              return isString(responseData)
                ? responseData
                : `<html><body style='font-family:Monaco,courier;font-size:10pt'>\n${Caf.toString(
                    formattedInspect(responseData)
                      .replace(/\n/g, "<br>\n")
                      .replace(/\ /g, "&nbsp;")
                      .replace(
                        RegExp(`(${Caf.toString(findUrlRegexp.source)})`, "g"),
                        "<a href='$1'>$1</a>"
                      )
                  )}\n</body></html>`;
            };
            this.prototype._encodePlain = function(
              responseHeaders,
              responseData
            ) {
              responseHeaders["Content-Type"] = "text/plain; charset=UTF-8";
              return isString(responseData)
                ? responseData
                : formattedInspect(responseData);
            };
            this.prototype._encodeOutput = function(
              request,
              response,
              responseHeaders = {},
              responseData
            ) {
              let accept, encodedData, headers;
              ({ accept = "text/html" } = request.headers);
              encodedData =
                responseData &&
                (() => {
                  switch (false) {
                    case !/json/.test(accept):
                      return this._encodeJson(responseHeaders, responseData);
                    case !/html/.test(accept):
                      return this._encodeHtml(responseHeaders, responseData);
                    default:
                      return this._encodePlain(responseHeaders, responseData);
                  }
                })();
              Caf.each(
                (headers = merge(this._commonResponseHeaders, responseHeaders)),
                undefined,
                (v, k) => {
                  response.setHeader(k, v);
                }
              );
              this.logVerbose({
                done: {
                  method: request.method,
                  url: request.url,
                  accept,
                  responseData,
                  headers,
                  encodedData
                }
              });
              return response.end(encodedData);
            };
            this.prototype._handleHtmlRequestWrapper = function(
              request,
              requestData
            ) {
              return Promise.then(() => {
                return this.handleHtmlRequest(request, requestData);
              }).then(data => {
                return (() => {
                  switch (false) {
                    case !!(data != null):
                      return { status: missing };
                    case !isPlainObject(data):
                      return data;
                    case !(
                      isString(data) ||
                      (data = Caf.isF(data.toString) && data.toString())
                    ):
                      return { data };
                    default:
                      return (() => {
                        throw new Error(
                          "ArtExpressServer.PromiseHandler#_handleHtmlRequestWrapper - expected string, plainObject, object with toString() or null response"
                        );
                      })();
                  }
                })();
              });
            };
            this.prototype._handleApiRequestWrapper = function(
              request,
              requestData
            ) {
              return Promise.then(() => {
                return JSON.parse(requestData || "{}");
              })
                .catch(() => {
                  return (() => {
                    throw new Error(
                      `requested data was not valid JSON: ${Caf.toString(
                        requestData
                      )}`
                    );
                  })();
                })
                .then(parsedData => {
                  let url, __, query;
                  ({ url } = request);
                  [__, query] = url.split("?");
                  return merge(
                    parsedData,
                    query &&
                      Caf.each(
                        querystring.parse(query),
                        {},
                        (v, cafK, cafInto) => {
                          let cafError;
                          cafInto[cafK] = (() => {
                            try {
                              return JSON.parse(v);
                            } catch (cafError) {
                              return v;
                            }
                          })();
                        }
                      )
                  );
                })
                .then(parsedData => {
                  return this.handleApiRequest(request, parsedData);
                })
                .then(data => {
                  return data ? { data } : { status: missing };
                });
            };
          }
        ))
      );
    }
  );
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  return Caf.importInvoke(
    [
      "getEnv",
      "merge",
      "fastBind",
      "process",
      "Neptune",
      "compactFlatten",
      "Math",
      "timeout",
      "currentSecond",
      "Object"
    ],
    [global, __webpack_require__(2), __webpack_require__(7)],
    (
      getEnv,
      merge,
      fastBind,
      process,
      Neptune,
      compactFlatten,
      Math,
      timeout,
      currentSecond,
      Object
    ) => {
      let memoryCheckCycleMs, Server;
      return (
        __webpack_require__(22),
        (memoryCheckCycleMs = 10000),
        (Server = Caf.defClass(
          class Server extends __webpack_require__(4)(
            __webpack_require__(9).BaseClass
          ) {},
          function(Server, classSuper, instanceSuper) {
            this.defaults = { port: 8085, server: "http://localhost" };
            this.start = function(...manyOptions) {
              return new Server().start(...manyOptions);
            };
            this.prototype.start = function(...manyOptions) {
              let WEB_CONCURRENCY, PORT, ART_EXPRESS_SERVER_VERBOSE, numWorkers;
              ({
                WEB_CONCURRENCY,
                PORT,
                ART_EXPRESS_SERVER_VERBOSE
              } = getEnv());
              if (ART_EXPRESS_SERVER_VERBOSE != null) {
                this.verbose = true;
              }
              ({ numWorkers } = this.options = this._allowAllCors(
                merge(
                  Server.defaults,
                  { numWorkers: WEB_CONCURRENCY || 1, port: PORT },
                  ...manyOptions
                )
              ));
              if (numWorkers != null) {
                numWorkers = numWorkers | 0;
              }
              return numWorkers > 1
                ? __webpack_require__(26)({
                    workers: numWorkers,
                    master: () => {
                      this.logEnvironment();
                      return this.log({
                        start: { throng: { workers: numWorkers } }
                      });
                    },
                    start: fastBind(this._startOneServer, this)
                  })
                : (this.logEnvironment(), this._startOneServer());
            };
            this.prototype.logEnvironment = function() {
              return this.logVerbose({
                start: {
                  options: this.options,
                  verbose: this.verbose,
                  env: merge(
                    Caf.each(process.env, {}, (v, k, cafInto) => {
                      if (k.match(/^art/)) {
                        cafInto[k] = v;
                      }
                    }),
                    {
                      WEB_CONCURRENCY: getEnv().WEB_CONCURRENCY,
                      WEB_MEMORY: getEnv().WEB_MEMORY,
                      MEMORY_AVAILABLE: getEnv().MEMORY_AVAILABLE,
                      PORT: getEnv().PORT,
                      ART_EXPRESS_SERVER_MAX_AGE_SECONDS: getEnv()
                        .ART_EXPRESS_SERVER_MAX_AGE_SECONDS,
                      ART_EXPRESS_SERVER_MAX_SIZE_MB: getEnv()
                        .ART_EXPRESS_SERVER_MAX_SIZE_MB,
                      ART_EXPRESS_SERVER_VERBOSE: getEnv()
                        .ART_EXPRESS_SERVER_VERBOSE
                    }
                  ),
                  Neptune: Neptune.getVersions()
                }
              });
            };
            this.prototype._allowAllCors = function(options) {
              return options.allowAllCors
                ? merge(options, {
                    commonResponseHeaders: merge(
                      __webpack_require__(3).commonResponseHeaders,
                      options.commonResponseHeaders
                    ),
                    handlers: compactFlatten([
                      __webpack_require__(3),
                      options.handlers
                    ])
                  })
                : options;
            };
            this.prototype._initMonitors = function(server) {
              let ART_EXPRESS_SERVER_MAX_AGE_SECONDS,
                ART_EXPRESS_SERVER_MAX_SIZE_MB,
                maxAgeMs,
                maxAgeTimeString,
                checkMemory;
              ({
                ART_EXPRESS_SERVER_MAX_AGE_SECONDS,
                ART_EXPRESS_SERVER_MAX_SIZE_MB
              } = getEnv());
              if (ART_EXPRESS_SERVER_MAX_AGE_SECONDS) {
                ART_EXPRESS_SERVER_MAX_AGE_SECONDS =
                  ART_EXPRESS_SERVER_MAX_AGE_SECONDS | 0;
                maxAgeMs =
                  (1000 *
                    ART_EXPRESS_SERVER_MAX_AGE_SECONDS *
                    (0.9 + Math.random() * 0.2)) |
                  0;
                maxAgeTimeString =
                  ART_EXPRESS_SERVER_MAX_AGE_SECONDS <= 60
                    ? `${Caf.toString((maxAgeMs / 1000).toFixed(2))}s`
                    : ART_EXPRESS_SERVER_MAX_AGE_SECONDS <= 60 * 60
                      ? `${Caf.toString((maxAgeMs / 60000).toFixed(2))}m`
                      : `${Caf.toString(
                          (maxAgeMs / (60 * 60000)).toFixed(2)
                        )}h`;
                this.log(
                  `ART_EXPRESS_SERVER_MAX_AGE_SECONDS=${Caf.toString(
                    ART_EXPRESS_SERVER_MAX_AGE_SECONDS
                  )} -> shut down after ${Caf.toString(
                    maxAgeTimeString
                  )} (+/- 10% randomly)`.green
                );
                timeout(maxAgeMs).then(() => {
                  this.log(
                    `ART_EXPRESS_SERVER_MAX_AGE_SECONDS=${Caf.toString(
                      ART_EXPRESS_SERVER_MAX_AGE_SECONDS
                    )} -> shutting down: ${Caf.toString(
                      maxAgeTimeString
                    )} expired`.red
                  );
                  server.close();
                  return process.exit(0);
                });
              }
              return ART_EXPRESS_SERVER_MAX_SIZE_MB
                ? ((ART_EXPRESS_SERVER_MAX_SIZE_MB =
                    ART_EXPRESS_SERVER_MAX_SIZE_MB | 0),
                  this.log(
                    `ART_EXPRESS_SERVER_MAX_SIZE_MB=${Caf.toString(
                      ART_EXPRESS_SERVER_MAX_SIZE_MB
                    )} -> shut down when MemoryUsage(${Caf.toString(
                      (process.memoryUsage().rss / (1024 * 1024)) | 0
                    )}MB) > ${Caf.toString(
                      ART_EXPRESS_SERVER_MAX_SIZE_MB
                    )}MB (check every: ${Caf.toString(
                      (memoryCheckCycleMs / 1000) | 0
                    )}s)`.green
                  ),
                  timeout(
                    memoryCheckCycleMs,
                    (checkMemory = () => {
                      let rssMegabytes;
                      if (
                        ART_EXPRESS_SERVER_MAX_SIZE_MB <
                        (rssMegabytes =
                          (process.memoryUsage().rss / (1024 * 1024)) | 0)
                      ) {
                        this.log(
                          `ART_EXPRESS_SERVER_MAX_SIZE_MB=${Caf.toString(
                            ART_EXPRESS_SERVER_MAX_SIZE_MB
                          )} -> shutting down: MemoryUsage(${Caf.toString(
                            rssMegabytes
                          )}MB) > ${Caf.toString(
                            ART_EXPRESS_SERVER_MAX_SIZE_MB
                          )}. uptime: ${Caf.toString(this.uptime | 0)}s`.red
                        );
                        server.close();
                        process.exit(0);
                      } else {
                        this.logVerbose(
                          `ART_EXPRESS_SERVER_MAX_SIZE_MB=${Caf.toString(
                            ART_EXPRESS_SERVER_MAX_SIZE_MB
                          )} -> tested OK! MemoryUsage(${Caf.toString(
                            rssMegabytes
                          )}MB) <= ${Caf.toString(
                            ART_EXPRESS_SERVER_MAX_SIZE_MB
                          )}MB`.green
                        );
                      }
                      return timeout(memoryCheckCycleMs, checkMemory);
                    })
                  ))
                : undefined;
            };
            this.getter({
              uptime: function() {
                return currentSecond() - this.startTime;
              }
            });
            this.prototype._startOneServer = function(workerId) {
              let staticOptions,
                initWorker,
                port,
                handlers,
                postmiddleware,
                middleware,
                commonResponseHeaders,
                server;
              this.workerId = workerId;
              this.startTime = currentSecond();
              ({
                static: staticOptions,
                initWorker,
                port,
                handlers,
                postmiddleware,
                middleware,
                commonResponseHeaders
              } = this.options);
              this.app = __webpack_require__(10)();
              Caf.isF(initWorker) && initWorker(this);
              this.app.use(__webpack_require__(23)());
              if (Caf.is(middleware, Object)) {
                Caf.each(
                  compactFlatten([middleware]),
                  undefined,
                  (callback, path) => {
                    this.app.use(path, callback);
                  }
                );
              } else {
                if (middleware != null) {
                  Caf.each(compactFlatten([middleware]), undefined, mw => {
                    this.app.use(mw);
                  });
                }
              }
              Caf.each(compactFlatten([handlers]), undefined, handler => {
                this.app.use(handler.getMiddleware(this.options));
              });
              if (staticOptions) {
                this.app.use(
                  __webpack_require__(10).static(
                    staticOptions.root,
                    merge(
                      {
                        maxAge: 3600 * 24 * 7,
                        setHeaders: (response, path) => {
                          switch (__webpack_require__(24)
                            .extname(path)
                            .toLowerCase()) {
                            case ".js":
                              response.setHeader(
                                "Content-Type",
                                "application/javascript; charset=UTF-8"
                              );
                          }
                          return Caf.each(
                            merge(commonResponseHeaders, staticOptions.headers),
                            undefined,
                            (v, k) => {
                              response.setHeader(k, v);
                            }
                          );
                        }
                      },
                      staticOptions
                    )
                  )
                );
              }
              Caf.each(compactFlatten([postmiddleware]), undefined, mw => {
                this.app.use(mw);
              });
              server = this.app.listen(port | 0, () => {
                return this.log(
                  `listening on: http://localhost:${Caf.toString(port)}`
                );
              });
              return this._initMonitors(server);
            };
          }
        ))
      );
    }
  );
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

var ref, ref1;

module.exports = (ref = typeof Neptune !== "undefined" && Neptune !== null ? (ref1 = Neptune.Art) != null ? ref1.CommunicationStatus : void 0 : void 0) != null ? ref : __webpack_require__(16);


/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

var CommunicationStatus,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

module.exports = (__webpack_require__(17)).addNamespace('CommunicationStatus', CommunicationStatus = (function(superClass) {
  extend(CommunicationStatus, superClass);

  function CommunicationStatus() {
    return CommunicationStatus.__super__.constructor.apply(this, arguments);
  }

  CommunicationStatus.version = __webpack_require__(20).version;

  return CommunicationStatus;

})(Neptune.PackageNamespace));


/***/ }),
/* 9 */
/***/ (function(module, exports) {

module.exports = require("art-class-system");

/***/ }),
/* 10 */
/***/ (function(module, exports) {

module.exports = require("express");

/***/ }),
/* 11 */
/***/ (function(module, exports) {

module.exports = require("neptune-namespaces");

/***/ }),
/* 12 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  return __webpack_require__(18);
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 13 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  let process = global.process;
  return __webpack_require__(12).start({
    initWorker: function(server) {
      return process.env.ART_EXPRESS_SERVER_MAX_SIZE_MB
        ? Caf.importInvoke(
            ["timeout", "Array", "Math", "process"],
            [global, __webpack_require__(2)],
            (timeout, Array, Math, process) => {
              let makeItBig, alloc;
              return (
                (makeItBig = []),
                timeout(
                  1000,
                  (alloc = () => {
                    makeItBig.push(
                      new Array((1024 * 1024 * Math.random()) | 0)
                    );
                    server.log(
                      `simulating memory leak... (${Caf.toString(
                        (process.memoryUsage().rss / (1024 * 1024)) | 0
                      )}MB allocated)`.blue
                    );
                    return timeout(1000, alloc);
                  })
                )
              );
            }
          )
        : undefined;
    }
  });
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 14 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(module) {
let Caf = __webpack_require__(1);
Caf.defMod(module, () => {
  return __webpack_require__(6);
});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(0)(module)))

/***/ }),
/* 15 */
/***/ (function(module, exports) {

var CommunicationStatus;

module.exports = CommunicationStatus = (function() {
  var communicationStatuses, k, ref, v;

  function CommunicationStatus() {}

  CommunicationStatus.communicationStatuses = communicationStatuses = {

    /*
    status: success
    
    * An unqualified success.
    * I guess it could be qualified, with additional information in another field,
      but the 'expected' data should be present.
     */
    success: {
      httpStatus: 200

      /*
      status: missing
      
      * The request was properly formatted.
      * There were no network errors.
      * There were no server errors.
      * The only problem is the server could not find the requested resource.
       */
    },
    missing: {
      httpStatus: 404,
      failure: true

      /*
      status: clientFailure
      
      * The server rejected the request.
      * There is something wrong with the client's request.
      * It's up to the client to fix the problem.
      * This includes mal-formed requests as well as invalid data.
      * all 4xx errors except 404
      NOTE: 404 is not necessarilly a client NOR server error, therefor it's status: missing
       */
    },
    clientFailure: {
      httpStatus: 400,
      clientFailure: true,
      failure: true

      /*
      status: notAuthorized
      
      * The resource exists, but the client is not allowed to access it.
      
      This is a form of clientFailure because the client could possibly change
      something in the request to make it work.
       */
    },
    clientFailureNotAuthorized: {
      httpStatus: 403,
      clientFailure: true,
      failure: true

      /*
      status: serverFailure
      
      * There is something broken on the server.
      * There is nothing the client can do to solve this problem.
      
      SBD: Possble rename to 'internalFailure': Reason: so it also makes sense for local library calls.
        If something is failing in a local library, serverFailure makes less sense.
        Then again, local libraries pretty-much don't need communicationStatus at all - they
        can use 'throw' or 'promise.reject'
       */
    },
    serverFailure: {
      httpStatus: 500,
      failure: true,
      serverFailure: true

      /*
      status: networkFailure
      
      * The remote-server could not be reached.
      * There is nothing the code running on the Client NOR Server can do to fix this.
      * There is something wrong with the network between the client computer and the server.
      * The client can attempt to retry at a later time and it might magically work.
      * The client-side-humans or server-side-humans can attempt to fix the network.
      * The failure may be one of the following:
        a) the local computer has no internet connection OR
        b) the internet is in a shitstorm ;) OR
        c) there is an network problem within the Servers' facility.
       */
    },
    networkFailure: {
      failure: true

      /*
      status: aborted
      
      * the request was aborted, AS REQUESTED BY THE CLIENT
       */
    },
    aborted: {
      failure: true

      /*
      status: pending
      
      * The request is proceeding.
      * No errors so far.
       */
    },
    pending: {},

    /*
    status: failure
    
    Use when the same code is used clientSide and serverSide.
    
    Server code should convert :failure into :serverFailure when sending
    a failing reply to a client.
     */
    failure: {
      httpStatus: 500,
      failure: true
    }
  };

  ref = CommunicationStatus.communicationStatuses;
  for (k in ref) {
    v = ref[k];
    CommunicationStatus[k] = k;
  }

  CommunicationStatus.isClientFailure = function(status) {
    var ref1;
    return !!((ref1 = communicationStatuses[status]) != null ? ref1.clientFailure : void 0);
  };

  CommunicationStatus.isServerFailure = function(status) {
    var ref1;
    return !!((ref1 = communicationStatuses[status]) != null ? ref1.serverFailure : void 0);
  };

  CommunicationStatus.isFailure = function(status) {
    var ref1;
    return !!((ref1 = communicationStatuses[status]) != null ? ref1.failure : void 0);
  };

  CommunicationStatus.isSuccess = function(status) {
    return status === "success";
  };


  /*
  OUT: true if status is a valid status-string
   */

  CommunicationStatus.validStatus = function(status) {
    return CommunicationStatus[status] === status;
  };

  CommunicationStatus.decodeHttpStatus = function(httpStatus) {
    var status;
    if (httpStatus == null) {
      return {
        status: CommunicationStatus.networkFailure,
        message: "network failure"
      };
    }
    status = (function() {
      switch (httpStatus / 100 | 0) {
        case 2:
          return this.success;
        case 3:
          return this.missing;
        case 4:
          switch (httpStatus) {
            case 403:
              return this.clientFailureNotAuthorized;
            case 404:
              return this.missing;
            default:
              return this.clientFailure;
          }
          break;
        case 5:
          switch (httpStatus) {
            case 502:
            case 503:
            case 504:
              return this.networkFailure;
            case 501:
            case 505:
            case 530:
              return this.clientFailure;
            case 500:
              return this.serverFailure;
          }
      }
    }).call(CommunicationStatus);
    if (status == null) {
      throw new Error("unhandled httpStatus: " + httpStatus);
    }
    return {
      status: status,
      httpStatus: httpStatus,
      message: status + " (" + httpStatus + ")"
    };
  };

  CommunicationStatus.encodeHttpStatus = function(status) {
    var httpStatus, ref1;
    if (!(httpStatus = (ref1 = CommunicationStatus.communicationStatuses[status]) != null ? ref1.httpStatus : void 0)) {
      throw new Error("There is no valid HttpStatus for " + status + ".");
    }
    return httpStatus;
  };

  return CommunicationStatus;

})();


/***/ }),
/* 16 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(8);

module.exports.includeInNamespace(__webpack_require__(15));


/***/ }),
/* 17 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = (__webpack_require__(11)).vivifySubnamespace('Art');

__webpack_require__(8);


/***/ }),
/* 18 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(19);

module.exports.includeInNamespace(__webpack_require__(14)).addModules({
  AllowAllCorsHandler: __webpack_require__(3),
  LoggingMixin: __webpack_require__(4),
  PromiseHandler: __webpack_require__(5),
  Server: __webpack_require__(6)
});


/***/ }),
/* 19 */
/***/ (function(module, exports, __webpack_require__) {

var ExpressServer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

module.exports = (__webpack_require__(11)).addNamespace('Art.ExpressServer', ExpressServer = (function(superClass) {
  extend(ExpressServer, superClass);

  function ExpressServer() {
    return ExpressServer.__super__.constructor.apply(this, arguments);
  }

  ExpressServer.version = __webpack_require__(21).version;

  return ExpressServer;

})(Neptune.PackageNamespace));


/***/ }),
/* 20 */
/***/ (function(module, exports) {

module.exports = {"author":"Shane Brinkman-Davis Delamore, Imikimi LLC","dependencies":{"art-build-configurator":"*","art-class-system":"*","art-config":"*","art-standard-lib":"*","art-testbench":"*","bluebird":"^3.5.0","caffeine-script":"*","caffeine-script-runtime":"*","case-sensitive-paths-webpack-plugin":"^2.1.1","chai":"^4.0.1","coffee-loader":"^0.7.3","coffee-script":"^1.12.6","colors":"^1.1.2","commander":"^2.9.0","css-loader":"^0.28.4","dateformat":"^2.0.0","detect-node":"^2.0.3","fs-extra":"^3.0.1","glob":"^7.1.2","glob-promise":"^3.1.0","json-loader":"^0.5.4","mocha":"^3.4.2","neptune-namespaces":"*","script-loader":"^0.7.0","style-loader":"^0.18.1","webpack":"^2.6.1","webpack-dev-server":"^2.4.5","webpack-merge":"^4.1.0","webpack-node-externals":"^1.6.0"},"description":"Simplified system of statuses for HTTP and any other network protocol","license":"ISC","name":"art-communication-status","scripts":{"build":"webpack --progress","start":"webpack-dev-server --hot --inline --progress","test":"nn -s;mocha -u tdd --compilers coffee:coffee-script/register","testInBrowser":"webpack-dev-server --progress"},"version":"1.5.2"}

/***/ }),
/* 21 */
/***/ (function(module, exports) {

module.exports = {"author":"Shane Brinkman-Davis Delamore, Imikimi LLC","dependencies":{"art-build-configurator":"*","art-class-system":"*","art-config":"*","art-standard-lib":"*","art-testbench":"*","bluebird":"^3.5.0","caffeine-script":"*","caffeine-script-runtime":"*","case-sensitive-paths-webpack-plugin":"^2.1.1","chai":"^4.0.1","coffee-loader":"^0.7.3","coffee-script":"^1.12.6","colors":"^1.1.2","commander":"^2.9.0","compression":"^1.6.2","css-loader":"^0.28.4","dateformat":"^2.0.0","detect-node":"^2.0.3","express":"^4.15.3","fs-extra":"^3.0.1","glob":"^7.1.2","glob-promise":"^3.1.0","json-loader":"^0.5.4","jsonwebtoken":"^7.4.1","mocha":"^3.4.2","neptune-namespaces":"*","script-loader":"^0.7.0","style-loader":"^0.18.1","throng":"^4.0.0","webpack":"^2.6.1","webpack-dev-server":"^2.4.5","webpack-merge":"^4.1.0","webpack-node-externals":"^1.6.0"},"description":"Extensible, Promise-based HTTP Server based on Express","license":"ISC","name":"art-express-server","scripts":{"build":"webpack --progress","start":"webpack-dev-server --hot --inline --progress","test":"nn -s;mocha -u tdd --compilers coffee:coffee-script/register","testInBrowser":"webpack-dev-server --progress","testServer":"caf ./TestServer"},"version":"0.6.1"}

/***/ }),
/* 22 */
/***/ (function(module, exports) {

module.exports = require("colors");

/***/ }),
/* 23 */
/***/ (function(module, exports) {

module.exports = require("compression");

/***/ }),
/* 24 */
/***/ (function(module, exports) {

module.exports = require("path");

/***/ }),
/* 25 */
/***/ (function(module, exports) {

module.exports = require("querystring");

/***/ }),
/* 26 */
/***/ (function(module, exports) {

module.exports = require("throng");

/***/ })
/******/ ]);