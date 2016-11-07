###
Used for buidling the minimal node.js code to deploy for production.
Right now, this is tested with HEROKU, but it should work in other cases.

Basically, you will build a single JS file that inludes:

  require and init your pipelines
  require this file

See art-ery-heroku-dev for a concrete example. In fact, you can use that repository
as a starting point. All you need to do is require your own pipelines in
the index.coffe file.

###

require 'art-aws/Server'

{Validator} = require 'art-foundation'

optionsValidator = new Validator
  loadPipelines:  "required function"
  Config:         "required"

module.exports = class Server
  @start: (options) ->
    optionsValidator.validate {loadPipelines, Config} = options
    .then -> (require './Node').init Config: Config
    .then -> loadPipelines()
    .then -> (require 'art-ery/Server').start
      numWorkers:   process.env.WEB_CONCURRENCY || 1
      port:         process.env.PORT

###
# CaffeineScript:

&ArtAws/Server

include &ArtFoundation

optionsValidator = new Validator
  loadPipelines:  "required function"
  Config:         "required object"

class Server
  @start: (options extract loadPipelines Config) ->
    optionsValidator.validate options
    then &Node.init Config: Config
    then loadPipelines()
    then &ArtEry/Server.start
      numWorkers:   process.env.WEB_CONCURRENCY || 1
      port:         process.env.PORT
###