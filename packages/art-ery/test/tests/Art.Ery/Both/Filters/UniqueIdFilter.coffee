{log, createWithPostCreate, isString, Validator} = require 'art-foundation'
{UniqueIdFilter} = require('art-ery').Filters
SimplePipeline = require '../SimplePipeline'
{assert} = require('art-testbench');

module.exports = suite: ->
  test "fields are set correctly", ->
    createWithPostCreate class MyPipeline extends SimplePipeline
      @filter UniqueIdFilter

    assert.eq MyPipeline.getFields().id.dataType, "string"

  test "create", ->
    createWithPostCreate class MyPipeline extends SimplePipeline
      @filter UniqueIdFilter

    (new MyPipeline).create {}
    .then ({id}) ->
      assert.match id, /^[-_a-zA-Z0-9\/\:]{12}$/
