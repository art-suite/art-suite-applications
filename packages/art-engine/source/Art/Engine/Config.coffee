{w, Validator, defineModule, mergeInto, BaseClass, Configurable} = require '@art-suite/art-foundation'

defineModule module, class Config extends Configurable
  @defaults
    drawCacheEnabled: true
    partialRedrawEnabled: true
    showPartialDrawAreas: false