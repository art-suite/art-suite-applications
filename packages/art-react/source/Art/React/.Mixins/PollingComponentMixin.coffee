{defineModule, log, interval} = require 'art-standard-lib'

defineModule module, ->
  (superClass) -> class PollingComponentMixin extends superClass
    @extendableProperty pollInterval: 10

    # override this:
    poll: ->
      log.warn "PollingComponentMixin: @poll() not overridden."

    componentWillMount: ->
      super
      @poll()
      @_interval = interval @getPollInterval() * 1000, @poll

    componentWillUnmount: -> @_interval.stop()
