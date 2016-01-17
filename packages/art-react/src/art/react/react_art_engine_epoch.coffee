define [
  'art.foundation'
], (Foundation) ->
  {log, merge, clone, peek, inspect, timeout, BaseObject, Epoch, globalCount, stackTime, isWebWorker, timeout} = Foundation

  # bind to GlobalEpochCycle if not web-worker
  unless isWebWorker
    timeout 0, ->
      require ['lib/art/engine/core/global_epoch_cycle'], (GlobalEpochCycle) ->
        GlobalEpochCycle.singleton.includeReact ReactArtEngineEpoch.singleton

  class ReactArtEngineEpoch extends Epoch
    @singletonClass()

    addChangingComponent: (component)->
      @queueItem component

    processEpochItems: (changingComponents)->
      globalCount "ReactArtEngineEpoch processEpochItems", stackTime =>
        for component in changingComponents
          component._applyPendingState()


