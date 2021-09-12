{
  defineModule, log, merge
} = require './StandardImport'
{verboseLog, subscribeToChanges} = require "./Lib"

{config} = Config = require './Config'
{session} = require 'art-ery'
Pusher = require './namespace'

activeSubscriptions = {}
Pusher.getActiveSubscriptions = -> activeSubscriptions

defineModule module, -> (superClass) -> class PusherArtModelMixin extends superClass
  constructor: ->
    super
    @_subscriptions = activeSubscriptions[@name] = {}

  @getter
    pusherEventName: -> config.pusherEventName

  ####################
  # ArtModel Overrides
  ####################
  modelStoreEntryUpdated: ({key, subscribers}) ->
    @_subscribe key if subscribers.length > 0  # have local subscribers
    super

  modelStoreEntryRemoved: ({key}) ->
    @_unsubscribe key
    super

  ####################
  # PRIVATE
  ####################
  ###
    IN:   pusherClient, channelName, eventName, handler
    OUT:  {} unsubscribe: function
    Pusher has the concept of subscribe & bind
    This does both in one step.
  ###
  _subscribe: (key) ->
    @_subscriptions[key] ?= subscribeToChanges @name, key, (pusherData) =>
      @_processPusherChangedEvent pusherData, key

  _unsubscribe: (key) ->
    @_subscriptions[key]?.unsubscribe()
    delete @_subscriptions[key]

  _processPusherChangedEvent: (event, channelKey) =>
    {key, sender, updatedAt, type} = event
    verboseLog {model: @name, key, event}

    model = @recordsModel || @

    try
      switch type
        when "create", "update"
          if sender == session.data.artEryPusherSession
            verboseLog "saved 1 reload due to sender check! (model: #{@name}, key: #{key})"

          else if (artModelRecord = model.getModelRecord key) && artModelRecord.updatedAt >= updatedAt
            verboseLog "saved 1 reload due to updatedAt check! (model: #{@name}, key: #{key})"

          else
            verboseLog dataUpdateTriggered: key
            model.loadData key
            .then (data) -> model.dataUpdated key, data

        when "delete"
          verboseLog dataDeleteTriggered: {@name, channelKey, key}
          model.dataDeleted key

          # TODO: ideally the 2nd arg should be the keyString for the specific query
          @dataDeleted channelKey, key

        else log.error "PusherFluxModelMixin: _processPusherChangedEvent: unsupported type: #{type}", {event}
    catch error
      log _processPusherChangedEvent: {error}
      throw error