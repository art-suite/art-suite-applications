module.exports =
  params: "<pipelineName>"
  action: ({args:[table]}) ->
    {fields, normalizedFields} = (require 'art-ery').pipelines[table]
    fields: fields
    normalizedFields: normalizedFields

