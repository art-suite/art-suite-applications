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
} = require 'art-suite'
ArtAws = require 'art-aws'
{DynamoDbPipeline} = require 'art-ery-aws'

defineModule module, class Init
  @getSelectedEnvironmentName: (environments) =>
    query = parseQuery()

    env = query.env || query.artSuiteEnvironment || "development"

    log """
      Options
        ?env=development
          select which Config.Environments to use
          shortcuts:
            prod: production
            dev:  development
      """

    switch env
      when "production", "prod" then "Production"
      when "development", "dev" then "Development"
      else throw new Error "unknown 'env=#{env}' url query option. Expected: production, prod, development or dev"

  @getSelectedEnvironment: (Config) =>
    environmentName = @getSelectedEnvironmentName()
    log environmentName: environmentName
    environment = deepMerge Config.Environments[environmentName = upperCamelCase environmentName],
      artSuiteConfig = JSON.parse parseQuery().artSuiteConfig || "{}"

    throw new Error "environment not found for: #{environmentName}" unless environment

    log selectedEnvironment:
      environment: environment
      "Config.Environments.#{environmentName}": Config.Environments[environmentName = upperCamelCase environmentName]
      artSuiteConfig: artSuiteConfig

    environment

  @configure: (Config) ->
    {pusher, artAws, artEry} = Config.current = @getSelectedEnvironment Config

    global.pusher = new Pusher pusher.key, encrypted: true if global.Pusher
    ArtAws.configure artAws
    ArtEry.configure artEry

  ###
  IN: options:
    Config: is an object with:
      Config.Enviroments.Development should be set, since it's the default
      Config.Enviroments.* and you can have additional environments

    Component: React component to instantiate as the top component

    title: the title of this app. Sets the browser tab's title, also effects logging

    *: all options are passed to ArtEngine.FullScreenApp.init
      see that doc for more valid options (such as styleSheets and fontFamilies)

  EFFECT:
    Config.current will be set to the selected environment
  ###
  @init: (options) =>
    options.title ||= "ArtSuiteApp"
    {title, Component, Config} = options
    throw new Error "options.Component and options.Config.Environments.Development required" unless Component and Config?.Environments?.Development
    log "#{title}: initializing..."
    FullScreenApp.init options
    .then => @configure Config
    .then -> DynamoDbPipeline.createTablesForAllRegisteredPipelines()
    .then -> ArtEryFluxModel.defineModelsForAllPipelines()
    .then -> ArtEry.Session.singleton.loadSession()
    .then -> timeout 100
    .then -> Component.instantiateAsTopComponent()
    .then -> log "#{title}: started."
    .catch (e) -> log "#{title}: error initializing", e
