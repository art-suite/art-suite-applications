{log, createWithPostCreate, isString, Validator} = require '@art-suite/art-foundation'
{TimestampFilter} = require('art-ery').Filters
SimplePipeline = require '../SimplePipeline'
{FieldTypes} = require 'art-validation'
{assert} = require('art-testbench');

module.exports = suite: ->

  test "fields are set correctly", ->
    createWithPostCreate class MyPipeline extends SimplePipeline
      @filter TimestampFilter

    assert.eq MyPipeline.singleton.fields.createdAt, FieldTypes.secondsTimestamp
    assert.eq MyPipeline.singleton.fields.updatedAt, FieldTypes.secondsTimestamp

  test "create", ->
    createWithPostCreate class MyPipeline extends SimplePipeline
      @filter TimestampFilter

    MyPipeline.singleton.create data: {}
    .then ({createdAt, updatedAt, id}) ->
      assert.isNumber createdAt
      assert.isNumber updatedAt
      assert.eq createdAt, updatedAt
      id

    .then (id) ->
      MyPipeline.singleton.update key: id, data: foo: "bar"

    .then ({createdAt, updatedAt}) ->
      assert.isNumber createdAt
      assert.isNumber updatedAt
      assert.gte updatedAt, createdAt
