// Generated by CoffeeScript 1.12.7
(function() {
  var CommunicationStatus, Promise, Request, RequestError, Response, Validator, alignTabs, arrayWith, arrayWithoutLast, cleanStackTrace, clientFailure, clone, compactFlatten, config, currentSecond, failure, formattedInspect, getCleanStackTraceWarning, getDetailedRequestTracingEnabled, getDetailedRequestTracingExplanation, getEnv, inspect, isJsonType, isNode, isPlainArray, isPlainObject, log, merge, missing, namespace, neq, object, objectHasKeys, objectKeyCount, objectWithout, peek, pureMerge, ref, responseValidator, serverFailure, success, w,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('./StandardImport'), objectHasKeys = ref.objectHasKeys, clone = ref.clone, currentSecond = ref.currentSecond, objectWithout = ref.objectWithout, arrayWithoutLast = ref.arrayWithoutLast, pureMerge = ref.pureMerge, Promise = ref.Promise, compactFlatten = ref.compactFlatten, object = ref.object, peek = ref.peek, isPlainArray = ref.isPlainArray, objectKeyCount = ref.objectKeyCount, arrayWith = ref.arrayWith, inspect = ref.inspect, RequestError = ref.RequestError, isPlainObject = ref.isPlainObject, log = ref.log, CommunicationStatus = ref.CommunicationStatus, merge = ref.merge, isJsonType = ref.isJsonType, formattedInspect = ref.formattedInspect, w = ref.w, neq = ref.neq, success = ref.success, missing = ref.missing, failure = ref.failure, serverFailure = ref.serverFailure, clientFailure = ref.clientFailure, Validator = ref.Validator, alignTabs = ref.alignTabs, isNode = ref.isNode, getDetailedRequestTracingEnabled = ref.getDetailedRequestTracingEnabled, getDetailedRequestTracingExplanation = ref.getDetailedRequestTracingExplanation, getEnv = ref.getEnv, cleanStackTrace = ref.cleanStackTrace, getCleanStackTraceWarning = ref.getCleanStackTraceWarning;

  Request = require('./Request');

  config = require('./Config').config;

  namespace = require('./namespace');

  responseValidator = new Validator({
    request: w("required", {
      "instanceof": Request
    }),
    status: w("required communicationStatus"),
    session: "object",
    props: "object"
  });


  /*
  TODO: Merge Response back into Request
  
    Turns out, Response has very little special functionality.
    At this point, the RequestuestResponseBase / Request / Response class structure
    actually requires more code than just one, Request class would.
  
  What to add to Request:
  
    @writeOnceProperty "responseStatus responseSession responseProps"
  
    @getter
      hasResponse: -> !!@responseStatus
  
    Split out: filterLog into beforeFilterLog and afterFilterLog.
   */


  /*
  new Response
  
  IN:
    request: Request (required)
    status: CommunicationStatus (required)
    props: plainObject with all JSON values
    session: plainObject with all JSON values
  
    data: JSON value
      data is an alias for @props.data
      EFFECT: replaces @props.data
      NOTE: for clientRequest, @props.data is the value returned unless returnResponse/returnResponseObject is requested
  
    remoteRequest: remoteResponse:
      Available for inspecting what exactly went over-the-wire.
      Otherwise ignored by Response
   */

  module.exports = Response = (function(superClass) {
    extend(Response, superClass);

    function Response(options) {
      var ref1;
      Response.__super__.constructor.call(this, merge(options, {
        creationStack: options.request.creationStack
      }));
      responseValidator.validate(options, {
        context: "Art.Ery.Response options",
        logErrors: true
      });
      this.request = options.request, this.status = options.status, this.props = (ref1 = options.props) != null ? ref1 : {}, this.session = options.session, this.remoteRequest = options.remoteRequest, this.remoteResponse = options.remoteResponse;
      if (options.requestOptions) {
        throw new Error("options.requestOptions is DEPRICATED - use options.props");
      }
      if (options.data != null) {
        this._props.data = options.data;
      }
      if (this._session == null) {
        this._session = neq(this.request.session, this.request.originalRequest.session) ? this.request.session : void 0;
      }
      this._endTime = null;
      if (this.type === "create" || this.type === "get") {
        this.setGetCache();
      }
    }

    Response.prototype.isResponse = true;

    Response.property("request props session remoteResponse remoteRequest");

    Response.setter("status");

    Response.getter({
      status: function() {
        if (this._status === failure) {
          switch (this.location) {
            case "server":
              return serverFailure;
            case "client":
              return clientFailure;
          }
        }
        return this._status;
      },
      failed: function() {
        return this._status === failure || this._status === serverFailure;
      },
      data: function() {
        return this._props.data;
      },
      session: function() {
        var ref1;
        return (ref1 = this._session) != null ? ref1 : this.request.session;
      },
      responseData: function() {
        return this._props.data;
      },
      responseProps: function() {
        return this._props;
      },
      responseSession: function() {
        return this._session;
      },
      beforeFilterLog: function() {
        return this.request.filterLog || [];
      },
      handledBy: function() {
        return !this.failed && peek(this.request.filterLog);
      },
      rawRequestLog: function() {
        return compactFlatten([this.beforeFilterLog, this.afterFilterLog]);
      },
      requestLog: function() {
        var endTime, firstTime, lastProps, lastTime, name, out, ref1, startTime, time;
        ref1 = this, startTime = ref1.startTime, endTime = ref1.endTime;
        firstTime = lastTime = startTime;
        lastProps = null;
        out = (function() {
          var j, len, ref2, ref3, results;
          ref2 = this.rawRequestLog;
          results = [];
          for (j = 0, len = ref2.length; j < len; j++) {
            ref3 = ref2[j], name = ref3.name, time = ref3.time;
            if (firstTime == null) {
              firstTime = lastTime = time;
            }
            if (lastProps != null) {
              lastProps.deltaMs = (time - lastTime) * 1000 | 0;
            }
            lastProps = {
              name: name,
              timeMs: 0,
              wallMs: (time - firstTime) * 1000 | 0
            };
            lastTime = time;
            results.push(lastProps);
          }
          return results;
        }).call(this);
        log({
          startTime: startTime,
          lastTime: lastTime,
          _endTime: this._endTime
        });
        if (lastProps != null) {
          lastProps.deltaMs = (endTime - lastTime) * 1000 | 0;
        }
        return out;
      },
      afterFilterLog: function() {
        return this._filterLog || [];
      },
      isSuccessful: function() {
        return this._status === success;
      },
      isMissing: function() {
        return this._status === missing;
      },
      notSuccessful: function() {
        return this._status !== success;
      },
      description: function() {
        return this.requestString + ": " + this.status;
      },
      propsForClone: function() {
        return {
          request: this.request,
          status: this.status,
          props: this.props,
          session: this._session,
          filterLog: this._filterLog,
          remoteRequest: this.remoteRequest,
          remoteResponse: this.remoteResponse,
          errorProps: this.errorProps
        };
      },
      propsForResponse: function() {
        return this.propsForClone;
      },
      summary: function() {
        return {
          response: merge({
            status: this.status,
            props: this.props,
            errorProps: this.errorProps
          })
        };
      },
      plainObjectsResponse: function(fields) {
        return object(fields || {
          status: this.status,
          props: this.props,
          beforeFilterLog: this.beforeFilterLog,
          afterFilterLog: this.afterFilterLog,
          session: this._session
        }, {
          when: function(v) {
            switch (false) {
              case !isPlainObject(v):
                return objectKeyCount(v) > 0;
              case !isPlainArray(v):
                return v.length > 0;
              default:
                return v !== void 0;
            }
          }
        });
      },
      responseForRemoteRequest: function() {
        return this.getPlainObjectsResponse(!config.returnProcessingInfoToClient ? {
          status: this.status,
          props: this.props,
          session: this._session
        } : void 0);
      }
    });

    Response.prototype.withMergedSession = function(session) {
      return Promise.resolve(session).then((function(_this) {
        return function(session) {
          return new _this["class"](merge(_this.propsForClone, {
            session: merge(_this.session, session)
          }));
        };
      })(this));
    };


    /*
    IN: options:
      returnNullIfMissing: true [default: false]
        if status == missing
          if returnNullIfMissing
            promise.resolve null
          else
            promise.reject new RequestError
    
      returnResponse: true [default: false]
      returnResponseObject: true (alias)
        if true, the response object is returned, otherwise, just the data field is returned.
    
    OUT:
       * if response.isSuccessful && returnResponse == true
      promise.then (response) ->
    
       * if response.isSuccessful && returnResponse == false
      promise.then (data) ->
    
       * if response.isMissing && returnNullIfMissing == true
      promise.then (data) -> # data == null
    
       * else
      promise.catch (errorWithInfo) ->
        {response} = errorWithInfo.info
     */

    Response.prototype.toPromise = function(options) {
      var data, isMissing, isSuccessful, ref1, returnNullIfMissing, returnResponse, returnResponseObject;
      if (options) {
        returnNullIfMissing = options.returnNullIfMissing, returnResponse = options.returnResponse, returnResponseObject = options.returnResponseObject;
      }
      ref1 = this, data = ref1.data, isSuccessful = ref1.isSuccessful, isMissing = ref1.isMissing;
      returnResponse || (returnResponse = returnResponseObject);
      if (isMissing && returnNullIfMissing) {
        data = null;
        isSuccessful = true;
      }
      if (isSuccessful) {
        return Promise.resolve(returnResponse ? this : data);
      } else {
        return Promise.reject(this._getRejectionError());
      }
    };

    Response.prototype._getRejectionError = function() {
      var context, exception, filterLog, i, name, ref1, ref2, ref3, ref4, ref5, ref6, ref7, request, stack, time;
      return this._preparedRejectionError || (this._preparedRejectionError = new RequestError({
        message: compactFlatten([
          (ref1 = (ref2 = (ref3 = this.responseData) != null ? ref3.message : void 0) != null ? ref2 : (ref4 = this.responseProps) != null ? ref4.message : void 0) != null ? ref1 : (ref5 = this.errorProps) != null ? (ref6 = ref5.exception) != null ? ref6.message : void 0 : void 0, "", "request: " + this.pipeline + "." + this.type, formattedInspect({
            status: this.status,
            session: this.session,
            props: this.requestProps
          })
        ]).join("\n"),
        type: this.type,
        status: this.status,
        requestData: this.requestData,
        responseData: this.responseData,
        sourceLib: "ArtEry",
        response: this,
        stack: compactFlatten([
          (exception = (ref7 = this.errorProps) != null ? ref7.exception : void 0) ? "Exception stack:\n" + (cleanStackTrace(exception.stack, false, true)) + "\n" : void 0, ((function() {
            var j, ref8, ref9, results;
            ref8 = this.requestTrace;
            results = [];
            for (i = j = ref8.length - 1; j >= 0; i = j += -1) {
              ref9 = ref8[i], time = ref9.time, request = ref9.request, context = ref9.context, name = ref9.name, stack = ref9.stack, filterLog = ref9.filterLog;
              results.push(request + ": " + (filterLog != null ? ((function() {
                var k, len, results1;
                results1 = [];
                for (k = 0, len = filterLog.length; k < len; k++) {
                  name = filterLog[k].name;
                  if (name !== "created") {
                    results1.push(name);
                  }
                }
                return results1;
              })()).join(" -> ") : context + " " + name) + " (request-depth: " + (i + 1) + ", start-time: " + (time * 1000 | 0) + "ms) " + (stack ? "\n" + (cleanStackTrace(stack, null, true)) + "\n" : ''));
            }
            return results;
          }).call(this)).join("\n"), getDetailedRequestTracingExplanation(), getCleanStackTraceWarning()
        ]).join("\n")
      }));
    };

    return Response;

  })(require('./RequestResponseBase'));

}).call(this);

//# sourceMappingURL=Response.js.map