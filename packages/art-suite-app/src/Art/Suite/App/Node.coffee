{
  defineModule
  log
  Promise
  inspect
  formattedInspect
  deepMerge
} = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'

defineModule module, class Node

  @configureArtAws: ({artAws}) -> ArtAws.configure artAws
  @configureArtEry: ({artEry}) -> ArtEry.configure artEry

  ###
  IN:
    process.env
      artSuiteAppEnvironment: string
      artSuiteAppConfig:      JSON object structure
  ###
  @init: ({Config, environmentName = "Development"}) ->
    envConfig = if process.env.artSuiteAppConfig
      try
        JSON.parse process.env.artSuiteAppConfig
      catch e
        log.error "\nInvalid 'artSuiteAppConfig' environment. Must be valid JSON.\nprocess.env.artSuiteAppConfig =\n  #{process.env.artSuiteAppConfig}\n\nerror: #{e}\n"
        null

    environmentName ||= process.env.artSuiteAppEnvironment

    environment = Config.current = deepMerge null,
      Config.Environments[environmentName]
      envConfig

    log artSuiteApp: environment: environment

    throw new Error "Environment not found #{inspect environment} in Config.Environments: #{formattedInspect Object.keys Config?.Environments?.modules}" unless environment

    Promise
    .then => @configureArtAws environment
    .then => @configureArtEry environment
