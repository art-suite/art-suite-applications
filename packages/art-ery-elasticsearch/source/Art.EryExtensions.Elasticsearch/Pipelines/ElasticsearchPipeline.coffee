{
  formattedInspect, log, present, isPlainObject, defineModule, snakeCase
  array, object, find
  compactFlatten
  objectWithout
  mergeInto
  isString
  merge
  isFunction
} = require 'art-standard-lib'
{DeclarableMixin} = require 'art-class-system'
{missing, clientFailure} = require 'art-communication-status'
{Pipeline, pipelines} = require 'art-ery'

{config} = require "../ElasticsearchConfig"

defineModule module, class ElasticsearchPipeline extends require './ElasticsearchPipelineBase'
  @abstractClass()

  ###################
  # DECLARATIVE API
  ###################

  ###
  set mapping

  SEE: https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html

  IN: the mapping for this pipeline's index+type

    NOTE: the elasticsearch API's mappings action can set all indexes and all types
    in one call. The mapping specified HERE, though, is only for the current pipeline's
    mapping. Each pipeline represents a specific elasticsearch-index and a specific
    elasticsearch-type.

    SO, the input value for @mapping is the plain-object-structure for just one index+type.
    The index and type will automatically be wrapped around the @mapping value you specified.

  example:

    declaration:

      @mapping
        _all:     enabled: false
        properties:
          title:  type: "text"
          name:   type: "text"
          age:    type: "integer"

    sent to elasticsearch:
      mappings:
        "#{@elasticsearchType}":
          _all:     enabled: false
          properties:
            title:  type: "text"
            name:   type: "text"
            age:    type: "integer"

  ###
  @declarable
    parentField:        validate: isString
    routingField:       validate: isString
    elasticsearchType:  validate: isString # default: snakeCase class.getName()
    mapping:      extendable: {}

  ###################
  @getter
    elasticsearchType:  -> @class._elasticsearchType ||= snakeCase @class.getName()
    indexTypeUrl:       -> "#{@getIndexUrl()}/#{@elasticsearchType}"
    searchUrl:          -> "#{@getIndexTypeUrl()}/_search"

  getEntryBaseUrl:  (id) -> "#{@getIndexUrl()}/#{@elasticsearchType}/#{id}"
  getEntryUrl:      (id, data) -> "#{@getEntryBaseUrl id}#{@getEntryUrlParams data}"
  getUpdateUrl:     (id, data) -> "#{@getEntryBaseUrl id}/_update#{@getEntryUrlParams data}"

  getEntryUrlParams:    (data) ->
    params = compactFlatten [
      if data? && routingField = @getRoutingField()
        if present routingValue = data[routingField]
          "routing=#{encodeURIComponent routingValue}"
        # else
        #   throw new Error "routing field '#{routingField}' is not present in data: #{formattedInspect data}"

      if data? && parentField = @getParentField()
        if present parentValue = data[parentField]
          "parent=#{encodeURIComponent parentValue}"
        # else
        #   throw new Error "parent field '#{parentField}' is not present in data: #{formattedInspect data}"
    ]

    "?#{params.join "&"}"

  getEntryUrlFromRequest: (request) ->
    {key, data} = request
    request.require present(key), "key required for #{request.type}: #{formattedInspect {key, data}}"
    .then => @getEntryUrl key, data

  @handlers
    findDuplicateIds: (request) ->
      request.subrequest request.pipelineName, "elasticsearch",
        data:
          size:   request.props.limit ? 100
          query:  term: _id: request.key
      .then (result) -> result.hits.hits

    get: (request) ->
      {key, data} = request
      @getEntryUrlFromRequest request
      .then (url) =>
        @normalizeJsonRestClientResponse request,
          @restClient.getJson url
          # @elasticsearchClient.get id: key, data: data
      .then (got) =>
        if got._source?
          request.success
            data: got._source
            elasticsearch: objectWithout got, "_source"

    # Adds or replaces a 'document' in the index
    # this is not "create" since it doesn't generate a key - the key must be provided
    addOrReplace: (request) ->
      {key, data} = request
      request.require present(key) && isPlainObject(data), "key and data required, #{formattedInspect {key, data}}"
      .then =>
        @normalizeJsonRestClientResponse request,
          @restClient.putJson @getEntryUrl(key, data), data

    # SEE: https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html
    # Actually, this is createOrUpdate
    # TODO: I'd probably rename this to createOrUpdate, but ArtEry.UpdateAfterMixin only supports "update" right now
    update: (request) ->
      {key, data} = request
      request.require present(key) && isPlainObject(data), "key and data required, #{formattedInspect {key, data}}"
      .then =>
        @normalizeJsonRestClientResponse request,
          @restClient.postJson @getUpdateUrl(key, data),
            doc:            data  # update fields in data
            doc_as_upsert:  true  # if doesn't exist, create with data
      .then (response) =>
        if response.status == clientFailure &&
            response.data?.error?.root_cause?[0]?.type == "version_conflict_engine_exception" &&
            isFunction @reindex
          request.subrequest request.pipelineName, "reindex", {key}
        else
          response

    # delete
    delete: (request) ->
      @getEntryUrlFromRequest request
      .then (url) =>
        @normalizeJsonRestClientResponse request,
          @restClient.deleteJson url
      .then (deleteResult) ->
        if deleteResult?.status == missing
          request.missing()
        else
          # deleteResult looks like:
          #   found: true
          #   _index: "imikimi_oz_test"
          #   _type: "topic_search"
          #   _id: "wCe2JvAH5L0g"
          #   _version: 2
          #   result: "deleted"
          #   _shards:
          #     total: 2
          #     successful: 1
          #     failed: 0
          request.success props: deleteResult

    ###
    perform a search

    Initially, data should just be the full elasticsearch API.

    But, I suspect we'll want some streamlined options.
    ###
    elasticsearch: (request) ->
      {data} = request
      @normalizeJsonRestClientResponse request,
        @restClient.postJson @getSearchUrl(), data
