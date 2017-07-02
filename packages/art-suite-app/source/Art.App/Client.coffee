{
  defineModule
  log
  merge
  timeout
  Promise
  session
  initArtSuiteApp
} = require 'art-suite'

defineModule module, class Client

  ###
  IN: options:
    all options are passed to:
      initArtSuiteApp options

      specifically, you should see:
        Art.Foundation.ConfigRegistry.configure options
        Art.Engine.FullScreenApp.init options

  EFFECT: Does everything initArtSuiteApp does PLUS initializes Ery
  ###
  @initArtSuiteClient: (options) =>
    initArtSuiteApp options