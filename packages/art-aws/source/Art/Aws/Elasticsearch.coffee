RestClient = require 'art-rest-client'
{compactFlatten, mergeInto, object, log, present, defineModule, parseUrl, peek, Promise,merge} = require 'art-standard-lib'

{config} = Config = require "./Config"

aws4 = require 'aws4'

{BaseClass} = require 'art-class-system'

defineModule module, class Elasticsearch extends BaseClass
  constructor: (options) ->
    super
    {@host, @index, @type, @parentField, @routingField} = @options = merge config.elasticsearch, options
    [__, @protocol, __, @domain, __, @port] = @host.match urlRegexp

    # @client = new (require 'elasticsearch').Client {@host}

  # mergeInto @prototype, object w("get"),
  #   (key) -> (options) ->
  #     @client[key] options

  # IN: options: type, index, id
  get: (params) ->
    # {index, type, id, routing, parent} = @normalizeEntryRequestParams params
    # @client.get {index, type, id, routing, parent}
    aws4.sign
      host: @domain
      service: 'es'
      path:'/'

    RestClient.getJson @getEntryUrl options

  indicesGet: (params) ->

  @property "elasticsearchType elasticsearchIndex"

  getIndexUrl:      (options) -> "#{@host}/#{options.index}"
  getIndexTypeUrl:  (options) -> "#{@getIndexUrl options}/#{options.type}"
  getSearchUrl:     (options) -> "#{@getIndexTypeUrl options}/_search"

  getEntryBaseUrl:  (options) -> "#{@getIndexUrl     options}/#{options.type}/#{options.id}"
  getEntryUrl:      (options) -> "#{@getEntryBaseUrl options}#{@getEntryUrlParams options}"
  getUpdateUrl:     (options) -> "#{@getEntryBaseUrl options}/_update#{@getEntryUrlParams options}"

  ###
  IN: options:
    data:         (object) field data
    routingField: (string) field-name to use for routing
    parentField:  (string) field-name for parent
  ###
  getEntryUrlParams: (options) ->
    {data, routing, parent} = options
    params = compactFlatten [

      "routing=#{encodeURIComponent present}" if present routing
      "parent=#{encodeURIComponent parent}"   if present parent
    ]

    "?#{params.join "&"}"


  normalizeEntryRequestParams: (params) ->
    {data} = params

    if @routingField
      unless present routingValue = data?[@routingField]
        throw new Error "routing field '#{@routingField}' is not present in data: #{formattedInspect data}"
      params.routing = data[@routingField]

    if @parentField
      unless present parentValue = data?[@parentField]
        throw new Error "parent field '#{@parentField}' is not present in data: #{formattedInspect data}"

      params.parent = data[@parentField]

    params.index   = @index
    params.type    = @type
    params
