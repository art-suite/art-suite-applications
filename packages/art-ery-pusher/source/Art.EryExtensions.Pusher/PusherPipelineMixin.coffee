{defineModule, object} = require './StandardImport'

defineModule module, -> (superClass) -> class PusherPipelineMixin extends superClass
  @abstractClass?()
  @fluxModelMixin   require './PusherFluxModelMixin'

  ### getChannelsAndKeysToUpdateOnRecordChange
    IN: updated record's data
    OUT: channelName: keyValue
  ###
  getChannelsAndKeysToUpdateOnRecordChange: (updatedRecord) ->
    object @queries, (pipelineQuery) ->
      pipelineQuery.toKeyString updatedRecord

  getPusherChannel: (queryName, fluxKey) ->

  ### Add ArtEry filter
    NOTE: This Filter will run very first after the handler
    since it is defined in the mixin - before the body of the
    actual class is evaluated.

    This is fine for now, but if we ever want to push actual data, we may
    need this to run after other filters which refine said data.
  ###
  @filter           require './PusherFilter'
