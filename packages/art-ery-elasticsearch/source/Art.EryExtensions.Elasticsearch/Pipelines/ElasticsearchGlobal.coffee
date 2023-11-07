{
  formattedInspect, log
  defineModule
  merge
  array
  object
  objectWithout
  mergeInto
} = require 'art-standard-lib'
{DeclarableMixin} = require 'art-class-system'
{Pipeline, pipelines} = require 'art-ery'

{config} = require "../ElasticsearchConfig"
{Aws4RestClient} = require 'art-aws'
{CommunicationStatus:{missing}} = require 'art-foundation'
ElasticsearchPipeline = require './ElasticsearchPipeline'

defineModule module, class ElasticsearchGlobal extends require './ElasticsearchPipelineBase'

  ###
  using @fields, generate the correct 'mappings' data for initializing the ElasticsearchPipelines index
  SEE:
    https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html
    https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html

  OUT: plain data-structue that is exactly what you can PUT to
    elasticsearch to initialize all mappings for the current elasticsearchPipelines.
  ###
  @getElasticsearchMappings: ->
    elasticsearchPipelines = array pipelines,
      when: (v) -> v instanceof ElasticsearchPipeline

    settings = {}
    mappings: object elasticsearchPipelines,
      key:  (pipeline) -> pipeline.elasticsearchType
      with: (pipeline) ->
        mapping = pipeline.getMapping()
        if mapping.settings
          mergeInto settings, mapping.settings
          objectWithout mapping, "settings"
        else
          mapping
    settings: settings

  @handlers

    # SEE: @getElasticsearchMappings
    initialize: (request)->
      request.subrequest request.pipeline, "indexExists"
      .then (exists) =>
        if !exists
          @normalizeJsonRestClientResponse request,
            @restClient.putJson @getIndexUrl(), @class.getElasticsearchMappings()
        else
          status: "alreadyInitialized"

    getInitializeParams: (request) -> @class.getElasticsearchMappings()

    getIndicies: (request) ->
      @restClient.getJson "/*"

    indexExists: (request) ->
      @restClient.getJson @getIndexUrl()
      .then -> request.success data: true
      .catch (e) =>
        if e.status == missing
          request.success data: false
        else
          @normalizeJsonRestClientError request, e

    createIndex: (request) ->
      @normalizeJsonRestClientResponse request, @restClient.putJson @getIndexUrl()

    deleteIndex: (request) ->
      request.require request.data?.force, "data.force=true required"
      .then =>
        @normalizeJsonRestClientResponse request, @restClient.deleteJson @getIndexUrl()
