Foundation = require 'art-foundation'
Flux = require 'art-flux'
Atomic = require 'art-atomic'

{log, createHotWithPostCreate, shallowClone, timeout, bound} = Foundation
{ApplicationState} = Flux
{rgbColor} = Atomic

createHotWithPostCreate module, class CurrentColor extends ApplicationState

  # we maintain both the color and the individual channels
  # so we don't lose information in degenerate cases (like saturation or lightness == 0 or 1)
  getInitialState: ->
    color: rgbColor "#f00"
    r: 1
    g: 0
    b: 0
    h: 1
    s: 1
    l: 1

  setChannel: (channel, v)->
    c = @state.color.withChannel channel, v = bound 0, v, 1

    toSet = switch channel
      when "r", "g", "b" then h:c.h, s:c.s, l:c.l, color:c
      else r:c.r, g:c.g, b:c.b, color:c
    toSet[channel] = v

    @setState toSet
