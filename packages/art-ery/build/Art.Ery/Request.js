// Generated by CoffeeScript 1.12.7
(function() {
  var ArtEry, CommunicationStatus, Foundation, Promise, Request, RestClient, Validator, _validator, arrayWith, clientFailure, currentSecond, each, failure, inspect, isFunction, isObject, isPlainObject, isString, log, merge, missing, object, objectHasKeys, objectKeyCount, objectWithout, present, ref, ref1, requestConstructorValidator, success, validStatus, w,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = Foundation = require('art-standard-lib'), currentSecond = ref.currentSecond, each = ref.each, present = ref.present, Promise = ref.Promise, merge = ref.merge, inspect = ref.inspect, isString = ref.isString, isObject = ref.isObject, log = ref.log, CommunicationStatus = ref.CommunicationStatus, arrayWith = ref.arrayWith, w = ref.w, objectKeyCount = ref.objectKeyCount, isString = ref.isString, isPlainObject = ref.isPlainObject, objectWithout = ref.objectWithout, isFunction = ref.isFunction, object = ref.object, objectHasKeys = ref.objectHasKeys;

  RestClient = require('art-rest-client');

  ArtEry = require('./namespace');

  Validator = require('art-validation').Validator;

  ref1 = require('art-communication-status'), success = ref1.success, missing = ref1.missing, validStatus = ref1.validStatus, clientFailure = ref1.clientFailure, failure = ref1.failure;

  _validator = null;

  requestConstructorValidator = function() {
    return _validator || (_validator = new Validator({
      pipeline: {
        required: {
          "instanceof": ArtEry.Pipeline
        }
      },
      type: {
        required: {
          fieldType: "string"
        }
      },
      session: {
        required: {
          fieldType: "object"
        }
      },
      parentRequest: {
        "instanceof": ArtEry.Request
      },
      originatedOnServer: "boolean",
      props: "object",
      key: "string"
    }));
  };


  /*
  new Request(options)
  
  IN: options:
    see requestConstructorValidator for the validated options
    below are special-case options
  
    props: {}
      Any props you want.
      Common props:
  
      data: - generaly one record's data or an array of record data
      key:  - generally the ID for one record OR the complete set of parameters for a get-query
  
     * aliases - if either data/key are provided in both props and in these aliases,
     *   these aliases have priority
    data: >> @props.data
    key:  >> @props.key
  
    NOTE: Request doesn't care about @data, the alias is proved only as a convenience
    NOTE: Request only cares about @key for two things:
      - REST urls
      - cachedGet
  
      In general, type: "get" and key: "string" is a CACHEABLE request.
      This is why it must be a string.
      Currently there are no controls for HOW cacheable type-get is, though.
      All other requests are NOT cacheable.
  
  CONCEPTS
  
    context:
  
      This is the only mutable part of the request. It establishes one shared context for
      a request, all its clones, subrequests, responses and response clones.
  
      The primary purpose is for subrequests to coordinate their actions with the primary
      request. Currently this is only used server-side.
  
      There are two contexts when using a remote server: The client-side context is not
      shared with the server-side context. A new context is created server-side when
      responding to the request.
  
      BUT - there is only one context if location == "both" - if we are running without
      a remote server.
   */

  module.exports = Request = (function(superClass) {
    var getRestClientParamsForArtEryRequest, restMap;

    extend(Request, superClass);

    function Request(options) {
      var context, key, ref2, ref3, verbose;
      Request.__super__.constructor.apply(this, arguments);
      if (!this._filterLog) {
        this._filterLog = [
          {
            name: "created",
            stack: this._creationStack,
            time: currentSecond()
          }
        ];
      }
      verbose = options.verbose, this.type = options.type, this.pipeline = options.pipeline, this.session = options.session, this.originalRequest = options.originalRequest, this.parentRequest = options.parentRequest, this.originatedOnServer = options.originatedOnServer, this.props = (ref2 = options.props) != null ? ref2 : {}, context = options.context, this.remoteRequest = options.remoteRequest;
      this._verbose = verbose;
      this._context = context;
      this._startTime = null;
      key = (ref3 = options.key) != null ? ref3 : this._props.key;
      if (key != null) {
        options.key = this._props.key = this.pipeline.toKeyString(key);
      }
      if (options.data != null) {
        this._props.data = options.data;
      }
      if (this._originalRequest == null) {
        this._originalRequest = this;
      }
      requestConstructorValidator().validate(options, {
        context: "create Art.Ery.Request options",
        logErrors: true
      });
      if (options.requestOptions) {
        throw new Error("options.requestOptions is DEPRICATED - use options.props");
      }
    }

    Request.property("originalRequest type pipeline session originatedOnServer parentRequest props data key context remoteRequest");

    Request.getter({
      context: function() {
        return this._context != null ? this._context : this._context = {};
      },
      key: function() {
        return this._props.key;
      },
      data: function() {
        return this._props.data;
      },
      requestData: function() {
        return this._props.data;
      },
      requestProps: function() {
        return this._props;
      },
      requestOptions: function() {
        throw new Error("DEPRICATED: use props");
      },
      description: function() {
        return this.requestString + " request";
      },
      summary: function() {
        return {
          request: {
            props: this.props
          }
        };
      }
    });

    Request.getter({
      request: function() {
        return this;
      },
      shortInspect: function() {
        return "" + (this.parentRequest ? this.parentRequest.shortInspect + " > " : "") + (this.pipeline.getName()) + "-" + this.type + "(" + (this.key || '') + ")";
      },
      beforeFilterLog: function() {
        return this.filterLog || [];
      },
      afterFilterLog: function() {
        return [];
      },
      isRequest: function() {
        return true;
      },
      isRootRequest: function() {
        return !this.parentRequest;
      },
      requestPipelineAndType: function() {
        log.warn("DEPRICATED - use pipelineAndType");
        return this.pipeline.name + "-" + this.type;
      },
      propsForClone: function() {
        return {
          originalRequest: this.originalRequest,
          pipeline: this.pipeline,
          type: this.type,
          props: this.props,
          session: this.session,
          parentRequest: this.parentRequest,
          filterLog: this.filterLog,
          originatedOnServer: this.originatedOnServer,
          context: this._context,
          verbose: this.verbose,
          remoteRequest: this.remoteRequest
        };
      },
      urlKeyClause: function() {
        if (present(this.key)) {
          return "/" + this.key;
        } else {
          return "";
        }
      }
    });

    Request.prototype.handled = function(_handledBy) {
      return this.success().then(function(response) {
        return response.handled(_handledBy);
      });
    };

    Request.prototype.getRestRequestUrl = function(server) {
      return server + "/" + this.pipeline.name + this.urlKeyClause;
    };

    Request.prototype.getNonRestRequestUrl = function(server) {
      return server + "/" + this.pipeline.name + "-" + this.type + this.urlKeyClause;
    };

    Request.prototype.toPromise = function() {
      throw new Error("ArtEry.Request: toPromise can only be called on Response objects.");
    };

    restMap = {
      get: "get",
      create: "post",
      update: "put",
      "delete": "delete"
    };

    Request.getRestClientParamsForArtEryRequest = getRestClientParamsForArtEryRequest = function(arg) {
      var data, hasSessionData, key, method, restPath, server, session, type, url, urlKeyClause;
      session = arg.session, server = arg.server, restPath = arg.restPath, type = arg.type, key = arg.key, data = arg.data;
      urlKeyClause = present(key) ? "/" + key : "";
      server || (server = "");
      hasSessionData = objectHasKeys(session);
      url = (method = restMap[type]) && (method !== "get" || !hasSessionData) ? "" + server + restPath + urlKeyClause : (method = "post", "" + server + restPath + "-" + type + urlKeyClause);
      return {
        method: method,
        url: url,
        data: data
      };
    };

    Request.getter({
      remoteRequestProps: function() {
        var data, key, pipeline, props, propsCount, ref2, remoteRequestData, session, type;
        ref2 = this, session = ref2.session, data = ref2.data, props = ref2.props, pipeline = ref2.pipeline, type = ref2.type, key = ref2.key;
        propsCount = 0;
        props = object(props, {
          when: function(v, k) {
            return v !== void 0 && k !== "key" && k !== "data";
          }
        });
        data = object(data, {
          when: function(v) {
            return v !== void 0;
          }
        });
        remoteRequestData = null;
        if (session.signature) {
          (remoteRequestData || (remoteRequestData = {})).session = session.signature;
        }
        if (0 < objectHasKeys(props)) {
          (remoteRequestData || (remoteRequestData = {})).props = props;
        }
        if (0 < objectHasKeys(data)) {
          (remoteRequestData || (remoteRequestData = {})).data = data;
        }
        return getRestClientParamsForArtEryRequest({
          restPath: pipeline.restPath,
          server: (function() {
            switch (pipeline.remoteServer) {
              case true:
              case ".":
              case "/":
                return "";
              default:
                return pipeline.remoteServer;
            }
          })(),
          type: type,
          key: key,
          session: session,
          data: remoteRequestData
        });
      }
    });

    Request.createFromRemoteRequestProps = function(options) {
      var data, key, pipeline, props, remoteRequest, requestData, session, type;
      session = options.session, pipeline = options.pipeline, type = options.type, key = options.key, requestData = options.requestData, remoteRequest = options.remoteRequest;
      data = requestData.data, props = requestData.props;
      return new Request({
        remoteRequest: remoteRequest,
        pipeline: pipeline,
        type: type,
        session: session,
        key: key,
        data: data,
        props: props,
        originatedOnClient: true
      });
    };

    Request.prototype.sendRemoteRequest = function() {
      var remoteRequest;
      return RestClient.restJsonRequest(remoteRequest = this.remoteRequestProps)["catch"]((function(_this) {
        return function(error) {
          var message, ref2, response, status;
          if (error.info) {
            ref2 = error.info, status = ref2.status, response = ref2.response;
          } else {
            status = error.status, message = error.message;
          }
          if (status == null) {
            status = failure;
          }
          return merge(response, {
            status: status,
            message: message
          });
        };
      })(this)).then((function(_this) {
        return function(remoteResponse) {
          return _this.addFilterLog((remoteRequest.method.toLocaleUpperCase()) + " " + remoteRequest.url, "remoteRequest").toResponse(remoteResponse.status, merge(remoteResponse, {
            remoteRequest: remoteRequest,
            remoteResponse: remoteResponse
          }));
        };
      })(this));
    };

    return Request;

  })(require('./RequestResponseBase'));

}).call(this);

//# sourceMappingURL=Request.js.map