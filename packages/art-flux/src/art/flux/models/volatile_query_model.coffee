define [
  'art-foundation'
  '../db/flux_db_query_model'
], (Foundation, FluxDbQueryModel) ->
  {log, BaseObject, decapitalize, pluralize, pureMerge, shallowClone, isString,
  emailRegexp, urlRegexp, isNumber, nextTick, capitalize, inspect, isFunction, objectWithout} = Foundation

  class VolatileQueryModel extends FluxDbQueryModel

    _storeGet: (queryParam, callback) =>
      @_singlesModel._storeGet "", (allRequestStatus) =>
        if allRequestStatus.status != 200
          callback objectWithout allRequestStatus, "fluxKey"
        else
          callback
            status: allRequestStatus.status
            data: for k, fields of allRequestStatus.data when fields[@_parameterizedField] == queryParam
              fields
      , true
