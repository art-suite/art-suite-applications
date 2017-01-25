Foundation = require 'art-foundation'
{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
  isNumber
} = Foundation

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class PutItem extends TableApiBaseClass
  ###
  IN: params:
    table:                  string (required)

  ###
  _translateParams: (params) =>
    @_translateItem params
    @_translateOptionalParams params
    @_target

  _translateItem: (params) =>
    {item, data} = params
    item ||= data
    throw new Error "item or data required" unless item
    @_target.Item = @_encodeItem item
    @_target

  ReturnConsumedCapacity: 'INDEXES | TOTAL | NONE',
  ReturnItemCollectionMetrics: 'SIZE | NONE',
  ReturnValues: 'NONE | ALL_OLD | UPDATED_OLD | ALL_NEW | UPDATED_NEW'

  _translateOptionalParams: (params) ->
    @_translateConditionExpressionParam params
    @_translateConstantParam params, "returnConsumedCapacity"
    @_translateConstantParam params, "returnItemCollectionMetrics"
    @_translateConstantParam params, "returnValues"
