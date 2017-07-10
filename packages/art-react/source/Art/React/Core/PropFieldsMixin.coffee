{defineModule, log, object, each, isPlainObject, merge, mergeInto} = require 'art-standard-lib'

defineModule module, -> (superClass) -> class PropFieldsMixin extends superClass

  normalizePropFieldValue = (name, value) ->
    default: value

  @extendableProperty(
    propFields: null
    (addPropFields) ->
      # NOTE, if propFields is null, @ will be global (window/self). Silly JavaScript.
      #   If @ as null, as it should be, we could just do:
      #     mergeInto @ ? {}, addPropFields
      mergeInto (if (isPlainObject @) then @ else {}), addPropFields
  )

  ###
  Declare prop fields you intend to use.
  IN: fields
    map from field names to:
      default-values

  FUTURE-NOTE:
    If we decide we want more options than just 'default-values',
    we can add a new declarator: @propFieldsWithOptions
    where the map-to-values must all be options objects.

  EFFECTS:
    used to define getters for @prop
  ###
  @propFields: sf = (fields) ->
    @extendPropFields fields
    each fields, (defaultValue, field) =>
      @addGetter field, -> @props[field]

  # ALIAS
  @propField: sf

  # could use: pureMerge @getPropFields(), props
  # but I'm concerned about performance.
  _preprocessProps: (props) ->
    log PropFieldsMixin: _preprocessProps: {props, @propFields}
    if propFields = @getPropFields()
      out = {}
      out[k] = v for k, v of propFields
      out[k] = v for k, v of props
      out
    else props
