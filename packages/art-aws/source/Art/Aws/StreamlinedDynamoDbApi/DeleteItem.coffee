Foundation = require 'art-foundation'
{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
  isNumber
} = Foundation

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class DeleteItem extends TableApiBaseClass
  ###
  IN: params:
    table:                  (required) string
    key:                    (required) see TableApiBaseClass._translateKey
    conditionalExpression:  (optional) see TableApiBaseClass._translateConditionalExpression
    returnConsumedCapacity: (optional) see TableApiBaseClass._translateConsumedCapacity
  ###
  _translateParams: (params) ->
    @_translateKey params
    @_translateOptionalParams params
    @_target

  _translateOptionalParams: (params) ->
    @_translateConsumedCapacity params
    @_translateConditionalExpression params
