// Generated by CoffeeScript 1.12.7
(function() {
  var ArtEry, ArtEryBaseObject, Promise, RequestResponseBase, array, arrayWith, clientFailure, clientFailureNotAuthorized, compactFlatten, config, currentSecond, dashCase, defineModule, failure, formattedInspect, getDetailedRequestTracingEnabled, getEnv, inspect, inspectedObjectLiteral, isArray, isClientFailure, isFunction, isJsonType, isPlainObject, isPromise, isString, log, merge, mergeWithoutNulls, missing, networkFailure, object, objectKeyCount, objectWithDefinedValues, objectWithout, peek, present, ref, ref1, serverFailure, success, timeout, toInspectedObjects,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('./StandardImport'), timeout = ref.timeout, currentSecond = ref.currentSecond, log = ref.log, arrayWith = ref.arrayWith, mergeWithoutNulls = ref.mergeWithoutNulls, defineModule = ref.defineModule, merge = ref.merge, isJsonType = ref.isJsonType, isString = ref.isString, isPlainObject = ref.isPlainObject, isArray = ref.isArray, inspect = ref.inspect, inspectedObjectLiteral = ref.inspectedObjectLiteral, toInspectedObjects = ref.toInspectedObjects, formattedInspect = ref.formattedInspect, Promise = ref.Promise, object = ref.object, isFunction = ref.isFunction, objectWithDefinedValues = ref.objectWithDefinedValues, objectWithout = ref.objectWithout, array = ref.array, isPromise = ref.isPromise, compactFlatten = ref.compactFlatten, objectKeyCount = ref.objectKeyCount, present = ref.present, peek = ref.peek, dashCase = ref.dashCase, getEnv = ref.getEnv, getDetailedRequestTracingEnabled = ref.getDetailedRequestTracingEnabled;

  ArtEry = require('./namespace');

  ArtEryBaseObject = require('./ArtEryBaseObject');

  ref1 = require('art-communication-status'), networkFailure = ref1.networkFailure, failure = ref1.failure, isClientFailure = ref1.isClientFailure, success = ref1.success, missing = ref1.missing, serverFailure = ref1.serverFailure, clientFailure = ref1.clientFailure, clientFailureNotAuthorized = ref1.clientFailureNotAuthorized;

  config = require('./Config').config;


  /*
  TODO: merge reponse and request into one object
  
  TODO: Work towards the concept of "oldData" - sometimes we need to know
   the oldData when updating. Specifically, ArtEryPusher needs to know the oldData
   to notify clients if a record is removed from one query and added to another.
   Without oldData, there is no way of knowing what old query it was removed from.
   In this case, either a) the client needs to send the oldData to the server of b)
   we need to fetch the oldData before overwriting it - OR we need to us returnValues: "allOld".
  
   Too bad there isn't a way to return BOTH the old and new fields with DynamoDb.
  
   Not sure if ArtEry needs any special code for "oldData." It'll probably be a convention
   that ArtEryAws and ArtEryPusher conform to. It's just a props from ArtEry's POV.
   */

  defineModule(module, RequestResponseBase = (function(superClass) {
    var cachedGet, createRequirementNotMetRequestProps, defaultWhenTest, resolveRequireTestValue;

    extend(RequestResponseBase, superClass);

    function RequestResponseBase(options) {
      RequestResponseBase.__super__.constructor.apply(this, arguments);
      this._creationTime = currentSecond();
      this.filterLog = options.filterLog, this.errorProps = options.errorProps, this.creationStack = options.creationStack;
      if (getDetailedRequestTracingEnabled()) {
        if (this._creationStack == null) {
          this._creationStack = (new Error).stack;
        }
      }
    }

    RequestResponseBase.property("filterLog errorProps creationTime creationStack");

    RequestResponseBase.prototype.addFilterLog = function(filter, context) {
      var ref2, ref3;
      this._filterLog = arrayWith(this._filterLog, {
        name: isString(filter) ? filter : filter.getLogName(this.type),
        context: context,
        time: currentSecond(),
        stack: (ref2 = this.originalRequest) != null ? ref2.creationStack : void 0,
        exception: (ref3 = this.errorProps) != null ? ref3.exception : void 0
      });
      return this;
    };

    RequestResponseBase.getter({
      lastFilterLogEntry: function() {
        var ref2, ref3;
        return (ref2 = peek(this.filterLog)) != null ? ref2 : (ref3 = this.request) != null ? ref3.lastFilterLogEntry : void 0;
      },
      requestTrace: function() {
        var context, exception, lastFilter, name, ref2, stack, time;
        if (lastFilter = this.lastFilterLogEntry) {
          name = lastFilter.name, context = lastFilter.context, time = lastFilter.time, stack = lastFilter.stack, exception = lastFilter.exception;
        }
        return compactFlatten([
          (ref2 = this.parentRequest) != null ? ref2.requestTrace : void 0, {
            time: time - this.startTime,
            request: this.requestString,
            context: dashCase(context),
            filterLog: compactFlatten([this.beforeFilterLog, this.afterFilterLog]),
            name: name,
            stack: stack,
            exception: exception
          }
        ]);
      },
      verbose: function() {
        var ref2, ref3;
        return this._verbose || ((ref2 = this.originalRequest) != null ? ref2._verbose : void 0) || ((ref3 = this.rootRequest) != null ? ref3._verbose : void 0);
      },
      location: function() {
        return this.pipeline.location;
      },
      requestType: function() {
        return this.type;
      },
      pipelineName: function() {
        return this.pipeline.getName();
      },
      requestDataWithKey: function() {
        return merge(this.requestData, this.keyObject);
      },
      keyObject: function() {
        return this.request.pipeline.toKeyObject(this.key);
      },
      rootRequest: function() {
        var ref2;
        return ((ref2 = this.parentRequest) != null ? ref2.rootRequest : void 0) || this.request;
      },
      originalRequest: function() {
        var ref2;
        return (ref2 = this._originalRequest) != null ? ref2 : this.request.originalRequest;
      },
      startTime: function() {
        return this.rootRequest.creationTime;
      },
      endTime: function() {
        return this.creationTime;
      },
      wallTime: function() {
        return this.startTime - this.endTime;
      },
      requestChain: function() {
        var ref2;
        return compactFlatten([this.isResponse ? this.request.requestChain : (ref2 = this.parentRequest) != null ? ref2.requestChain : void 0, this]);
      },
      simpleInspectedObjects: function() {
        var obj, props;
        props = objectWithout(this.props, "key", "data");
        if (!(0 < objectKeyCount(props))) {
          props = null;
        }
        return toInspectedObjects(object((
          obj = {},
          obj["" + this["class"].name] = this.requestString,
          obj.originatedOnServer = this.originatedOnServer,
          obj.data = this.data,
          obj.status = this.status,
          obj.props = props,
          obj.errorProps = this.errorProps,
          obj
        ), {
          when: function(v) {
            return v != null;
          }
        }));
      },
      inspectedObjects: function() {
        var obj, request;
        return (
          obj = {},
          obj["Art.Ery." + this["class"].name] = (function() {
            var i, len, ref2, results;
            ref2 = this.requestChain;
            results = [];
            for (i = 0, len = ref2.length; i < len; i++) {
              request = ref2[i];
              results.push(request.simpleInspectedObjects);
            }
            return results;
          }).call(this),
          obj
        );
      }
    });

    RequestResponseBase.getter({
      isSuccessful: function() {
        return true;
      },
      isFailure: function() {
        return this.notSuccessful;
      },
      notSuccessful: function() {
        return false;
      },
      requestSession: function() {
        return this.request.session;
      },
      requestProps: function() {
        return this.request.requestProps;
      },
      requestData: function() {
        return this.request.requestData;
      },
      isRootRequest: function() {
        return this.request.isRootRequest;
      },
      key: function() {
        var ref2;
        return this.request.key || ((ref2 = this.responseData) != null ? ref2.id : void 0);
      },
      pipeline: function() {
        return this.request.pipeline;
      },
      parentRequest: function() {
        return this.request.parentRequest;
      },
      isSubrequest: function() {
        return !!this.request.parentRequest;
      },
      type: function() {
        return this.request.type;
      },
      originatedOnServer: function() {
        return this.request.originatedOnServer;
      },
      context: function() {
        return this.request.context;
      },
      pipelineAndType: function() {
        return this.pipelineName + "." + this.type;
      },
      requestString: function() {
        if (this.key) {
          return this.pipelineAndType + (" " + (formattedInspect(this.key)));
        } else {
          return this.pipelineAndType;
        }
      },
      description: function() {
        return this.requestString;
      },
      requestPathArray: function(into) {
        var localInto, parentRequest;
        localInto = into || [];
        parentRequest = this.parentRequest;
        if (parentRequest) {
          parentRequest.getRequestPathArray(localInto);
        }
        localInto.push(this);
        return localInto;
      },
      requestPath: function() {
        var r;
        return ((function() {
          var i, len, ref2, results;
          ref2 = this.requestPathArray;
          results = [];
          for (i = 0, len = ref2.length; i < len; i++) {
            r = ref2[i];
            results.push(r.requestString);
          }
          return results;
        }).call(this)).join(' >> ');
      }
    });

    RequestResponseBase.prototype.toStringCore = function() {
      return "ArtEry." + (this.isResponse ? 'Response' : 'Request') + " " + this.pipelineName + "." + this.type + (this.key ? " key: " + this.key : '');
    };

    RequestResponseBase.prototype.toString = function() {
      return "<" + (this.toStringCore()) + ">";
    };

    RequestResponseBase.getter({
      requestCache: function() {
        var base;
        return (base = this.context).requestCache || (base.requestCache = {});
      },
      subrequestCount: function() {
        var base;
        return (base = this.context).subrequestCount || (base.subrequestCount = 0);
      }
    });

    RequestResponseBase.setter({
      responseProps: function() {
        throw new Error("cannot set responseProps");
      }
    });

    RequestResponseBase.prototype.incrementSubrequestCount = function() {
      return this.context.subrequestCount = (this.context.subrequestCount | 0) + 1;
    };


    /*
    TODO:
      I think I may have a way clean up the subrequest API and do
      what is easy in Ruby: method-missing.
    
      Here's the new API:
         * request on the same pipeline
        request.pipeline.requestType requestOptions
    
         * request on another pipeline
        request.pipelines.otherPipelineName.requestType requestOptions
    
      Here's how:
        .pipeline and .pipelines are getters
        And the return proxy objects, generated and cached on the fly.
    
      Alt API idea:
         * same pipeline
        request.subrequest.requestType
    
         * other pipelines
        request.crossSubrequest.user.requestType
    
        I kinda like this more because it makes it clear we are talking
        sub-requests. This is just a ALIASes to the API above.
     */

    RequestResponseBase.prototype.createSubRequest = function(pipelineName, type, requestOptions) {
      var pipeline, ref2;
      if (requestOptions && !isPlainObject(requestOptions)) {
        throw new Error("requestOptions must be an object");
      }
      pipeline = ArtEry.pipelines[pipelineName];
      if (!pipeline) {
        throw new Error("Pipeline not registered: " + (formattedInspect(pipelineName)));
      }
      return new ArtEry.Request(merge({
        originatedOnServer: (ref2 = requestOptions != null ? requestOptions.originatedOnServer : void 0) != null ? ref2 : true
      }, requestOptions, {
        type: type,
        pipeline: pipeline,
        verbose: this.verbose,
        session: (requestOptions != null ? requestOptions.session : void 0) || this.session,
        parentRequest: this.request,
        context: this.context
      }));
    };

    RequestResponseBase.prototype.subrequest = function(pipelineName, type, requestOptions, b) {
      var promise, ref2, subrequest;
      if (isString(requestOptions)) {
        requestOptions = merge(b, {
          key: requestOptions
        });
      }
      pipelineName = pipelineName.pipelineName || pipelineName;
      subrequest = this.createSubRequest(pipelineName, type, requestOptions);
      this.incrementSubrequestCount();
      promise = subrequest.pipeline._processRequest(subrequest).then((function(_this) {
        return function(response) {
          return response.toPromise(requestOptions);
        };
      })(this));
      if (type === "update" && !(requestOptions != null ? (ref2 = requestOptions.props) != null ? ref2.returnValues : void 0 : void 0) && isString(subrequest.key)) {
        this._getPipelineTypeCache(pipelineName, type)[subrequest.key] = promise;
      }
      return promise;
    };

    RequestResponseBase.prototype.nonblockingSubrequest = function(pipelineName, type, requestOptions) {
      this.subrequest(pipelineName, type, requestOptions).then((function(_this) {
        return function(result) {
          if (config.verbose) {
            return log({
              ArtEry: {
                RequestResponseBase: {
                  nonblockingSubrequest: {
                    status: "success",
                    pipelineName: pipelineName,
                    type: type,
                    requestOptions: requestOptions,
                    parentRequest: {
                      pipelineName: _this.pipelineName,
                      type: _this.type,
                      key: _this.key
                    },
                    result: result
                  }
                }
              }
            });
          }
        };
      })(this))["catch"]((function(_this) {
        return function(error) {
          return log({
            ArtEry: {
              RequestResponseBase: {
                nonblockingSubrequest: {
                  status: "failure",
                  pipelineName: pipelineName,
                  type: type,
                  requestOptions: requestOptions,
                  parentRequest: {
                    pipelineName: _this.pipelineName,
                    type: _this.type,
                    key: _this.key
                  },
                  error: error
                }
              }
            }
          });
        };
      })(this));
      return Promise.resolve();
    };

    RequestResponseBase.prototype._getPipelineTypeCache = function(pipelineName, type) {
      var base, base1;
      return (base = ((base1 = this.requestCache)[pipelineName] || (base1[pipelineName] = {})))[type] || (base[type] = {});
    };

    RequestResponseBase.prototype.cachedSubrequest = function(pipelineName, requestType, keyOrRequestProps, d) {
      if (d !== void 0) {
        throw new Error("DEPRICATED: 4-param cachedSubrequest");
      }
      return this._cachedSubrequest(pipelineName, requestType, requestType, keyOrRequestProps);
    };

    RequestResponseBase.prototype._cachedSubrequest = function(pipelineName, cacheType, requestType, keyOrRequestProps) {
      var base, key;
      key = isString(keyOrRequestProps) ? keyOrRequestProps : keyOrRequestProps.key;
      if (!isString(key)) {
        throw new Error("_cachedSubrequest: key must be a string (" + (formattedInspect({
          key: key
        })) + ")");
      }
      return (base = this._getPipelineTypeCache(pipelineName, cacheType))[key] || (base[key] = this.subrequest(pipelineName, requestType, keyOrRequestProps)["catch"]((function(_this) {
        return function(error) {
          if (error.status === networkFailure && requestType === "get") {
            return timeout(20 + 10 * Math.random()).then(function() {
              return _this.subrequest(pipelineName, requestType, keyOrRequestProps);
            });
          } else {
            throw error;
          }
        };
      })(this)));
    };

    RequestResponseBase.prototype.setGetCache = function() {
      if (this.status === success && present(this.key) && (this.responseData != null)) {
        return this._getPipelineTypeCache(this.pipelineName, "get")[this.key] = Promise.then((function(_this) {
          return function() {
            return _this.responseData;
          };
        })(this));
      }
    };

    RequestResponseBase.prototype.cachedGet = cachedGet = function(pipelineName, key) {
      if (isPlainObject(key)) {
        key = ArtEry.pipelines[pipelineName].dataToKeyString(key);
      }
      if (!isString(key)) {
        throw new Error("cachedGet: key must be a string OR object when pipeline supports dataToKeyString (" + (formattedInspect({
          key: key
        })) + ")");
      }
      return this.cachedSubrequest(pipelineName, "get", key);
    };

    RequestResponseBase.prototype.cachedGetWithoutInclude = function(pipelineName, key) {
      if (!isString(key)) {
        throw new Error("cachedGetWithoutInclude: key must be a string (" + (formattedInspect({
          key: key
        })) + ")");
      }
      return this._getPipelineTypeCache(pipelineName, "get")[key] || this._cachedSubrequest(pipelineName, "get-no-include", "get", {
        key: key,
        props: {
          include: false
        }
      });
    };

    RequestResponseBase.prototype.cachedPipelineGet = cachedGet;

    RequestResponseBase.prototype.cachedGetIfExists = function(pipelineName, key) {
      if (key == null) {
        return Promise.resolve(null);
      }
      return this.cachedGet(pipelineName, key)["catch"](function(error) {
        if (error.status === missing) {
          return Promise.resolve(null);
        } else {
          throw error;
        }
      });
    };


    /* rejectIfErrors: success unless errors?
      IN:   errors: null, string or array of strings
      OUT:  Promise
    
        if errors?
          Promise.reject clientFailure with message based on errors
        else
          Promise.resolve request
     */

    createRequirementNotMetRequestProps = function(pipelineAndType, errors, stackException) {
      var data;
      return {
        data: data = {
          details: compactFlatten([pipelineAndType, 'requirement not met', errors]).join(' - '),
          message: "Request requirement not met: " + compactFlatten([errors]).join(' - ')
        },
        errorProps: getDetailedRequestTracingEnabled() ? {
          exception: stackException != null ? stackException : new Error(data.message)
        } : void 0
      };
    };

    RequestResponseBase.prototype.rejectIfErrors = function(errors, stackException) {
      if (errors) {
        return this.clientFailure(createRequirementNotMetRequestProps(this.pipelineAndType, errors, stackException)).then(function(response) {
          return response.toPromise();
        });
      } else {
        return Promise.resolve(this);
      }
    };

    RequestResponseBase.prototype.rejectNotAuthorizedIfErrors = function(errors) {
      if (errors) {
        return this.clientFailureNotAuthorized(createRequirementNotMetRequestProps(this.pipelineAndType, errors)).then(function(response) {
          return response.toPromise();
        });
      } else {
        return Promise.resolve(this);
      }
    };

    RequestResponseBase._resolveRequireTestValue = resolveRequireTestValue = function(testValue) {
      if (isFunction(testValue)) {
        testValue = testValue();
      }
      return Promise.resolve(testValue);
    };


    /* require: Success if !!test
      OUT: see @rejectIfErrors
    
      EXAMPLE: request.require myLegalInputTest, "myLegalInputTest"
     */

    RequestResponseBase.prototype.require = function(test, context) {
      var stackException;
      if (getDetailedRequestTracingEnabled()) {
        stackException = new Error(context);
      }
      return resolveRequireTestValue(test).then((function(_this) {
        return function(test) {
          return _this.rejectIfErrors(!test ? context != null ? context : [] : void 0, stackException);
        };
      })(this));
    };


    /* requiredFields
      Success if all props in fields exists (are not null or undefined)
    
      IN: fields (object)
      OUT-SUCCESS: fields
    
      OUT-REJECTED: see @rejectIfErrors
    
      EXAMPLE:
         * CaffeineScript's Object-Restructuring makes this particularly nice
        request.requiredFields
          {foo, bar} = request.data # creates a new object with just foo and bar fields
     */

    RequestResponseBase.prototype.requiredFields = function(fields, context) {
      var k, missingFields, v;
      missingFields = null;
      for (k in fields) {
        v = fields[k];
        if (v == null) {
          (missingFields != null ? missingFields : missingFields = []).push(k);
        }
      }
      return this.rejectIfErrors(missingFields ? ["missing fields: " + missingFields.join(", "), context] : void 0).then(function() {
        return fields;
      });
    };


    /* rejectIf: Success if !test
      OUT: see @rejectIfErrors
    
      EXAMPLE: request.rejectIf !myLegalInputTest, "myLegalInputTest"
     */

    RequestResponseBase.prototype.rejectIf = function(testValue, context) {
      return resolveRequireTestValue(testValue).then((function(_this) {
        return function(testValue) {
          return _this.require(!testValue, context);
        };
      })(this));
    };


    /* requireServerOrigin: Success if @originatedOnServer
      OUT: see @rejectIfErrors
    
      EXAMPLE: request.requireServerOrigin "to use myServerOnlyFeature"
     */

    RequestResponseBase.prototype.requireServerOrigin = function(context) {
      return this.requireServerOriginOr(false, context);
    };


    /* requireServerOriginOr: Success if testValue or @originatedOnServer
      OUT: see @rejectIfErrors
    
      EXAMPLE: request.requireServerOriginOr admin, "to use myAdminFeature"
     */

    RequestResponseBase.prototype.requireServerOriginOr = function(testValue, context) {
      if (this.originatedOnServer) {
        return Promise.resolve(this);
      }
      return resolveRequireTestValue(testValue).then((function(_this) {
        return function(testValue) {
          return _this.rejectNotAuthorizedIfErrors(!testValue ? "originatedOnServer required " + ((context != null ? context.match(/\s*to\s/) : void 0) ? context : context ? "to " + context : '') : void 0);
        };
      })(this));
    };


    /* requireServerOriginIf: Success if !testValue or @originatedOnServer
      OUT: see @rejectIfErrors
    
      EXAMPLE: request.requireServerOriginIf clientAuthorized, "to use myFeature"
     */

    RequestResponseBase.prototype.requireServerOriginIf = function(testValue, context) {
      if (this.originatedOnServer) {
        return Promise.resolve(this);
      }
      return resolveRequireTestValue(testValue).then((function(_this) {
        return function(testValue) {
          return _this.requireServerOriginOr(!testValue, context);
        };
      })(this));
    };

    RequestResponseBase.prototype["with"] = function(constructorOptions) {
      return Promise.resolve(constructorOptions).then((function(_this) {
        return function(constructorOptions) {
          return _this._with(constructorOptions);
        };
      })(this));
    };

    RequestResponseBase.prototype._with = function(o) {
      return new this["class"](merge(this.propsForClone, o));
    };


    /*
    IN: data can be a plainObject or a promise returning a plainObject
    OUT: promise.then (new request or response instance) ->
    
    withData:           new instance has @data replaced by `data`
    withMergedData:     new instance has @data merged with `data`
    withSession:        new instance has @session replaced by `session`
    withMergedSession:  new instance has @session merged with `session`
     */

    RequestResponseBase.prototype.withData = function(data) {
      return Promise.resolve(data).then((function(_this) {
        return function(data) {
          return _this._with({
            data: data
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withMergedData = function(data) {
      return Promise.resolve(data).then((function(_this) {
        return function(data) {
          return _this._with({
            data: merge(_this.data, data)
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withKey = function(data) {
      return Promise.resolve(data).then((function(_this) {
        return function(key) {
          return _this._with({
            key: key
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withProps = function(props) {
      return Promise.resolve(props).then((function(_this) {
        return function(props) {
          return _this._with({
            props: props,
            key: props.key,
            data: props.data
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withMergedProps = function(props) {
      return Promise.resolve(props).then((function(_this) {
        return function(props) {
          return _this._with({
            key: props.key,
            data: props.data,
            props: merge(_this.props, props)
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withMergedPropsWithoutNulls = function(props) {
      return Promise.resolve(props).then((function(_this) {
        return function(props) {
          return _this._with({
            key: props.key,
            data: props.data,
            props: mergeWithoutNulls(_this.props, props)
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withMergedErrorProps = function(errorProps) {
      return Promise.resolve(errorProps).then((function(_this) {
        return function(errorProps) {
          return _this._with({
            errorProps: merge(_this.errorProps, errorProps)
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withSession = function(session) {
      return Promise.resolve(session).then((function(_this) {
        return function(session) {
          return _this._with({
            session: session
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.withMergedSession = function(session) {
      return Promise.resolve(session).then((function(_this) {
        return function(session) {
          return _this._with({
            session: merge(_this.session, session)
          });
        };
      })(this));
    };

    RequestResponseBase.prototype.respondWithSession = function(session) {
      return this.success({
        session: session
      });
    };

    RequestResponseBase.prototype.respondWithMergedSession = function(session) {
      return this.success({
        session: merge(this.session, session)
      });
    };


    /*
    IN:
      withFunction, whenFunction
      OR: object:
        with: withFunction
        when: whenFunction
    
    withFunction: (record, requestOrResponse) ->
      IN:
        record: a plain object
        requestOrResponse: this
      OUT: See EFFECT below
        (can return a Promise in all situations)
    
    whenFunction: (record, requestOrResponse) -> t/f
      withFunction is only applied if whenFunction returns true
    
    EFFECT:
      if isPlainObject @data
        called once: singleRecordTransform @data
        if singleRecordTransform returns:
          null:         >> return status: missing
          plainObject:  >> return @withData data
          response:     >> return response
    
        See singleRecordTransform.OUT above for results
    
      if isArray @data
        Basically:
          @withData array record in @data with singleRecordTransform record
    
        But, each value returned from singleRecordTransform:
          null:                              omitted from array results
          response.status is clientFailure*: omitted from array results
          plainObject:                       returned in array results
          if any error:
              exception thrown
              rejected promise
              response.status is not success and not clientFailure
            then a failing response is returned
    
    TODO:
      Refactor. 'when' should really be a Filter - just like Caffeine/CoffeeScript comprehensions.
        Right now, if when is false, the record is still returned, just not "withed"
        Instead, only records that pass "when" should even be returned.
     */

    defaultWhenTest = function(data, request) {
      return request.pipeline.isRecord(data);
    };

    RequestResponseBase.prototype.withTransformedRecords = function(withFunction, whenFunction) {
      var firstFailure, options, transformedRecords;
      if (whenFunction == null) {
        whenFunction = defaultWhenTest;
      }
      if (isPlainObject(options = withFunction)) {
        withFunction = options["with"];
        whenFunction = options.when || defaultWhenTest;
      }
      if (isPlainObject(this.data)) {
        return Promise.resolve(whenFunction(this.data, this) ? this.next(withFunction(this.data, this)) : this);
      } else if (isArray(this.data)) {
        firstFailure = null;
        transformedRecords = array(this.data, (function(_this) {
          return function(record) {
            return Promise.then(function() {
              if (whenFunction(record, _this)) {
                return withFunction(record, _this);
              } else {
                return record;
              }
            })["catch"](function(error) {
              var ref2, response;
              if (error.status === "missing") {
                return null;
              } else if (response = error != null ? (ref2 = error.props) != null ? ref2.response : void 0 : void 0) {
                return response;
              } else {
                throw error;
              }
            }).then(function(out) {
              if ((out != null ? out.status : void 0) && out instanceof RequestResponseBase) {
                if (isClientFailure(out.status)) {
                  if (typeof out._clearErrorStack === "function") {
                    out._clearErrorStack();
                  }
                  return null;
                } else {
                  return firstFailure || (firstFailure = out);
                }
              } else {
                return out;
              }
            });
          };
        })(this));
        return Promise.all(transformedRecords).then((function(_this) {
          return function(records) {
            return firstFailure || _this.withData(compactFlatten(records));
          };
        })(this));
      } else {
        return Promise.resolve(this);
      }
    };


    /*
    next is used right after a filter or a handler.
    It's job is to convert the results into a request or response object.
    
    IN:
      null/undefined OR
      JSON-compabile data-type OR
      Response/Request OR
      something else - which is invalid, but is handled.
    
      OR a Promise returing one of the above
    
    OUT:
      if a Request or Response object was passed in, that is immediatly returned.
      Otherwise, this returns a Response object as follows:
    
    
      if data is null/undefined, return @missing
      if data is a JSON-compatible data structure, return @success with that data
      else, return @failure
     */

    RequestResponseBase.prototype.next = function(data) {
      return Promise.resolve(data).then((function(_this) {
        return function(data) {
          if (data instanceof RequestResponseBase) {
            return data;
          }
          if (data == null) {
            return _this.missing();
          } else if (isJsonType(data)) {
            return _this.success({
              data: data
            });
          } else {
            log.error({
              invalidXYZ: data
            });
            throw new Error("invalid response data passed to RequestResponseBaseNext");
          }
        };
      })(this), (function(_this) {
        return function(error) {
          var ref2, ref3;
          if ((ref2 = error.props) != null ? (ref3 = ref2.response) != null ? ref3.isResponse : void 0 : void 0) {
            return error.props.response;
          } else {
            return _this.failure({
              error: error
            });
          }
        };
      })(this));
    };

    RequestResponseBase.prototype.success = function(responseProps) {
      return this.toResponse(success, responseProps);
    };

    RequestResponseBase.prototype.missing = function(responseProps) {
      return this.toResponse(missing, responseProps);
    };

    RequestResponseBase.prototype.clientFailure = function(responseProps) {
      return this.toResponse(clientFailure, responseProps);
    };

    RequestResponseBase.prototype.clientFailureNotAuthorized = function(responseProps) {
      return this.toResponse(clientFailureNotAuthorized, responseProps);
    };

    RequestResponseBase.prototype.failure = function(responseProps) {
      return this.toResponse(failure, responseProps);
    };

    RequestResponseBase.prototype.rejectWithMissing = function(responseProps) {
      return this.toResponse(missing, responseProps, true);
    };

    RequestResponseBase.prototype.rejectWithClientFailure = function(responseProps) {
      return this.toResponse(clientFailure, responseProps, true);
    };

    RequestResponseBase.prototype.rejectWithClientFailureNotAuthorized = function(responseProps) {
      return this.toResponse(clientFailureNotAuthorized, responseProps, true);
    };

    RequestResponseBase.prototype.rejectWithFailure = function(responseProps) {
      return this.toResponse(failure, responseProps, true);
    };


    /*
    IN:
      status: legal CommunicationStatus
      responseProps: (optionally Promise returning:)
        PlainObject:          directly passed into the Response constructor
        String:               becomes data: message: string
        RequestResponseBase:  returned directly
        else:                 considered internal error, but it will create a valid, failing Response object
    OUT:
      promise.then (response) ->
      .catch -> # should never happen
     */

    RequestResponseBase.prototype.toResponse = function(status, responseProps, returnRejectedPromiseOnFailure) {
      if (returnRejectedPromiseOnFailure == null) {
        returnRejectedPromiseOnFailure = false;
      }
      if (!isString(status)) {
        throw new Error("missing status");
      }
      return Promise.resolve(responseProps).then((function(_this) {
        return function(responseProps) {
          if (responseProps == null) {
            responseProps = {};
          }
          switch (false) {
            case !(responseProps instanceof RequestResponseBase):
              log.warn("DEPRICATED: toResponse is instanceof RequestResponseBase");
              return responseProps;
            case !isPlainObject(responseProps):
              return new ArtEry.Response(merge(_this.propsForResponse, responseProps, {
                status: status,
                request: _this.request
              }));
            case !isString(responseProps):
              return _this.toResponse(status, {
                data: {
                  message: responseProps
                }
              });
            default:
              return _this.toResponse(failure, _this._toErrorResponseProps(responseProps));
          }
        };
      })(this)).then(function(response) {
        if (returnRejectedPromiseOnFailure) {
          return response.toPromise();
        } else {
          return response;
        }
      });
    };

    RequestResponseBase.prototype._toErrorResponseProps = function(error) {
      return log(this, {
        responseProps: responseProps
      }, {
        data: {
          message: responseProps instanceof Error ? "Internal Error: ArtEry.RequestResponseBase#toResponse received Error instance: " + (formattedInspect(responseProps)) : "Internal Error: ArtEry.RequestResponseBase#toResponse received unsupported type"
        }
      });
    };

    return RequestResponseBase;

  })(ArtEryBaseObject));

}).call(this);

//# sourceMappingURL=RequestResponseBase.js.map