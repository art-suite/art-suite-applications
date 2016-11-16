###
IN: options:
  load: [required] ->
    OUT: merged with Options
    EFFECT: all your pipelines, if any, area loaded

  package: your package.json file
    Example: package: require './package.json'

  Config, environmentName
    see Art.Suite.Node.Init

  createTables STUFF - what will that be?

configuration:
  Config.current = merge
    Config[environmentName]
    eval process.env.artSuiteApp || "null"
###
module.exports = (options)->
  (require 'art-foundation/buildCommander')
    package: options.package
    beforeActions: (commander)->
      {merge} = require 'art-foundation'
      require 'art-aws/Server'
      options = merge options, options?.load()
      (require './Node').init verbose: commander.verbose
      .then ->
        options

    actions: (require './src/Art/Suite/App/Tools').modules
