###
Used for buidling the minimal node.js code to deploy for production.
Right now, this is tested with HEROKU, but it should work in other cases.

Example user:

  require 'art-suite-app/Server'
  .start
    Config:           require './src/Art/Imikimi/Auth/Config'
    loadPipelines: -> require './src/Art/Imikimi/Auth/Pipelines'

  # NOTE: loadPipelines is a function so it can get called AFTER: require "art-aws/Server"

###

require 'art-aws/Server'

{Validator} = require 'art-foundation'

optionsValidator = new Validator
  loadPipelines:  "required function"
  Config:         "required"

module.exports = class Server
  @start: (options) ->
    optionsValidator.validate {loadPipelines, Config} = options
    .then -> (require './Node').init {Config}
    .then -> loadPipelines()
    .then -> (require 'art-ery/Server').start
      numWorkers:   process.env.WEB_CONCURRENCY || 1
      port:         process.env.PORT
