Foundation = require 'art-foundation'
{log, merge, clone, peek, inspect, Epoch, globalCount, stackTime, isWebWorker} = Foundation

module.exports = class ReactArtEngineEpoch extends Epoch
  @singletonClass()

  addChangingComponent: (component)->
    @queueItem component

  processEpochItems: (changingComponents)->
    globalCount "ReactArtEngineEpoch processEpochItems", stackTime =>
      for component in changingComponents
        component._applyPendingState()

# TODO: see Component's comment on ArtEngineCore
# bind to GlobalEpochCycle if not web-worker
if ArtEngineCore = global.Neptune.Art?.Engine?.Core
  {GlobalEpochCycle} = ArtEngineCore
  GlobalEpochCycle.singleton.includeReact ReactArtEngineEpoch.singleton
