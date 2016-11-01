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

###
module.exports = (options)->
  (require 'art-foundation/buildCommander')
    package: options.package #require './package.json'
    beforeActions: (commander)->
      {merge} = require 'art-foundation'
      require 'art-aws/Server'
      (require './node').init options = merge options, options.load()
      .then ->
        options

    actions: (require './src/Art/Suite/App/Tools').modules
