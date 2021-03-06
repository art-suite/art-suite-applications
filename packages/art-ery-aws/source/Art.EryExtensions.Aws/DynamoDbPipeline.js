// Generated by CoffeeScript 1.12.7
(function() {
  var ArtAws, DynamoDb, DynamoDbPipeline, KeyFieldsMixin, Pipeline, Promise, UpdateAfterMixin, Validator, compactFlatten, compare, deepMerge, defineModule, formattedInspect, inspect, intRand, isArray, isFunction, isPlainObject, isString, log, merge, mergeInto, mergeIntoUnless, networkFailure, object, objectWithExistingValues, pipelines, present, ref, ref1, timeout, upperCamelCase, withSort,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('art-standard-lib'), defineModule = ref.defineModule, mergeInto = ref.mergeInto, Promise = ref.Promise, object = ref.object, isPlainObject = ref.isPlainObject, deepMerge = ref.deepMerge, compactFlatten = ref.compactFlatten, inspect = ref.inspect, log = ref.log, merge = ref.merge, compare = ref.compare, Validator = ref.Validator, isString = ref.isString, isFunction = ref.isFunction, withSort = ref.withSort, formattedInspect = ref.formattedInspect, mergeIntoUnless = ref.mergeIntoUnless, objectWithExistingValues = ref.objectWithExistingValues, present = ref.present, isString = ref.isString, timeout = ref.timeout, intRand = ref.intRand, isArray = ref.isArray, upperCamelCase = ref.upperCamelCase;

  networkFailure = require('art-communication-status').networkFailure;

  ref1 = require('art-ery'), Pipeline = ref1.Pipeline, KeyFieldsMixin = ref1.KeyFieldsMixin, pipelines = ref1.pipelines, UpdateAfterMixin = ref1.UpdateAfterMixin;

  DynamoDb = (ArtAws = require('art-aws')).DynamoDb;

  defineModule(module, DynamoDbPipeline = (function(superClass) {
    var isServiceUnavailableError, retryIfServiceUnavailable;

    extend(DynamoDbPipeline, superClass);

    function DynamoDbPipeline() {
      return DynamoDbPipeline.__super__.constructor.apply(this, arguments);
    }

    DynamoDbPipeline.abstractClass();

    DynamoDbPipeline.createTablesForAllRegisteredPipelines = function() {
      var name, pipeline, promises;
      promises = (function() {
        var results;
        results = [];
        for (name in pipelines) {
          pipeline = pipelines[name];
          if (isFunction(pipeline.createTable)) {
            results.push(pipeline.createTable());
          }
        }
        return results;
      })();
      return Promise.all(promises);
    };

    DynamoDbPipeline.classGetter({
      dynamoDb: function() {
        return DynamoDb.singleton;
      }
    });

    DynamoDbPipeline.globalIndexes = function(globalIndexes) {
      this._globalIndexes = globalIndexes;
      return this.query(this._getAutoDefinedQueries(globalIndexes));
    };

    DynamoDbPipeline.localIndexes = function(localIndexes) {
      this._localIndexes = localIndexes;
      return this.query(this._getAutoDefinedQueries(localIndexes));
    };

    DynamoDbPipeline.getter({
      globalIndexes: function() {
        return this._options.globalIndexes || this["class"]._globalIndexes;
      },
      localIndexes: function() {
        return this._options.localIndexes || this["class"]._localIndexes;
      }
    });

    DynamoDbPipeline.primaryKey = function() {
      var hashKey, keyFields, obj, ref2;
      DynamoDbPipeline.__super__.constructor.primaryKey.apply(this, arguments);
      if ((ref2 = keyFields = this.getKeyFields(), hashKey = ref2[0], ref2) && (keyFields != null ? keyFields.length : void 0) === 2) {
        return this.query(this._getAutoDefinedQueries((
          obj = {},
          obj["by" + (upperCamelCase(hashKey))] = this.getKeyFieldsString(),
          obj
        )));
      }
    };

    DynamoDbPipeline.getter({
      status: function() {
        return this._vivifyTable().then(function() {
          return "OK: table exists and is reachable";
        })["catch"](function() {
          return "ERROR: could not connect to the table";
        });
      },
      dynamoDb: function() {
        return DynamoDb.singleton;
      }
    });

    DynamoDbPipeline.prototype.queryDynamoDb = function(params) {
      log.warn("DEPRICATED: queryDynamoDb; use queryDynamoDbWithRequest");
      return this._retryIfServiceUnavailable(null, (function(_this) {
        return function() {
          return _this.dynamoDb.query(merge(params, {
            table: _this.tableName
          }));
        };
      })(this));
    };

    DynamoDbPipeline.prototype.queryDynamoDbWithRequest = function(request, params) {
      return this._retryIfServiceUnavailable(request, (function(_this) {
        return function() {
          return _this.dynamoDb.query(merge(params, {
            table: _this.tableName
          }));
        };
      })(this));
    };

    DynamoDbPipeline.prototype.scanDynamoDb = function(params) {
      return this.dynamoDb.scan(merge(params, {
        table: this.tableName
      }));
    };

    DynamoDbPipeline.prototype.withDynamoDb = function(action, params) {
      return this.dynamoDb[action](merge(params, {
        table: this.tableName
      }));
    };


    /*
    iterate over entire table
    IN:
      f: (listOfRecords) -> # out ignored; throw to abort
      options:
        limit: stop after this many entries found
        batchLimit: limit the number of entries returned per batch
    OUT: count
     */

    DynamoDbPipeline.prototype.batchedEach = function(f, options) {
      var batchLimit, inLastEvaluatedKey, lastEvaluatedKey, limit;
      if (options == null) {
        options = {};
      }
      lastEvaluatedKey = options.lastEvaluatedKey, limit = options.limit, batchLimit = options.batchLimit;
      if ((limit != null) && (batchLimit == null)) {
        batchLimit = limit;
      }
      inLastEvaluatedKey = lastEvaluatedKey;
      return this.getAll({
        returnResponse: true,
        props: merge(options.props, {
          lastEvaluatedKey: lastEvaluatedKey,
          limit: batchLimit
        })
      }).then((function(_this) {
        return function(arg) {
          var data, getMore, lastEvaluatedKey, ref2;
          (ref2 = arg.props, lastEvaluatedKey = ref2.lastEvaluatedKey), data = arg.data;
          getMore = (!limit || limit > data.length) && !!lastEvaluatedKey;
          log("got " + data.length + " records. " + (formattedInspect({
            getMore: getMore,
            limit: limit,
            lastEvaluatedKey: lastEvaluatedKey
          })));
          if (lastEvaluatedKey != null) {
            if (inLastEvaluatedKey === lastEvaluatedKey) {
              throw new Error("same last-key " + inLastEvaluatedKey);
            }
          }
          return Promise.then(function() {
            return f(data);
          }).then(function() {
            if (getMore) {
              return _this.batchedEach(f, merge(options, {
                lastEvaluatedKey: lastEvaluatedKey,
                limit: (limit != null) && limit - data.length
              })).then(function(count) {
                return count + data.length;
              });
            } else {
              return data.length;
            }
          });
        };
      })(this));
    };

    DynamoDbPipeline.handlers({
      createTable: function() {
        return this._vivifyTable().then(function() {
          return {
            message: "success"
          };
        });
      },
      initialize: function(request) {
        return this._vivifyTable().then(function() {
          return {
            message: "success"
          };
        });
      },
      getInitializeParams: function() {
        return this.createTableParams;
      },
      get: function(request) {
        return this._artEryToDynamoDbRequest(request, {
          requiresKey: true,
          then: (function(_this) {
            return function(params) {
              return _this.dynamoDb.getItem(params).then(function(result) {
                return result.item || request.missing();
              });
            };
          })(this)
        });
      },

      /*
      limit: number (optional)
      lastEvaluatedKey:
        use the lastEvaluatedKey that was returned from the previous call, if it was set
       */
      scan: function(request) {
        var lastEvaluatedKey, limit, ref2;
        ref2 = request.props, limit = ref2.limit, lastEvaluatedKey = ref2.lastEvaluatedKey;
        return this.scanDynamoDb({
          limit: limit,
          lastEvaluatedKey: lastEvaluatedKey
        }).then(function(arg) {
          var items, lastEvaluatedKey;
          lastEvaluatedKey = arg.lastEvaluatedKey, items = arg.items;
          return request.success({
            data: items,
            props: {
              lastEvaluatedKey: lastEvaluatedKey
            }
          });
        });
      },
      getAll: function(request) {
        return request.subrequest(request.pipeline, "scan", {
          returnResponse: true,
          props: request.props
        });
      },
      batchGet: function(request) {
        var keys, ref2, select;
        ref2 = request.props, keys = ref2.keys, select = ref2.select;
        return request.require(isArray(request.props.keys)).then(function() {
          if (select) {
            return request.require(isString(request.props.select));
          }
        }).then((function(_this) {
          return function() {
            return _this._artEryToDynamoDbRequest(request, {
              then: function(params) {
                return _this.dynamoDb.batchGetItem(params).then(function(arg) {
                  var items;
                  items = arg.items;
                  return items;
                });
              }
            });
          };
        })(this));
      },

      /*
      TODO: make create fail if the item already exists
        WHY? we have after-triggers that need to only trigger on a real create - not a replace
        AND filters like ValidationFilter assume create is a real create and update is a real update...
        NOTE: replace should be considered an update...
        NOTE: We have createOrUpdate if you really want both.
      
        ADD "replaceOk" prop
          Only replace existing items if explicitly requested:
          {replaceOk} = request.props
          This will mostly be used internally. Use createOrUpdate for
          that behavior externally.
      
      HOW to do 'replaceOk':
      
        http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html
        To prevent a new item from replacing an existing item, use a conditional
        expression that contains the attribute_not_exists function with the name of
        the attribute being used as the partition key for the table. Since every
        record must contain that attribute, the attribute_not_exists function will
        only succeed if no matching item exists.
       */
      create: function(request) {
        return this._artEryToDynamoDbRequest(request, {
          then: (function(_this) {
            return function(params) {
              return _this.dynamoDb.putItem(params).then(function() {
                return request.data;
              });
            };
          })(this)
        });
      },

      /*
      IN: response.props:
        createOk: true/falsish
          NOTE:
            A) can only use on tables which don't auto-generate-ids
      
      OUT:
        if record didn't exist:
          if createOk
            record was created
          response.status == missing
        else
          data: all fields with their current values (returnValues: 'allNew')
      
      TODO:
        support request.props.add and request.props.setDefault
          for both: requireOriginatedOnServer
       */
      update: function(request) {
        var createOk;
        createOk = request.props.createOk;
        return request.requireServerOriginIf(createOk, "to use createOk").then((function(_this) {
          return function() {
            return request.rejectIf(createOk && _this.getKeyFieldsString() === 'id', "createOk not available on tables with auto-generated-ids");
          };
        })(this)).then((function(_this) {
          return function() {
            var _dynamoDbParams;
            _dynamoDbParams = null;
            return _this._artEryToDynamoDbRequest(request, {
              mustExist: !createOk,
              requiresKey: true,
              then: function(dynamoDbParams) {
                _dynamoDbParams = dynamoDbParams;
                return _this.dynamoDb.updateItem(dynamoDbParams).then(function(arg) {
                  var data, item, modifiedFields, ref2;
                  item = arg.item;
                  if ((ref2 = dynamoDbParams.returnValues) != null ? ref2.match(/old/i) : void 0) {
                    return request.success({
                      props: {
                        oldData: item,
                        data: request.requestDataWithKey
                      }
                    });
                  } else {
                    modifiedFields = _this.getFieldsRequestWillModify(request);
                    return request.success({
                      props: {
                        data: data = mergeInto(request.requestDataWithKey, item),
                        updatedData: object(data, {
                          when: function(v, k) {
                            return modifiedFields[k] != null;
                          }
                        })
                      }
                    });
                  }
                })["catch"](function(error) {
                  if (error.message.match(/ConditionalCheckFailedException/)) {
                    return request.missing("Attempted to update a non-existant record.");
                  } else {
                    log({
                      DynamoDbPipeline_update: {
                        error: error,
                        request: request
                      }
                    });
                    throw error;
                  }
                });
              }
            }).tapCatch(function(error) {
              return log({
                ArtEryDynamoDb: {
                  request: request,
                  _dynamoDbParams: _dynamoDbParams
                }
              });
            });
          };
        })(this));
      },

      /* updateBulk - TODO
        IN: data: array of objects compatible with a single 'update'
        Make sure to also update getFieldsRequestWillModify to correctly merge down all fields in the builk-update.
          This'll ensure UserOwnedFilter properly handles authorization
       */

      /*
        OUT:
          if record didn't exist:
            response.status == missing
          else
            data: keyFields & values
       */
      "delete": function(request) {
        return this._artEryToDynamoDbRequest(request, {
          mustExist: true,
          returnValues: "allOld",
          then: (function(_this) {
            return function(deleteItemParams) {
              return _this.dynamoDb.deleteItem(deleteItemParams).then(function(arg) {
                var item;
                item = arg.item;
                return item;
              })["catch"](function(error) {
                if (error.message.match(/ConditionalCheckFailedException/)) {
                  return request.missing("Attempted to delete a non-existant record.");
                } else {
                  throw error;
                }
              });
            };
          })(this)
        });
      },

      /*
      This calls 'get' first, then calls 'delete' if it exists. Therefor 'delete' hooks
      will only fire if the record actually exists.
      
      OUT: promise.then (response) -> response.data == key(s)
       */
      deleteIfExists: function(request) {
        var data, key;
        key = request.key, data = request.data;
        return request.subrequest(this.pipelineName, "delete", {
          key: key,
          data: data,
          returnNullIfMissing: true
        }).then(function(result) {
          return result != null ? result : request.success({
            data: request.requestDataWithKey
          });
        });
      },

      /*
      This calls 'update' and possibly 'create', so hooks on update OR create will be correctly triggered.
      NOTE: Only after-update OR after-create filters/events will be processed - NOT BOTH!
        Which is the whole reason this exists, really - so the correct after-filters-events fire.
      
      TODO:
        The new version should do this:
        get {key, returnNullIfMissing: true}
        .then (exists) ->
          if exists
            update {key, data}
            .catch (doesntExists???) ->
              Promise.reject raceConditionOccured: true if doesntExists
             * NOTE - ignoring the race-condition with 'delete'
          else
            create {key, data}
            .catch (exists???) ->
              Promise.reject raceConditionOccured: true if exists
        .catch ({raceConditionOccured}) ->
          if raceConditionOccured && 3 > retryCount = 1 + props.retryCount ? 0
            createOrUpdate {
              key
              props: merge props, {retryCount}
            }
          else
            throw original-error
       */
      createOrUpdate: function(request) {
        return request.requireServerOrigin().then((function(_this) {
          return function() {
            return request.rejectIf(_this.getKeyFieldsString() === 'id', "createOk not available on tables with auto-generated-ids");
          };
        })(this)).then((function(_this) {
          return function() {
            var add, data, key, ref2, setDefault;
            ref2 = request.props, key = ref2.key, data = ref2.data, add = ref2.add, setDefault = ref2.setDefault;
            return request.subrequest(_this.pipelineName, "update", {
              returnNullIfMissing: true,
              props: {
                key: key,
                data: data,
                add: add,
                setDefault: setDefault
              }
            }).then(function(result) {
              var keyFields;
              keyFields = isPlainObject(key) ? key : isString(key) && _this.toKeyObject ? _this.toKeyObject(key) : void 0;
              return result != null ? result : request.subrequest(_this.pipelineName, "create", {
                key: key,
                data: merge(keyFields, setDefault, data, add)
              });
            });
          };
        })(this));
      }
    });

    DynamoDbPipeline.prototype.getFieldsRequestWillModify = function(request) {
      return merge(request.props.setDefault, request.props.add, request.data);
    };


    /*
    IN:
      indexes: <Object> # a map:
        myIndexName: indexKeyOrProps
    
    indexKeyOrProps:
      <String> indexKey string
      <Object>
        key: <String> indexKey string
        ... other props passed to DynamoDb for index creation; ignored here
    
    OUT: params for Art.Ery.Pipeline's @query method
      Example:
        myQueryName:
          query: generatedQueryHandler = (request) ->
        ...
    
    EFFECT - after passed to @query:
      @handlers
        myQueryName:      generatedQueryHandler
        myQueryNameDesc:  generatedQueryHandlerDesc
    
    generatedQueryHandler Handler API:
      IN:
        REQUIRED: key: hashKeyValue <string>
        OPTIONAL:
          props: where: [sortKey]: # with exactly one of the following:
            eq:           sortValue
            lt:           sortValue
            lte:          sortValue
            gt:           sortValue
            gte:          sortValue
            between:      [sortValueA, sortValueB]  # returns values >= sortValueA and <= sortValueB
            beginsWith:   string-prefix
     */

    DynamoDbPipeline._getAutoDefinedQueries = function(indexes) {
      var fn, indexKey, queries, queryModelName;
      if (!indexes) {
        return {};
      }
      queries = {};
      fn = (function(_this) {
        return function(queryModelName, indexKey) {
          var doDynamoQuery, hashKey, indexName, ref2, sortKey;
          if (indexKey != null ? indexKey.key : void 0) {
            indexKey = indexKey.key;
          }
          if (isString(indexKey)) {
            ref2 = indexKey.split("/"), hashKey = ref2[0], sortKey = ref2[1];
            indexName = indexKey !== _this.getKeyFieldsString() ? queryModelName : void 0;
            doDynamoQuery = function(request, descending) {
              var beginsWith, between, eq, gt, gte, lt, lte, obj, params, ref3, select, sortKeyWhere;
              params = {
                where: (
                  obj = {},
                  obj["" + hashKey] = request.key,
                  obj
                )
              };
              if (indexName != null) {
                params.index = indexName;
              }
              if (descending) {
                params.descending = true;
              }
              if (sortKeyWhere = (ref3 = request.props.where) != null ? ref3[sortKey] : void 0) {
                if (isPlainObject(sortKeyWhere)) {
                  eq = sortKeyWhere.eq, lt = sortKeyWhere.lt, lte = sortKeyWhere.lte, gt = sortKeyWhere.gt, gte = sortKeyWhere.gte, between = sortKeyWhere.between, beginsWith = sortKeyWhere.beginsWith;
                  params.where[sortKey] = merge({
                    eq: eq,
                    lt: lt,
                    lte: lte,
                    gt: gt,
                    gte: gte,
                    between: between,
                    beginsWith: beginsWith
                  });
                } else {
                  params.where[sortKey] = {
                    eq: sortKeyWhere
                  };
                }
              }
              if (select = request.props.select) {
                if (isArray(select)) {
                  select = compactFlatten(select).join(' ');
                }
                if (!isString(select)) {
                  return request.clientFailure("select must be a string or array of strings");
                }
                params.select = select;
              }
              return request.pipeline.queryDynamoDbWithRequest(request, params).then(function(arg) {
                var items;
                items = arg.items;
                return items;
              }).tapCatch(function(error) {
                return log({
                  DynamoDbPipeline_query: {
                    error: error,
                    params: params,
                    request: request
                  }
                });
              });
            };
            queries[queryModelName] = {
              query: function(request) {
                return doDynamoQuery(request);
              },
              dataToKeyString: function(data) {
                return data[hashKey];
              },
              keyFields: [hashKey],
              localSort: function(queryData) {
                return withSort(queryData, function(a, b) {
                  var ret;
                  if (0 === (ret = compare(a[sortKey], b[sortKey]))) {
                    return compare(a.id, b.id);
                  } else {
                    return ret;
                  }
                });
              }
            };
            return queries[queryModelName + "Desc"] = {
              query: function(request) {
                return doDynamoQuery(request, true);
              },
              dataToKeyString: function(data) {
                return data[hashKey];
              },
              keyFields: [hashKey],
              localSort: function(queryData) {
                return withSort(queryData, function(b, a) {
                  var ret;
                  if (0 === (ret = compare(a[sortKey], b[sortKey]))) {
                    return compare(a.id, b.id);
                  } else {
                    return ret;
                  }
                });
              }
            };
          }
        };
      })(this);
      for (queryModelName in indexes) {
        indexKey = indexes[queryModelName];
        fn(queryModelName, indexKey);
      }
      return queries;
    };

    DynamoDbPipeline.prototype._vivifyTable = function() {
      return this._vivifyTablePromise || (this._vivifyTablePromise = Promise.resolve().then((function(_this) {
        return function() {
          return _this.tablesByNameForVivification.then(function(tablesByName) {
            if (!tablesByName[_this.tableName]) {
              log.warn((_this.getClassName()) + "#_vivifyTable() dynamoDb table does not exist: " + _this.tableName + ", creating...");
              return _this._createTable();
            }
          });
        };
      })(this)));
    };

    DynamoDbPipeline.classGetter({
      tablesByNameForVivification: function() {
        return this._tablesByNameForVivificationPromise || (this._tablesByNameForVivificationPromise = this.getDynamoDb().listTables().then((function(_this) {
          return function(arg) {
            var TableNames;
            TableNames = arg.TableNames;
            return object(TableNames, function() {
              return true;
            });
          };
        })(this)));
      }
    });

    DynamoDbPipeline.getter({
      tablesByNameForVivification: function() {
        return DynamoDbPipeline.getTablesByNameForVivification();
      },
      dynamoDbCreationAttributes: function() {
        var k, out, ref2, v;
        out = {};
        ref2 = this.normalizedFields;
        for (k in ref2) {
          v = ref2[k];
          if (v.dataType === "string" || v.dataType === "number") {
            out[k] = v.dataType;
          }
        }
        return out;
      },
      streamlinedCreateTableParams: function() {
        return merge({
          table: this.tableName,
          globalIndexes: this.globalIndexes,
          localIndexes: this.localIndexes,
          attributes: this.dynamoDbCreationAttributes,
          key: this.keyFieldsString
        }, this._options);
      },
      createTableParams: function() {
        return ArtAws.StreamlinedDynamoDbApi.CreateTable.translateParams(this.streamlinedCreateTableParams);
      }
    });

    DynamoDbPipeline.prototype._createTable = function() {
      return this.dynamoDb.createTable(this.streamlinedCreateTableParams)["catch"]((function(_this) {
        return function(e) {
          log.error("DynamoDbPipeline#_createTable " + _this.tableName + " FAILED", e);
          throw e;
        };
      })(this));
    };


    /*
    IN:
      request:
        requestProps:
          key
          data: {key: value}
            NOTE: null values are moved for CREATE and converted to REMOVE (attribute)
              actions for UPDATE.
    
          add: {key: value to add} -> dynamodb ADD action
          setDefault: {key: value} -> set attribute if not present
          conditionExpresssion: dynamodb update-of condition expressiong
          returnValues:         art.aws.dynamodb return value selector type
    
      requiresKey: true/false
        true:  key and data will be normalized using the primaryKey fields
        false: there willbe no key
    
      action: (streamlinedDynamoDbParams) -> out
    
    OUT:
      promise.catch (error) ->                # only internalErrors are thrown
      promise.then (clientFailureResponse) -> # if input is invalid, return clientFailure without invoking action
      promise.then (out) ->                   # otherwise, returns action's return value
     */

    DynamoDbPipeline.prototype._artEryToDynamoDbRequest = function(request, options) {
      var add, conditionExpression, consistentRead, data, key, keys, mustExist, ref2, requestType, requiresKey, returnValues, select, setDefault;
      if (options == null) {
        options = {};
      }
      requiresKey = options.requiresKey, mustExist = options.mustExist;
      if (mustExist) {
        requiresKey = true;
      }
      ref2 = request.props, key = ref2.key, data = ref2.data, add = ref2.add, setDefault = ref2.setDefault, conditionExpression = ref2.conditionExpression, returnValues = ref2.returnValues, consistentRead = ref2.consistentRead, keys = ref2.keys, select = ref2.select;
      requestType = request.requestType;
      return this._retryIfServiceUnavailable(request, (function(_this) {
        return function() {
          return Promise.then(function() {
            return request.requireServerOriginOr(!(add || setDefault || conditionExpression || returnValues), "to use add, setDefault, returnValues, or conditionExpression props");
          }).then(function() {
            return request.require(!(add || setDefault) || requestType === "update", "add and setDefault only valid for update requests");
          }).then(function() {
            var k, remove, v;
            if (requiresKey) {
              data = _this.dataWithoutKeyFields(data);
              key = _this.toKeyObject(request.key);
            }
            if (requestType === "update") {
              remove = (function() {
                var results;
                results = [];
                for (k in data) {
                  v = data[k];
                  if (v === null) {
                    results.push(k);
                  }
                }
                return results;
              })();
            }
            data = objectWithExistingValues(data);
            if (options.returnValues) {
              returnValues = options.returnValues;
            }
            if (requestType === "update") {
              returnValues || (returnValues = "allNew");
            }
            conditionExpression || (conditionExpression = mustExist && key);
            if (consistentRead) {
              consistentRead = true;
            }
            return objectWithExistingValues({
              tableName: _this.tableName,
              data: data,
              key: key,
              keys: keys,
              select: select,
              remove: remove,
              add: add,
              setDefault: setDefault,
              returnValues: returnValues,
              conditionExpression: conditionExpression,
              consistentRead: consistentRead
            });
          }).then(options.then, function(arg) {
            var message;
            message = arg.message;
            return request.clientFailure(message);
          });
        };
      })(this));
    };

    isServiceUnavailableError = function(error) {
      return error.message.match(/Service *Unavailable/i);
    };

    DynamoDbPipeline.prototype._retryIfServiceUnavailable = retryIfServiceUnavailable = function(request, action, retriesRemaining) {
      if (retriesRemaining == null) {
        retriesRemaining = 2;
      }
      return Promise.then(function() {
        return action();
      })["catch"](function(error) {
        if (isServiceUnavailableError(error)) {
          if (retriesRemaining > 0) {
            return timeout(10 + intRand(20)).then((function(_this) {
              return function() {
                return retryIfServiceUnavailable(request, action, retriesRemaining - 1);
              };
            })(this));
          } else if (request) {
            return request.toResponse(networkFailure).then(function(response) {
              return response.toPromise();
            });
          } else {
            throw error;
          }
        } else {
          throw error;
        }
      });
    };

    return DynamoDbPipeline;

  })(KeyFieldsMixin(UpdateAfterMixin(Pipeline))));

}).call(this);

//# sourceMappingURL=DynamoDbPipeline.js.map
