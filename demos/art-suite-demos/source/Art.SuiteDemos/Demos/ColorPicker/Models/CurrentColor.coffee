Foundation = require '@art-suite/art-foundation'
Flux = require '@art-suite/art-flux'
Atomic = require 'art-atomic'

{log, createWithPostCreate, shallowClone, timeout, bound} = Foundation
{ApplicationState} = Flux
{rgbColor} = Atomic

createWithPostCreate module, class CurrentColor extends ApplicationState

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

  setColor: (color) ->
    @setState
      color: color
      r: color.r
      g: color.g
      b: color.b
      h: color.h
      s: color.s
      l: color.l

