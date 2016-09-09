Foundation = require 'art-foundation'
Flux = require 'art-flux'

{log, createWithPostCreate, shallowClone, timeout} = Foundation
{ApplicationState} = Flux

createWithPostCreate module, class CurrentTime extends ApplicationState
  @stateFields
    second: 0
    minute: 0
    hour: 0
    totalSeconds: 0

  @getter
    total: -> @second + @minute * 60 + @hour * 3600

  _update: ->
    d = new Date
    second = d.getSeconds() | 0
    if second < @second
      @minute++
      if @minute >= 60
        @minute = 0
        @hour++
    @second = second

    timeout 1000, => @_update()

  constructor: ->
    super
    d = new Date
    @second = d.getSeconds() | 0
    @minute = d.getMinutes() | 0
    @hour = d.getHours() | 0

    @_update()
