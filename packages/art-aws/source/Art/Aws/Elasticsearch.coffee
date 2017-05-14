RestClient = require 'art-rest-client'
{mergeInto, object, log, present, defineModule, parseUrl, peek, Promise,merge} = require 'art-standard-lib'

{config} = Config = require "./Config"

{BaseClass} = require 'art-class-system'

defineModule module, class Elasticsearch extends BaseClass
  constructor: (options) ->
    super
    {@host} = @options = merge config.elasticsearch, options
    # @client = new (require 'elasticsearch').Client host: "http://localhost:9200"

  # mergeInto @prototype, object w("get"),
  #   (key) -> (options) ->
  #     @client[key] options

  # IN: options: type, index, id
  get: (options) ->
    RestClient.getJson @getEntryUrl options

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
    {data, routingField, parentField} = options
    params = compactFlatten [
      if routingField
        unless present routingValue = data[routingField]
          throw new Error "routing field '#{routingField}' is not present in data: #{formattedInspect data}"
        "routing=#{encodeURIComponent routingValue}"

      if parentField
        unless present parentValue = data[parentField]
          throw new Error "parent field '#{parentField}' is not present in data: #{formattedInspect data}"

        "parent=#{encodeURIComponent parentValue}"
    ]

    "?#{params.join "&"}"
