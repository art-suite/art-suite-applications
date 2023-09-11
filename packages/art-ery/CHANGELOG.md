# v2.0

### Breaking Changes

1. `ArtEry.Flux.defineModelsForAllPipelines` is no longer called automatically. You must manually call it after loading all your pipelines. This change allows us to support non-global Model and Pipeline registries in the future.
2. `Pipeline.fluxModelMixin` is removed. Instead, a new subscription system has been added so that Models can subscribe to changes coming from the Pipeline.
