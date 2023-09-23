module.exports = {
  defineModelsForAllPipelines: function () {
    throw new Error(
      "DEPRICATED: &ArtEry/Flux.defineModelsForAllPipelines()\nUSE: &@ArtSuite/ArtPipelineModels.defineModelsForAllPipelines()"
    );
  },
  defineArtEryPipelineFluxModels: function () {
    throw new Error(
      "DEPRICATED: &ArtEry/Flux.defineArtEryPipelineFluxModels()\nUSE: &@ArtSuite/ArtPipelineModels.defineModelsForAllPipelines()"
    );
  },
};
