require('../register');
require './StandardImport'
require 'art-aws/Server'
require '../'
require "art-foundation/testing"
.init
  artConfig:
    Art:
      Aws:
        credentials:
          accessKeyId:      'blah'
          secretAccessKey:  'blahblah'

        region:             'us-east-1'

        dynamoDb:
          endpoint:         'http://localhost:1337/localhost:8081'
      Ery: tableNamePrefix: "art-ery-aws-test."

  defineTests: -> require './tests'
