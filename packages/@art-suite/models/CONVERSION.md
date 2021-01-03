
# Things to patch in ArtFlux

```
# global init can just be copied over
global.artSuiteModelsInit = global.artFluxInit
```

```coffeescript
class FluxModel extends Model

  # Deprecated API methods
  fluxStoreEntryUpdated:  (entry) -> storeEntryUpdated  entry
  fluxStoreEntryAdded:    (entry) -> storeEntryAdded    entry
  fluxStoreEntryRemoved:  (entry) -> storeEntryRemoved  entry
  storeGet:               (key)   -> @getModelRecord key
  updateStore:            (key, modelRecord) -> @updateModelRecord key, modelRecord

  ###################################################
  # localStorage helper methods
  ###################################################
  # These need to be provided in FluxModel for backwards compatbility

  _localStoreKey: (id) -> "model:#{@_name}:#{id}"

  _localStoreGet: (id) ->
    if data = localStorage.getItem @_localStoreKey id
      JSON.parse data
    else
      null

  _localStoreSet: (id, data) -> localStorage.setItem @_localStoreKey(id), JSON.stringify data

```

This could just be adapted, but it sure would be nice to actually updated EpochClass... My plan is to let each
EpochClass instance declare where it should be in the "global epoch." I'd also like to simplify the global epoch, if possible.

```


# TODO 2020-12-31: Store should automatically bind to a standard global epoch cycle as the "models" epoched-state
# bind to GlobalEpochCycle if not web-worker
if GlobalEpochCycle = Neptune.Art.Engine?.Core?.GlobalEpochCycle
  GlobalEpochCycle.singleton.includeFlux Store.singleton

```