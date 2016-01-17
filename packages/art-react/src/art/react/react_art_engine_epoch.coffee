Foundation = require 'art.foundation'
{log, merge, clone, peek, inspect, timeout, BaseObject, Epoch, globalCount, stackTime, isWebWorker, timeout} = Foundation

module.exports = class ReactArtEngineEpoch extends Epoch
  @singletonClass()

  addChangingComponent: (component)->
    @queueItem component

  processEpochItems: (changingComponents)->
    globalCount "ReactArtEngineEpoch processEpochItems", stackTime =>
      for component in changingComponents
        component._applyPendingState()

# bind to GlobalEpochCycle if not web-worker
if ArtEngineCore = Neptune.Art.Engine.Core
  {GlobalEpochCycle} = ArtEngineCore
  GlobalEpochCycle.singleton.includeReact ReactArtEngineEpoch.singleton
