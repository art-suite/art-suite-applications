{defineModule, log} = require 'art-standard-lib'
Filter = require '../Filter'
Uuid = require 'uuid'
{FieldTypes} = require 'art-validation'

defineModule module, class UuidFilter extends Filter

  constructor: ->
    super
    log.warn "DEPRICATED: UuidFilter. USE: UniqueIdFilter"

  @alwaysForceNewIds: true
  @before
    create: (request) ->
      request.withMergedData
        id: if UuidFilter.alwaysForceNewIds
            Uuid.v4()
          else
            request.data.id || Uuid.v4()

  @fields
    id: FieldTypes.id
