Foundation = require 'art-foundation'
FluxDbQueryModel = require '../db/flux_db_query_model'
{success, failure, pending, missing} = require '../core/flux_status'

{log, objectWithout} = Foundation

module.exports = class VolatileQueryModel extends FluxDbQueryModel

  _storeGet: (queryParam, callback) =>
    @_singlesModel._storeGet "", (allRequestStatus) =>
      log success: success
      if allRequestStatus.status != 200 #success
        callback objectWithout allRequestStatus, "fluxKey"
      else
        callback
          status: allRequestStatus.status
          data: for k, fields of allRequestStatus.data when fields[@_parameterizedField] == queryParam
            fields
    , true
