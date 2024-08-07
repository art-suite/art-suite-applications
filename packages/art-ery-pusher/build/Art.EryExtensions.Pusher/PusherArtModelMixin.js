// Generated by CoffeeScript 1.12.7
(function() {
  var Config, Pusher, activeSubscriptions, config, defineModule, log, merge, ref, ref1, session, subscribeToChanges, verboseLog,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('./StandardImport'), defineModule = ref.defineModule, log = ref.log, merge = ref.merge;

  ref1 = require("./Lib"), verboseLog = ref1.verboseLog, subscribeToChanges = ref1.subscribeToChanges;

  config = (Config = require('./Config')).config;

  session = require('art-ery').session;

  Pusher = require('./namespace');

  activeSubscriptions = {};

  Pusher.getActiveSubscriptions = function() {
    return activeSubscriptions;
  };

  defineModule(module, function() {
    return function(superClass) {
      var PusherArtModelMixin;
      return PusherArtModelMixin = (function(superClass1) {
        extend(PusherArtModelMixin, superClass1);

        function PusherArtModelMixin() {
          this._processPusherChangedEvent = bind(this._processPusherChangedEvent, this);
          PusherArtModelMixin.__super__.constructor.apply(this, arguments);
          this._subscriptions = activeSubscriptions[this.name] = {};
        }

        PusherArtModelMixin.getter({
          pusherEventName: function() {
            return config.pusherEventName;
          }
        });

        PusherArtModelMixin.prototype.modelStoreEntryUpdated = function(arg) {
          var key, subscribers;
          key = arg.key, subscribers = arg.subscribers;
          if (subscribers.length > 0) {
            this._subscribe(key);
          }
          return PusherArtModelMixin.__super__.modelStoreEntryUpdated.apply(this, arguments);
        };

        PusherArtModelMixin.prototype.modelStoreEntryRemoved = function(arg) {
          var key;
          key = arg.key;
          this._unsubscribe(key);
          return PusherArtModelMixin.__super__.modelStoreEntryRemoved.apply(this, arguments);
        };


        /*
          IN:   pusherClient, channelName, eventName, handler
          OUT:  {} unsubscribe: function
          Pusher has the concept of subscribe & bind
          This does both in one step.
         */

        PusherArtModelMixin.prototype._subscribe = function(key) {
          var base;
          return (base = this._subscriptions)[key] != null ? base[key] : base[key] = subscribeToChanges(this.name, key, (function(_this) {
            return function(pusherData) {
              return _this._processPusherChangedEvent(pusherData, key);
            };
          })(this));
        };

        PusherArtModelMixin.prototype._unsubscribe = function(key) {
          var ref2;
          if ((ref2 = this._subscriptions[key]) != null) {
            ref2.unsubscribe();
          }
          return delete this._subscriptions[key];
        };

        PusherArtModelMixin.prototype._processPusherChangedEvent = function(event, channelKey) {
          var artModelRecord, error, key, model, sender, type, updatedAt;
          key = event.key, sender = event.sender, updatedAt = event.updatedAt, type = event.type;
          verboseLog({
            model: this.name,
            key: key,
            event: event
          });
          model = this.recordsModel || this;
          try {
            switch (type) {
              case "create":
              case "update":
                if (sender === session.data.artEryPusherSession) {
                  return verboseLog("saved 1 reload due to sender check! (model: " + this.name + ", key: " + key + ")");
                } else if ((artModelRecord = model.getModelRecord(key)) && artModelRecord.updatedAt >= updatedAt) {
                  return verboseLog("saved 1 reload due to updatedAt check! (model: " + this.name + ", key: " + key + ")");
                } else {
                  verboseLog({
                    dataUpdateTriggered: key
                  });
                  return model.loadData(key).then(function(data) {
                    return model.dataUpdated(key, data);
                  });
                }
                break;
              case "delete":
                verboseLog({
                  dataDeleteTriggered: {
                    name: this.name,
                    channelKey: channelKey,
                    key: key
                  }
                });
                model.dataDeleted(key);
                return this.dataDeleted(channelKey, key);
              default:
                return log.error("PusherFluxModelMixin: _processPusherChangedEvent: unsupported type: " + type, {
                  event: event
                });
            }
          } catch (error1) {
            error = error1;
            log({
              _processPusherChangedEvent: {
                error: error
              }
            });
            throw error;
          }
        };

        return PusherArtModelMixin;

      })(superClass);
    };
  });

}).call(this);

//# sourceMappingURL=PusherArtModelMixin.js.map
