###
Used for buidling the minimal node.js code to deploy for production.
Right now, this is tested with HEROKU, but it should work in other cases.

Example user:

  require 'art-suite-app/Server'
  .start
    loadPipelines: -> require '...'

  # NOTE: loadPipelines is a function so it can get called AFTER: require "art-aws/Server"

###

require 'art-aws/Server'
require 'art-aws'
require 'art-ery'
{Validator, merge, log, Promise} = require 'art-foundation'

module.exports = class Server
  @start: (options) ->
    {loadPipelines} = options
    Promise.then -> (require './Node').init options
    .then -> loadPipelines?()
    .then ->
      (require 'art-ery/Server').start merge options,
        numWorkers:   process.env.WEB_CONCURRENCY || 1
        port:         process.env.PORT
    .catch (e) ->
      log "Error starting Art.Suite.App server", e