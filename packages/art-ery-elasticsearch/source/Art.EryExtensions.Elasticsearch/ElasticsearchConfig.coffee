{merge, defineModule, select, newObjectFromEach, mergeInto, Configurable} = require 'art-foundation'

defineModule module, class ElasticsearchConfig extends Configurable
  @defaults
    index:    "ArtEryElasticsearch"
    endpoint:
      "http://localhost:9200"