Foundation = require 'art-foundation'
{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
} = Foundation

TableApiBaseClass = require './TableApiBaseClass'

module.exports = class CreateTable extends TableApiBaseClass

  constructor: ->
    super
    @_requiredAttributes = {}

  ###
  IN: params:
    table:      string (required)
    attributes:     see _translateAttributes
    globalIndexes:  see _translateGlobalIndexes
    key:            see _translateKey
    provisioning:   see _translateProvisioning
    localIndexes:   see _translateLocalIndexes

  NOTE:
    DynamoDb requires that attributes only list attributes used in the primary and index keys.
    BUT, _translateParams takes care of removing the extra fields from your list if present.

  ###
  _translateParams: (params) =>
    @_requiredAttributes = {}
    @_translateGlobalIndexes params
    @_translateLocalIndexes params
    @_translateKey params, @_target
    @_translateAttributes params
    @_target.BillingMode = if @_isPayPerRequest params
      "PAY_PER_REQUEST"
    else
      @_translateProvisioning params, @_target
      "PROVISIONED"
    @_target

  _isPayPerRequest: (params) ->
    (params.billingMode || params.BillingMode) == "PAY_PER_REQUEST" ||
    (!params.provisioning && !params.provisionedThroughput)


  # _getKeySchemaAttributes: (createParams) ->
  #   out = []
  #   deepEachAll createParams, (v, k) ->
  #     if k == "KeySchema"
  #       for key in v
  #         out.push key.AttributeName
  #   uniqueValues out.sort()

  ###
  IN:
    attributes:
      myHashKeyName:    'string'
      myRangeKeyName:   'string'
      myNumberAttrName: 'number'
      myBinaryAttrName: 'binary'
  ###
  _translateAttributes: (params, requiredAttributes = @_requiredAttributes) ->
    defs = params.attributes || id: 'string'
    @_target.AttributeDefinitions = if isPlainObject defs
      for attributeName in Object.keys(requiredAttributes).sort()
        type = defs[attributeName]
        throw new Error "Required attribute definition for '#{attributeName}'' not present. Please add it to 'attributes'." unless type
        AttributeName:  attributeName
        AttributeType:  @_normalizeConstant type
    else defs

    @_target

  ###
  IN:
    key:
      myHashKeyName:  'hash'
      myRangeKeyName: 'range'

      OR: "hashKeyField"
      OR: "hashKeyField/rangeKeyField"
        NOTE: you can use any string format that matches /[_a-zA-Z0-9]+/g
  ###
  _translateKey: (params, target = {}) ->
    keySchema = params.key || params.keySchema || id: 'hash'

    target.KeySchema = if isPlainObject keySchema
      for k, v of keySchema
        AttributeName:  k
        KeyType:        @_normalizeConstant v
    else if isString keySchema
      [hashKeyField, rangeKeyField] = keySchema.split "/"

      compactFlatten [
        {AttributeName: hashKeyField, KeyType: 'HASH'}
        {AttributeName: rangeKeyField, KeyType: 'RANGE'} if rangeKeyField
      ]

    for {AttributeName} in target.KeySchema
      @_requiredAttributes[AttributeName] = true

    target

  ###
  IN:
    provisioning:
      read: 5
      write: 5
  ###
  _translateProvisioning: (params, target = {}) ->
    provisioning = params?.provisioning  || params?.provisionedThroughput || {}
    target.ProvisionedThroughput =
      ReadCapacityUnits:  provisioning.read  || provisioning.readCapacityUnits  || 1
      WriteCapacityUnits: provisioning.write || provisioning.writeCapacityUnits || 1

    target

  ###
  IN:
    globalIndexes:
      myIndexName:
        "hashKey"           # see _translateKey
        "hashKey/rangeKey"  # see _translateKey

        OR

        key:          # see _translateKey
        projection:   # see _translateProjection
        provisioning: # see _translateProvisioning
  ###
  _translateGlobalIndexes: (params) =>
    if globalIndexes = params?.globalIndexes
      @_target.GlobalSecondaryIndexes = if isPlainObject globalIndexes
        for indexName, indexProps of globalIndexes
          _target = IndexName: indexName
          if isString indexProps
            @_translateKey key: indexProps, _target
          else
            @_translateKey indexProps, _target
          @_translateProjection indexProps, _target
          @_translateProvisioning indexProps, _target unless @_isPayPerRequest params
          _target
      else globalIndexes

    @_target

  ###
  IN:
    localIndexes:
      myIndexName:
        "hashKey"           # see _translateKey
        "hashKey/rangeKey"  # see _translateKey

        OR

        key:          # see _translateKey
        projection:   # see _translateProjection
  ###
  _translateLocalIndexes: (params) =>
    if localIndexes = params?.localIndexes  || params?.localSecondaryIndexes
      @_target.LocalSecondaryIndexes = if isPlainObject localIndexes
        for indexName, indexProps of localIndexes
          _target = IndexName: indexName
          if isString indexProps
            @_translateKey key: indexProps, _target
          else
            @_translateKey indexProps, _target
          @_translateProjection indexProps, _target
          _target
      else globalIndexes

    @_target

  _translateProjection: (params, target = {}) ->
    projection = params?.projection || type: 'all'
    type = if isString projection then projection else projection.type
    target.Projection = out =
      ProjectionType: @_normalizeConstant type, if projection.attributes then 'INCLUDE' else 'ALL'
    out.NonKeyAttributes = projection.attributes if projection.attributes
    out

