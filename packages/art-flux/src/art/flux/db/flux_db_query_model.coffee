define [
  'art.foundation'
  './flux_db_model_base'
], (Foundation, FluxDbModelBase) ->
  {log, BaseObject, decapitalize, pluralize, pureMerge, shallowClone, isString,
  emailRegexp, urlRegexp, isNumber, nextTick, capitalize, inspect, isFunction, objectWithout} = Foundation

  ###
  FluxDbQueryModel

  Foundation for auto-created query models.

  Currently only supports differentiating query model names based on a single field-name.

  To use: inherit and override _storeGet (required)

  options:
    keyFromData: (singleRecordData) -> key # override the default keyFromData method
      should return the key used by this model to fetch the list, aggregate or derrivative "data"
      that contains the singleRecordData

    modelName: "string"
      Normally the model name is generated from the singlesModel name and the parameterized field.
      This allows you to set an arbitrary alternative model name.
      Capitalization of the first letter is automatically handled correctly no matter what you pass in.

  ###
  class FluxDbQueryModel extends FluxDbModelBase
    constructor: (singlesModel, parameterizedField, options)->
      super if options?.modelName
        decapitalize options?.modelName
      else
        pluralize(singlesModel.name) + "By" + capitalize parameterizedField

      @_singlesModel = singlesModel
      @_parameterizedField = parameterizedField
      @keyFromData = options.keyFromData || eval "(function(data) {return data['#{parameterizedField}'];})"
      @_options = options # used by derivative children
      @toFluxKey = options.toFluxKey if options.toFluxKey
