{
  defineModule, log, merge
} = require './StandardImport'

{config} = Config = require './Config'
{session} = require 'art-ery'
Pusher = require './namespace'

activeSubscriptions = Pusher.activeSubscriptions = {}
Pusher.logActiveSubscriptions = ->
  log activeSubscriptions: Object.keys(activeSubscriptions).sort()

defineModule module, -> (superClass) -> class PusherFluxModelMixin extends superClass
  constructor: ->
    super
    @_channels = {}
    @_listeners = {}

  ####################
  # FluxModel Overrides
  ####################
  fluxStoreEntryUpdated: ({key, subscribers}) ->
    @_subscribe key if subscribers.length > 0  # have local subscribers
    super

  fluxStoreEntryRemoved: ({key}) ->
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

    @_channels[key] ||= pusherClient.subscribe @_getPusherChannel key
    unless @_listeners[key]
      activeSubscriptions["#{@name} #{key}"] = true
      @_channels[key].bind pusherEventName, @_listeners[key] = (pusherData) => @_processPusherChangedEvent pusherData, key

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
    pusherClient.unsubscribe @_getPusherChannel key
    delete @_channels[key]

  _processPusherChangedEvent: (event, channelKey) =>
    {key, sender, updatedAt, type} = event

    model = @recordsModel || @

    switch type
      when "create", "update"
        if sender == session.data.artEryPusherSession
          log "saved 1 reload due to sender check! (model: #{@name}, key: #{key})"
          return

        if (fluxRecord = model.fluxStoreGet key) && fluxRecord.updatedAt >= updatedAt
          log "saved 1 reload due to updatedAt check! (model: #{@name}, key: #{key})"
          return

        model.loadPromise key

      when "delete"
        # TODO: in order to update local queries... we need the queryKey - which needs
        # the record data for the deleted record -- OR we need to scan all local query data...
        model.dataDeleted key
        @dataDeleted channelKey, key

      else log.error "PusherFluxModelMixin: _processPusherChangedEvent: unsupported type: #{type}", {event}
