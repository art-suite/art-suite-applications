module.exports = (options) ->
  {args:[requestedPipelineName], getPlainTestData} = options
  (require './CreateTables').action options
  .then ->
    {
      isString, log, w, lowerCamelCase, isPlainObject, merge, isString, pluralize, present
    } = require 'art-foundation'
    {pipelines} = require 'art-ery'

    requestedPipelineName = null unless isString(requestedPipelineName) && present requestedPipelineName

    {UuidFilter} = (require 'art-ery').Filters
    UuidFilter.alwaysForceNewIds = false

    promises = for pipelineName, pipeline of pipelines when !requestedPipelineName || requestedPipelineName == pipelineName

      do (pipelineName) ->
        records = getPlainTestData(pipelineName) || []
        log "loading #{pipelineName} (#{records.length} records)..." if records.length > 0
        newRecordPromises = for record in records
          do (record) ->

            pipeline.create originatedOnServer: true, data: record
            .catch (e) ->
              createRejected:
                error: e
                inputRecord: record
                outRecord: outRecord

        Promise.all newRecordPromises
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
