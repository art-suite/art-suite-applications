{
  defineModule, log, merge
} = require './StandardImport'

{config} = Config = require './Config'
{session} = require 'art-ery'
Pusher = require './namespace'

activeSubscriptions = Pusher.activeSubscriptions = {}
Pusher.logActiveSubscriptions = ->
  log activeSubscriptions: Object.keys(activeSubscriptions).sort()

defineModule module, -> (superClass) -> class PusherArtModelMixin extends superClass
  constructor: ->
    super
    @_channels = {}
    @_listeners = {}

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
  _getPusherChannel: (key) ->
    Config.getPusherChannel @name, key

  # Pusher has the concept of subscribe & bind
  # This does both in one step.
  # If config.pusher isn't defined: noop
  _subscribe: (key) ->
    {pusherEventName} = config
    {pusherClient} = Config
    return unless pusherClient

    if config.verbose && !@_channels[key]
      log pusher:
        subscribe: @_getPusherChannel key
        model: @recordsModel || @
        self: @

    @_channels[key] ?= pusherClient.subscribe @_getPusherChannel key
    unless @_listeners[key]
      activeSubscriptions["#{@name} #{key}"] = true
      @_channels[key].bind pusherEventName, @_listeners[key] = (pusherData) =>
        log {key, pusherData}
        @_processPusherChangedEvent pusherData, key

  # If config.pusher isn't defined: noop
  _unsubscribe: (key) ->
    {pusherEventName} = config
    {pusherClient} = Config
    return unless pusherClient && @_channels[key]

    # unbind
    if @_listeners[key]
      @_channels[key]?.unbind pusherEventName, @_listeners[key]
      delete @_listeners[key]

    # unsubscribe
    delete activeSubscriptions["#{@name} #{key}"]

    if config.verbose
      log pusher:
        unsubscribe: @_getPusherChannel key
        model: @recordsModel || @

    pusherClient.unsubscribe @_getPusherChannel key
    delete @_channels[key]

  _processPusherChangedEvent: (event, channelKey) =>
    {key, sender, updatedAt, type} = event

    model = @recordsModel || @

    log _processPusherChangedEvent: {key, sender, updatedAt, type, model}

    try
      switch type
        when "create", "update"
          if sender == session.data.artEryPusherSession
            log "saved 1 reload due to sender check! (model: #{@name}, key: #{key})"
            return

          if (artModelRecord = model.getModelRecord key) && artModelRecord.updatedAt >= updatedAt
            log "saved 1 reload due to updatedAt check! (model: #{@name}, key: #{key})"
            return

          log dataUpdateTriggered: key
          model.loadData key
          .then (data) -> model.dataUpdated key, data

        when "delete"
          log dataDeleteTriggered: key
          # TODO: in order to update local queries... we need the queryKey - which needs
          # the record data for the deleted record -- OR we need to scan all local query data...
          model.dataDeleted key
          @dataDeleted channelKey, key

        else log.error "PusherFluxModelMixin: _processPusherChangedEvent: unsupported type: #{type}", {event}
    catch error
      log {error}
      throw error