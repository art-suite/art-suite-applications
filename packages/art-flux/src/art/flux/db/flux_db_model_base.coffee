define [
  'art.foundation'
  '../core'
], (Foundation, {FluxStore, ModelRegistry, FluxModel}) ->
  {
    log, BaseObject, decapitalize, pluralize, pureMerge, shallowClone, isString,
    emailRegexp, urlRegexp, isNumber, nextTick, capitalize, inspect, isFunction, merge, objectWithout, shallowClone,
    time, globalCount
  } = Foundation
  {fluxStore} = FluxStore

  idRegExpStr = "[a-z0-9]+"
  isId = (v) -> isString(v) && v.match ///^#{idRegExpStr}$///i
  isHexColor = (v) -> isString(v) && v.match /^#([a-f0-9]{3})|([a-f0-9]{6})/i

  ###
  FluxDbModelBase

  Basic functionality for DB-like models (CRUD).
  To use: inherit and override at least _storeGet and possibly other overrides.
  ###
  class FluxDbModelBase extends FluxModel
    # TODO: We need a way to expire old stuff from localStorage
    @localStoreCacheEnabled = false #true

    # get from fluxStore, null if not present
    get: (key) ->
      fluxStore.get @_name, key

    # get from fluxStore or, if not present, call load
    # returns fluxRecord if in fluxStore, else null
    # use callback to get results regardless
    getOrLoad: (key, callback) ->
      if fluxRecord = @get key
        callback && fluxStore.onNextReady -> callback fluxRecord
      else
        @load key, callback
      fluxRecord

    load: (key, callback) ->
      @_storeGet key, (fluxRecord) =>
        # TODO: in the case where this is a RELOAD (i.e. there is already a fluxRecord in the fluxStore):
        #   We should keep the current record's data and status:200 state (assuming it is 200)
        #   until and only if this load succeeds.
        fluxRecord.data ||= data if data
        fluxStore.update @_name, key, fluxRecord
        if fluxRecord.data && FluxDbModelBase.localStoreCacheEnabled
          @_localStoreSet key, fluxRecord.data
        callback && fluxStore.onNextReady -> callback fluxRecord
      if FluxDbModelBase.localStoreCacheEnabled && data = @_localStoreGet key
        data: data
        status: 200

    ###
    calls _storePut (must be overriden by inheriting class)

    updates fluxRecord as progress is made:
      start: sets fluxRecord.pendingData to expected result
      success: sets data to most up-to-date value
      success or failure: removes fluxRecord.pendingData

    callback:
      signature: (fluxRecord) => null
      invoked on:
        fluxRecord.status changes
        success or failure

    sets additional fields on the fluxStore fluxRecord:
      putPendingCount: 0 or more. if more, then there is a pending put
      data: is set to what we think the updated data will be for immediate user viz
      oldData: what the data was before the put
      retry: if set, this is a function you can call to retry a failed put. signature: (fluxRecord) -> null
        NOTE: retry will also call the original callback which may still be waiting for a success.
          Most the time you'll just call retry() and let the original callback do the work.
        Note: If there were multiple posts that failed, retry will retry them all.
    ###
    put: (id, fields, callback) ->
      ourOldData = null
      ourRetry = null
      throw new Error "invalid id: #{inspect id}" if id == null || id == undefined || id == false

      fluxStore.update @name, id, (oldFields) =>
        res = merge oldFields,
          putPendingCount: (oldFields.putPendingCount || 0) + 1
          data: merge oldFields?.pendingData || oldFields?.data, fields
          oldData: ourOldData = shallowClone oldFields?.oldData || oldFields?.data
        res

      @_storePut id, fields, (putStatus) =>
        callback && fluxStore.onNextReady => callback putStatus

        return unless putStatus.status != "pending"

        if putStatus.status == 200

          fluxStore.update @name, id, (oldFields) =>
            if oldFields.status != "pending" && oldFields.status != 200
              @load id
            updatedData = merge oldFields.data, fields
            fluxStore.onNextReady => @_updateQueries updatedData
            putPendingCount = (oldFields.putPendingCount || 0) - 1
            res = merge oldFields,
              data: merge oldFields.data, fields

            delete res.putPendingCount if putPendingCount <= 0
            delete res.retry if res.retry == oldFields.retry
            delete res.oldData if ourOldData == res.oldData
            res
        else
          # error, undo changes if oldData is ourOldData
          fluxStore.update @name, id, (oldFields) =>
            merge oldFields,
              data: if ourOldData == oldFields.oldData then ourOldData else oldFields.data
              putPendingCount: (oldFields.putPendingCount || 0) - 1
              retry: ourRetry = (newCallback) ->
                ourRetry = =>
                  @put id, fields, (fluxRecord) =>
                    newCallback? fluxRecord
                    callback? fluxRecord

                if otherRetry = oldFields.retry
                  otherRetry (fluxRecord) =>
                    if fluxRecord.status == 200
                      return ourRetry()
                      newCallback? fluxRecord
                      callback? fluxRecord
                else
                  ourRetry()

      null

    ###
    Updates fluxStore on success, otherwise is a passthrough for _storePost
    SBD TODO: fluxStore will purge entries with no subscribers, won't POST fluxStore updates always result in a no-op
      since, by definition, there can be no subscribers yet?
    ###
    post: (fields, callback) ->
      @_storePost fields, (fluxRecord) =>
        if fluxRecord.status == 200
          @_updateQueries fluxRecord.data
          fluxStore.update @name, fluxRecord.data.id, fluxRecord

        callback && fluxStore.onNextReady => callback fluxRecord
      null

    ###################################
    # PRIVATE
    ###################################
    keyFromData: (data) -> data.id

    ##################################
    # overrides
    ##################################

    _updateQueries: (updatedRecordData) ->

    # _storeGet can return a fluxRecord if the data is immediately ready, if not, be sure to return null
    _storeGet:  (id, callback)         -> throw new Error "must override. Class: #{@className}"
    _storePut:  (id, fields, callback) -> throw new Error "must override. Class: #{@className}"
    _storePost: (fields, callback)     -> throw new Error "must override. Class: #{@className}"
