module.exports =
  params: "[pipeline]"
  action: ({args:[pipelineName]}) ->
    Neptune.Art.Foundation.log  pipelineName:pipelineName
    if pipelineName
      "#{pipelineName}": Neptune.Art.Ery.pipelines[pipelineName].getPipelineReport()
    else
      Neptune.Art.Foundation.newObjectFromEach Neptune.Art.Ery.pipelines, (pipeline) ->
        pipeline.getPipelineReport()
