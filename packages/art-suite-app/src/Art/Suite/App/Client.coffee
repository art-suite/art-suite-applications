{
  defineModule
  upperCamelCase
  parseQuery
  log
  merge
  timeout
  Promise
  FullScreenApp
  ArtEry
  ArtEryFluxModel
  deepMerge
  ConfigRegistry
} = require 'art-suite'
ArtAws = require 'art-aws'
{DynamoDbPipeline} = require 'art-ery-aws'

defineModule module, class Init

  ###
  IN: options:
    Component: React component to instantiate as the top component

    title: the title of this app. Sets the browser tab's title, also effects logging

    all options are passed to:

      ConfigRegistry.configure options
      ArtEngine.FullScreenApp.init options

      See their respective Docs.
  ###
  @init: (options) =>
    ConfigRegistry.configure options

    options.title ||= "ArtSuiteApp"
    {title, Component} = options
    throw new Error "options.Component and options.Config.Environments.Development required" unless Component and Config?.Environments?.Development
    log "#{title}: initializing..."
    FullScreenApp.init options
    .then -> DynamoDbPipeline.createTablesForAllRegisteredPipelines()
    .then -> ArtEryFluxModel.defineModelsForAllPipelines()
    .then -> ArtEry.Session.singleton.loadSession()
    .then -> timeout 100
    .then -> Component.instantiateAsTopComponent()
    .then -> log "#{title}: started."
    .catch (e) -> log "#{title}: error initializing", e
