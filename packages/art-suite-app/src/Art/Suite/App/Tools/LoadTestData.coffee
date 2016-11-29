module.exports =
  params: "[pipelineName]"
  action: (options) ->
    {args:[requestedPipelineName], getPlainTestData} = options
    (require './CreateTables').action options
    .then ->
      {
        isString, log, w, lowerCamelCase, isPlainObject, merge, isString, pluralize, present
        isPlainArray
        Promise
        array
      } = require 'art-foundation'
      {pipelines} = require 'art-ery'

      requestedPipelineName = null unless isString(requestedPipelineName) && present requestedPipelineName

      {UuidFilter} = (require 'art-ery').Filters
      UuidFilter.alwaysForceNewIds = false

      promises = array pipelines,
        when: (pipeline, pipelineName) -> !requestedPipelineName || requestedPipelineName == pipelineName
        with: (pipeline, pipelineName) ->
          records = getPlainTestData(pipelineName) || []
          log "loading #{pipelineName} (#{records.length} records)..." if records.length > 0



          recordLoadPromises = if serial = true
            # serial
            serializer = new Promise.Serializer
            array records, (record, i) ->
              serializer.then ->
                log "loading #{pipeline.getName()}: #{i+1}/#{records.length}"
                pipeline.create originatedOnServer: true, data: record
                .catch (error) ->
                  log.error "loading #{pipeline.getName()}: #{i+1}/#{records.length} FAILED"
                  createRejected: {error, record}
          else
            array records, (record) ->
              pipeline.create originatedOnServer: true, data: record
              .catch (error) -> createRejected: {error, record}

          Promise.all recordLoadPromises
          .then (list) ->
            rejectList = (a.createRejected for a in list when a?.createRejected)
            merge
              pipeline: pipelineName
              recordsLoaded: list.length
              , if rejectList.length > 0
                rejects: rejectList
                recordsLoaded: list.length - rejectList.length
                failures: rejectList.length

      Promise.all promises
      .then (results) ->
        tablesLoaded: results
