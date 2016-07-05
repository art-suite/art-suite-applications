Dynasty = require 'dynasty'

credentials =
  accessKeyId: process.env.AWS_ACCESS_KEY_ID || "123"
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || "123"
  region: 'eu-west-1'

suite "Dynasty", ->
  @timeout 10000
  # test "thinngy", ->
  #   dynasty = Dynasty credentials, 'http://localhost:8081'
  #   dynasty.list()
  #   .then (resp) ->
  #     console.log resp
  #   .catch (err) ->
  #     console.error "error", err
