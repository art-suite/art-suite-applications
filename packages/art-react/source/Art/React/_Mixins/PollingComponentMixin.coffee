{defineModule, log, interval} = require 'art-standard-lib'

defineModule module, ->
  (superClass) -> class PollingComponentMixin extends superClass
    @extendableProperty pollInterval: 10

    # override this:
    poll: ->

    @getter
      pollCount: -> @state.pollCount ? 0

    @setter
      pollCount: (v) -> @setState "pollCount", v

    componentWillMount: ->
      super
      @poll @pollCount ? 0
      @_interval = interval @getPollInterval() * 1000, =>
        @pollCount = pc = (@pollCount ? 0) + 1
        @poll pc

    componentWillUnmount: -> @_interval.stop()
