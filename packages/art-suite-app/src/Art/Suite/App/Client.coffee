{
  defineModule
  log
  merge
  timeout
  Promise
  ArtEry
  ArtEryFluxModel
  initArtSuiteApp
} = require 'art-suite'
ArtAws = require 'art-aws'
{DynamoDbPipeline} = require 'art-ery-aws'

defineModule module, class Client

  ###
  IN: options:
    all options are passed to:
      initArtSuiteApp options

      specifically, you should see:
        Art.Foundation.ConfigRegistry.configure options
        Art.Engine.FullScreenApp.init options

  EFFECT: Does everything initArtSuiteApp does PLUS initializes ArtEry
  ###
  @initArtSuiteClient: (options) =>
    initArtSuiteApp merge options,
      prepare:
        Promise.resolve options.prepare
        .then -> ArtEryFluxModel.defineModelsForAllPipelines()
        .then -> ArtEry.Session.singleton.loadSession()
        .then -> timeout 100 # I think this may be here the handle the icomoon loading problems. TODO - elliminate this!
