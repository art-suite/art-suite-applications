module.exports =
  params: "<pipelineName>"
  action: ({args:[pipelineName]}) ->
    (require 'art-ery').pipelines[pipelineName].createTableParams
