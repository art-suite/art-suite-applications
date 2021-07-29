{defineModule, log, present, isPlainArray, isString, isPlainObject, formattedInspect, array, object, each
} = require 'art-standard-lib'
{Validator} = require 'art-validation'

###
@primaryKey and @keyFields are synonymous
Usage:

  class MyModel extends KeyFieldsMixin Pipeline # or FluxModel or whatever
    # 1 key
    @primaryKey "foo"
    @keyFields "foo"
    @keyFields ["foo"]

    # 2 keys
    @keyFields "foo/bar"
    @keyFields ["foo", "bar"]

    # 3 keys
    @keyFields "foo/bar/baz"   # compound key with 3 fields
    @keyFields ["foo", "bar', "baz"]

    # Default:
    # @keyFields "id"

Note that order matters. @keyFields is a lists of strings. Forward slash (/) is
used as a delimiter, so it shouldn't be in the names of your key-fields. Ideally
each key field name should match: /[-._a-zA-Z0-9]+/
###

# when CafScript arrives, this line will just be:
# mixin PrimaryKeyMixin
defineModule module, -> (superClass) -> class KeyFieldsMixin extends superClass

  ###########################################
  # Class API
  # TODO: use Declarable
  ###########################################
  @getKeyFields:        -> @_keyFields
  @getKeyFieldsString:  -> @_keyFieldsString

  @primaryKey: keyFields = (a) ->
    if isString a           then @_keyFields = (@_keyFieldsString = a).split "/"
    else if isPlainArray a  then @_keyFieldsString = (@_keyFields = a).join "/"
    else throw new Error "invalid value: #{formattedInspect a}"

  @keyFields: keyFields

  ###########################################
  # Instance API
  ###########################################
  @getter
    keyFieldsString:  -> @_keyFieldsString  ?= @class._keyFieldsString
    keyFields:        -> @_keyFields        ?= @class._keyFields
    keyValidator:     -> @_keyValidator     ?= @class._keyValidator

  allKeyFieldsPresent: (data) ->
    for keyField in @keyFields
      return false unless present data[keyField]
    true

  isRecord: (data) -> isPlainObject(data) && @allKeyFieldsPresent data

  # Overrides FluxModel's implementation
  dataToKeyString: (a) ->
    @validateKey a
    array @keyFields, (field) -> a[field]
    .join "/"

  createPropsToKeyFunction: (keyField = "id") ->
    if keyField == "id"
      recordType = @pipelineName
      (props, stateField) ->
        propsField = stateField ? recordType
        props[propsField]?.id ? props[propsField + "Id"]

    else if matches = keyField.match /^(.+)Id$/
      [propsIdField, propsField] = matches
      (props) ->  props[propsField]?.id ? props[propsIdField]

    else
      (props) ->  props[keyField]

  @getter
    propsToKey: ->
      @_propsToKey ?= do =>
        if @keyFields.length == 1
          @createPropsToKeyFunction @keyFields[0]
        else
          fMap = object @keyFields,
            withKey: (v) -> v
            with: (v) => @createPropsToKeyFunction v
          (props) -> object fMap, (f) -> f props

  toKeyObject: (a) ->
    {keyValidator, keyFields} = @
    keyObject = @validateKey if isPlainObject a
      object @keyFields, (v) -> a[v]
    else if isString a
      if keyFields.length > 1
        splitInput = a.split "/"
        keyObject = object keyFields, (v, i) -> splitInput[i]
        if splitInput.length != keyFields.length
          log.warn KeyFieldsMixin_toKeyObject: {
            message: "wrong number of /-delimited fields in key-string"
            @pipelineName
            input: a
            splitInput
            keyFields
            usingKeyObject: keyObject
          }
        keyObject

      else
        "#{keyFields[0]}": a

    else {}
    if keyValidator
      # the important thing is the preprocessor is applied
      keyObject = keyValidator.preprocess keyObject
    keyObject

  dataWithoutKeyFields: (data) ->
    data && object data, when: (v, k) => not(k in @keyFields)

  validateKey: (key) ->
    {keyFields} = @
    each keyFields, (field) => unless present key[field]
      throw new Error "#{@class.getName()} missing key field(s): #{formattedInspect {missing: field, keyFields, key}}"
    key

  #################################
  # PRIVATE
  #################################
  @_keyFieldsString:  defaultKeyFieldsString = "id"
  @_keyFields:        [defaultKeyFieldsString]

  @_initFields: ->
    super
    fields = @getFields()
    @_keyValidator = new Validator keyFields = object @getKeyFields(),
      when: (v) => fields[v]
      with: (v) => fields[v]
