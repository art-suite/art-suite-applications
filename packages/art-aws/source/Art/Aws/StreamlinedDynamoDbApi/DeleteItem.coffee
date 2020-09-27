{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
  isNumber
} = require 'art-standard-lib'

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class DeleteItem extends TableApiBaseClass
  ###
  IN: params:
    table:                  (required) string
    key:                    (required) see TableApiBaseClass._translateKey
    conditionExpression:  (optional) see TableApiBaseClass._translateConditionExpressionParam
    returnConsumedCapacity: (optional) see TableApiBaseClass._translateConsumedCapacity
  ###
  _translateParams: (params) ->
    @_translateKey params
    @_translateOptionalParams params
    @_target

  _translateOptionalParams: (params) ->
    @_translateConditionExpressionParam params
    @_translateConstantParam params, "returnConsumedCapacity"
    @_translateConstantParam params, "returnItemCollectionMetrics"
    @_translateConstantParam params, "returnValues"
