{eq, present, merge, isArray, object, defineModule, array, log, isString, formattedInspect, Promise} = require 'art-standard-lib'
{pipelines, UpdateAfterMixin, KeyFieldsMixin} = require 'art-ery'
ElasticsearchPipeline = require "./ElasticsearchPipeline"

defineModule module, ->
  ###
  Purpose:

  Example use:
    class UserSearch extends MirroredElasticsearchPipeline

      @setSourcePipeline "user"

      @mapping
        # field-types: https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html
        properties:
          displayName:        type: "text",     analyzer: "english"

          postCount:          type: "integer"
          topicCount:         type: "short"
          followerCount:      type: "integer"
          messageCount:       type: "integer"

          lastTopicCreatedAt: type: "long"
          lastPostCreatedAt:  type: "long"
          profileTopicId:     type: "keyword",  index: false

  ###
  class MirroredElasticsearchPipeline extends UpdateAfterMixin KeyFieldsMixin ElasticsearchPipeline
    @abstractClass()

    #####################
    # Declarable API
    #####################
    @declarable   sourcePipelineName: validate: isString
    @classGetter  sourcePipeline: -> pipelines[@getSourcePipelineName()]
    @getter       sourcePipeline: -> pipelines[@getSourcePipelineName()]

    #####################
    # Optional Overrides
    #####################
    ###
    IN:
      sourceData:
        extracted from sourcePipelineResponse:

        sourceData =
          sourcePipelineResponse.responseProps.updatedData ||
          sourcePipelineResponse.responseData ||
          sourcePipelineResponse.requestData

      parentRequestOrResponse:
        # NOTE: this should only be used for creating subrequests.
        # If this is called in response to a create/update, then it'll be the response to that action.
        # However, it could also be called by reindexAll, in which it may be the request object for reindex all

    OUT:
      promise.then (data) ->
      OR
      data (promise is optional)

      data: plain data-structure to be passed to elastic-search to index

    The returned data will be merged with any existing index data for the given key.
    Therefor, you only need to return updated fields. One quick test:

      sourceData = switch response.type
        when "update" then response.requestData
        when "create" then response.responseData
        else throw new Error "not supported"

    DEFAULT:
      The default implementation selects all the fields from sourceData that are
      in the properties defined by @mapping.
    ###

    getElasticsearchData: (sourceData, parentRequestOrResponse) ->
      object @getMapping().properties,
        when: (v, k) -> sourceData[k]?
        with: (v, k) -> sourceData[k]

    # Opposite of getElasticsearchData
    # override for custom elasticsearchDataFormat > applicationDbDataFormat
    # OUT: object (not a promise!)
    getApplicationData: (data) -> data

    ######################
    # PUBLIC IMPLEMENTATION
    ######################
    @postCreateConcreteClass: ->
      out = super

      throw new Error "sourcePipelineName invalid: #{formattedInspect getSourcePipelineName()}" unless isString @getSourcePipelineName()

      # TODO: implement deleteAfter in UpdateAfterMixin
      # @deleteAfter
      #   delete: "#{@getSourcePipelineName()}": (response) -> key: response.key

      @updateAfter
        create: "#{@getSourcePipelineName()}": (response) -> @_getElasticsearchUpdateProps response
        update: "#{@getSourcePipelineName()}": (response) -> @_getElasticsearchUpdateProps response

      @deleteAfter
        delete: "#{@getSourcePipelineName()}": ({responseData, key}) -> {key, data: responseData} if responseData

      out

    @handler
      # FIX one record's duplicate copies in elasticsearch
      # NO-TESTS, but it does work, at least as-of-now (2018-1-28) - it's hard to reliably reproduce duplicate records across shards.
      # USE? For when you have two or more records in different shards with the same ID
      # IN:
      #   key:    record-id
      #   props:  pretend: true - if you want to do a dry run
      # EFFECT: check to see if there is more than one copy of the same record on different elasticsearch shards
      #   If so, determine which one is correct and delete the others.
      fixDuplicateIds: (request)->
        id = request.key
        {pretend} = request.props
        Promise.all([
          request.subrequest request.pipelineName, "findDuplicateIds", id
          request.subrequest @sourcePipeline.name, "get", key: id, props: include: false
        ]).then ([elasticsearchResults, sourceRecord]) =>
          correctParams = @getEntryUrlParams sourceRecord
          foundCorrectElasticsearchRecord = null
          incorrectParams = []
          incorrectElasticsearchRecords = []
          for {_source} in elasticsearchResults
            if eq correctParams, params = @getEntryUrlParams _source
              throw new Error "found TWO correct records, WTF" if foundCorrectElasticsearchRecord
              foundCorrectElasticsearchRecord = _source
            else
              incorrectParams.push params
              incorrectElasticsearchRecords.push _source

          Promise.all([
            for source in incorrectElasticsearchRecords
              if pretend
                id
              else
                request.subrequest request.pipelineName, "delete",
                  key: id
                  data: source
          ]).then ->
            {
              "#{if pretend then 'pretend-' else ''}deleted": incorrectElasticsearchRecords.length
              key: id
              correctParams
              incorrectParams
            }

      # out: keys reindexed
      reindexFromElasticsearch: (request) ->
        {pretend} = request.props

        # we don't need any stored_fields to do this - just the _id
        query = merge request.data, stored_fields: []

        request.subrequest request.pipelineName, "elasticsearch", data: query, props: include: false
        .then (results) =>
          log reindexFromElasticsearch: {reindexing: !pretend, found: results.hits.hits.length}
          Promise.all(for hit in results.hits.hits
            do (hit) ->
              if pretend
                hit._id
              else
                request.subrequest request.pipelineName, "reindex", hit._id
                .then -> hit._id
          )

      reindex: (request) ->
        if request.data
          @_getElasticsearchUpdateProps request, request.data
          .then (updateProps) =>
            request.subrequest request.pipeline, "addOrReplace", updateProps
        else
          request.require request.key
          .then => request.subrequest @getSourcePipelineName(), "get",
            key: request.key
            returnResponseObject: true
            props: include: false
          .then (response)    => @_getElasticsearchUpdateProps response
          .then (updateProps) =>
            request.subrequest request.pipeline, "addOrReplace", updateProps

      # not efficient
      # only to be used in dev / small dbs
      reindexAll: (request) ->
        {pageLimit} = request.props

        @reindexPage request, null, pageLimit

    reindexPage: (request, lastEvaluatedKey, limit) ->
      stats = request.context.reindex ||=
        itemCount: 0
        pageCount: 0

      request.subrequest @getSourcePipelineName(), "getAll",
        returnResponse: true
        originatedOnServer: true
        props: {
          include: false
          lastEvaluatedKey
          limit
        }

      .then ({props: {lastEvaluatedKey, data: items}}) =>
        # log item0: items[0], count: items.length, lastEvaluatedKey: lastEvaluatedKey
        Promise.all(for data in items
          request.subrequest request.pipeline, "reindex", {data}
        ).then =>
          stats.itemCount += items.length
          stats.pageCount++
          log reindex: merge stats, {lastEvaluatedKey}
          if lastEvaluatedKey
            @reindexPage request, lastEvaluatedKey, limit
      .then -> stats

    @filter
      after: get: (response) ->
        response.withData response.pipeline.getApplicationData response.responseData

    ###############
    # PRIVATE
    ###############

    _getElasticsearchUpdateProps: (sourcePipelineResponse, sourceData)->
      sourceData ||= merge(
        sourcePipelineResponse.requestData
        sourcePipelineResponse.responseData
        sourcePipelineResponse.responseProps.updatedData
      )

      Promise.resolve @getElasticsearchData sourceData, sourcePipelineResponse
      .then (elasticsearchData) =>
        key:  sourceData?.id || sourcePipelineResponse.key
        data: @_getElasticsearchDataWithRouting elasticsearchData, sourceData

    _getElasticsearchDataWithRouting: (elasticsearchData, sourceData) ->
      routingField = @class.getRoutingField()
      parentField = @class.getParentField()

      elasticsearchData = object elasticsearchData if routingField || parentField

      if routingField
        unless present elasticsearchData[routingField] ||= sourceData[routingField]
          throw new Error "missing routing field: #{formattedInspect {routingField, requestData, sourceData}}"

      if parentField
        unless present elasticsearchData[parentField] ||= sourceData[parentField]
          throw new Error "missing parent field: #{formattedInspect {parentField, requestData, sourceData}}"

      elasticsearchData
