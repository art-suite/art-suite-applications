module.exports =
  params: "[pipeline]"
  action: ({args:[pipelineName]}) ->
    Neptune.Art.Foundation.log  pipelineName:pipelineName
    pipelines:
      if pipelineName
        "#{pipelineName}": Neptune.Art.Ery.pipelines[pipelineName].getPipelineReport()
      else
        Neptune.Art.Foundation.object Neptune.Art.Ery.pipelines, (pipeline) ->
          pipeline.getPipelineReport()

    afterEventsFilter: Neptune.Art.Ery.Filters.AfterEventsFilter.handlers
