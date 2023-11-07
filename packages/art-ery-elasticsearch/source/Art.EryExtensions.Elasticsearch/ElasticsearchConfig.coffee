{merge, defineModule, select, newObjectFromEach, mergeInto} = require 'art-standard-lib'
{Configurable} = require 'art-config'

defineModule module, class ElasticsearchConfig extends Configurable
  @defaults
    index:    "ArtEryElasticsearch"
    endpoint:
      "http://localhost:9200"