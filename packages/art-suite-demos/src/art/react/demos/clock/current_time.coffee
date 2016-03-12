Foundation = require 'art-foundation'
Flux = require 'art-flux'

{log, createHotWithPostCreate, shallowClone, timeout} = Foundation
{ApplicationState} = Flux

createHotWithPostCreate module, class CurrentTime extends ApplicationState
  @stateFields
    second: 0
    minute: 0
    hour: 0
    totalSeconds: 0

  @getter
    total: -> @second + @minute * 60 + @hour * 3600

  constructor: ->
    super
    d = new Date
    @second = d.getSeconds() | 0
    @minute = d.getMinutes() | 0
    @hour = d.getHours() | 0

    update = =>
      d = new Date
      second = d.getSeconds() | 0
      if second < @second
        @minute++
        if @minute >= 60
          @minute = 0
          @hour++
      @second = second

      timeout 100, update
    update()
