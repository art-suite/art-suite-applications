###
For testing, be sure to start both:
  - corsproxy
  - start_dynamo_db_local_server.coffee

Corsproxy is needed because dynamoDb-local has a bug that causes it to not return CORS headers
when errors occur.
###

require 'caffeine-mc/register'

require 'art-aws/Server'
require '../'
require "art-foundation/testing"
.init
  artConfig:
    Art:Aws:
      credentials:
        accessKeyId:      'blah'
        secretAccessKey:  'blahblah'

      region:             'us-east-1'

      dynamoDb:
        endpoint:         'http://localhost:1337/localhost:8081'

  defineTests: -> require './tests'
