Foundation = require 'art-foundation'
{
  log
  lowerCamelCase, wordsArray
  isString
  isPlainArray
  isPlainObject
  isNumber
  isBoolean
  inspect
  upperCamelCase
} = Foundation

{apiConstantsMap} = require './Common'

module.exports = class TableApiBaseClass
  constructor: ->
    @_uniqueExpressionAttributeId = 0
    @_target = {}

  translateParams: (params) ->
    @_translateTableName params
    @_translateParams params
    @_target

  @translateParams: (params) ->
    new @().translateParams params

  @decodeDynamoData: decodeDynamoData = (data) ->
    if map = data.M
      out = {}
      for k, v of map
        out[k] = decodeDynamoData v
      out
    else if array = data.L
      decodeDynamoData v for v in array
    else if string = data.S
      string
    else if (number = data.N)?
      parseFloat number
    else if bool = data.BOOL
      !!bool
    else if data.NULL
      null
    else
      throw new Error "unknown dynamo data type: #{inspect data}"

  @decodeDynamoItem: (item) ->
    out = {}
    for k, v of item
      out[k] = decodeDynamoData v
    out

  #################################
  # OVERRIDES
  #################################
  _translateParams: -> throw new Error "must be overridden"

  #################################
  # PROTECTED
  # for use by inheriting classes
  #################################
  _encodeDynamoData: (data) ->
    ret = if isPlainObject data
      values = {}
      values[k] = @_encodeDynamoData v for k, v of data when v != undefined
      M: values
    else if isPlainArray data
      L: (@_encodeDynamoData v for v in data when v != undefined)
    else if isBoolean data
      BOOL: data
    else if isString data
      S: data
    else if isNumber data
      N: data.toString()
    else if data == null
      NULL: true
    else
      throw new Error "invalid data type: #{inspect data}"

  _decodeDynamoData: decodeDynamoData

  _encodeItem: (item) ->
    @_encodeDynamoData(item).M

  _addExpressionAttributeValue: (key, value) ->
    (@_target.ExpressionAttributeValues ||= {})[key] = @_encodeDynamoData value

  _addExpressionAttributeName: (attributeAlias, attributeName) ->
    (@_target.ExpressionAttributeNames ||= {})[attributeAlias] = attributeName

  _getNextUniqueExpressionAttributeId: ->
    @_uniqueExpressionAttributeId = (@_uniqueExpressionAttributeId || 0) + 1

  # OUT: returns the test as a STRING for DynamoDb expressions
  # EFFECT: adds to @_target.ExpressionAttributeNames && @_target.ExpressionAttributeValues
  _translateConditionExpression: (conditionalExpression) ->
    ret = if isPlainArray conditionalExpression
      expressions = for subExpression in conditionalExpression
        if isString subExpression
          subExpression
        else
          @_translateConditionExpression subExpression

      expressions.join ' '
    else
      expressions = for attributeName, test of conditionalExpression
        uniqueId = @_getNextUniqueExpressionAttributeId @_target
        attributeAlias = "#attr#{uniqueId}"
        @_addExpressionAttributeName attributeAlias, attributeName
        @_translateConditionExpressionField attributeAlias, test, uniqueId
      expressions.join ' AND '
    "(#{ret})"

  _translateConditionExpressionField: (attributeAlias, test, uniqueId) ->
    valueAlias = ":val#{uniqueId}"
    if (gte = test.gte) and (lte = test.lte)
      @_addExpressionAttributeValue (gteAlias = valueAlias + "Gte"), gte
      @_addExpressionAttributeValue (lteAlias = valueAlias + "Lte"), lte
      "#{attributeAlias} BETWEEN #{gteAlias} AND #{lteAlias}"
    else
      expression = if !isPlainObject value = test then "#{attributeAlias} = #{valueAlias}"
      else if (value = test.eq        )? then "#{attributeAlias} = #{valueAlias}"
      else if (value = test.lt        )? then "#{attributeAlias} < #{valueAlias}"
      else if (value = test.gt        )? then "#{attributeAlias} > #{valueAlias}"
      else if (value = test.lte       )? then "#{attributeAlias} <= #{valueAlias}"
      else if (value = test.gte       )? then "#{attributeAlias} >= #{valueAlias}"
      else if (value = test.beginsWith)? then "begines_with(#{attributeAlias}, #{valueAlias})"
      else throw new Error "no valid test detected in: #{attributeAlias}: #{inspect test}"
      @_addExpressionAttributeValue valueAlias, value
      expression


  _translateTableName: (params) ->
    throw new Error "table required" unless params.table
    @_target.TableName = params.table

  _translateIndexName: (params) ->
    @_target.IndexName = params.index if params.index

  _normalizeConstant: (constant, _default) ->
    throw new Error "constant '#{constant}' not found/supported" unless ret = apiConstantsMap[constant] || _default
    ret

  _translateConstantParam: (params, paramName) ->
    dynamoDbName = upperCamelCase paramName
    value = params[paramName]
    @_target[dynamoDbName] = @_normalizeConstant value if value
