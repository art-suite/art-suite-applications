{defineModule, log, mergeInto, each, lowerCamelCase} = require 'art-standard-lib'

defineModule module, -> (superClass) -> class StateFieldsMixin extends superClass

  @extendableProperty stateFields: {}

  ###
  Declare state fields you intend to use.
  IN: fields
    map from field names to initial values

  EFFECTS:
    initializes @state
    declares @getters and @setters for each field
  ###
  @stateFields: sf = (fields) ->
    @extendStateFields fields
    each fields, (initialValue, field) =>
      @addSetter field, (v) -> @setState field, v
      @addGetter field, -> @state[field]
      if initialValue == true || initialValue == false
        @::[log lowerCamelCase "toggle #{field}"] = ->
          @setState field, !@state[field]

  # ALIAS
  @stateField: sf
