{
  defineModule
  log
  Promise
  inspect
  formattedInspect
  deepMerge
  parseQuery
  merge
} = require 'art-foundation'
ArtEry = require 'art-ery'
ArtAws = require 'art-aws'

defineModule module, class Node

  @configureArtAws: ({artAws}) -> ArtAws.configure artAws
  @configureArtEry: ({artEry}) -> ArtEry.configure artEry

  ###
  IN:
    process.env
      artSuiteEnvironment: string
      artSuiteConfig:      JSON object structure
  ###
  @init: ({Config, environmentName}) ->
    environmentName ||= process.env.artSuiteEnvironment || "Development"

    env = merge process.env, parseQuery()

    envConfig = if env.artSuiteConfig
      try
        parsedArtSuiteAppConfig = JSON.parse env.artSuiteConfig
      catch e
        log.error "\nInvalid 'artSuiteConfig' environment. Must be valid JSON.\nprocess.env.artSuiteConfig =\n  #{env.artSuiteConfig}\n\nerror: #{e}\n"
        null

    throw new Error "Config.Environments.#{environmentName} does not exist" unless Config.Environments[environmentName]

    environment = Config.current = deepMerge null,
      Config.Environments[environmentName]
      envConfig
      environment: environmentName

    log artSuiteApp:
      Config:
        current: environment
        "Environments.#{environmentName}": Config.Environments[environmentName]
      "process.env":
        artSuiteEnvironment: env.artSuiteEnvironment
        artSuiteConfig:      parsedArtSuiteAppConfig
      Neptune: Neptune

    throw new Error "Environment not found #{inspect environment} in Config.Environments: #{formattedInspect Object.keys Config?.Environments?.modules}" unless environment

    Promise
    .then => @configureArtAws environment
    .then => @configureArtEry environment
