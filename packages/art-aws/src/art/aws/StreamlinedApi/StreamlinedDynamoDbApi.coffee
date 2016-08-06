{lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten, isString, compactFlatten, deepEachAll, uniqueValues} = require 'art-foundation'
# {deepDecapitalizeAllKeys, deepCapitalizeAllKeys} = require './Tools'

module.exports = class StreamlinedDynamoDbApi

  # all dynamoDbConstants in lowerCamelCase, plus some aliases
  createConstantsMap =

    # aliases
    string: 'S'
    number: 'N'
    binary: 'B'
    bothImages: 'NEW_AND_OLD_IMAGES'

  for dynamoDbConstant in wordsArray """
      HASH RANGE
      ALL KEYS_ONLY INCLUDE
      S N B
      NEW_IMAGE OLD_IMAGE NEW_AND_OLD_IMAGES
      """
    createConstantsMap[lowerCamelCase dynamoDbConstant] = dynamoDbConstant

  @getKeySchemaAttributes: getKeySchemaAttributes = (createParams) ->
    out = []
    deepEachAll createParams, (v, k) ->
      if k == "KeySchema"
        for key in v
          out.push key.AttributeName
    uniqueValues out.sort()

  ###
  IN:
    attributes:
      myHashKeyName:    'string'
      myRangeKeyName:   'string'
      myNumberAttrName: 'number'
      myBinaryAttrName: 'binary'
  ###
  @translateAttributes: (params, target = {}, keySchemaAttributes) ->
    defs = params.attributes || params.attributeDefinitions || id: 'string'
    target.AttributeDefinitions = if isPlainObject defs
      for k, v of defs when !keySchemaAttributes || k in keySchemaAttributes
        AttributeName:  k
        AttributeType:  createConstantsMap[v.toLowerCase()] || v
    else defs

    target

  ###
  IN:
    key:
      myHashKeyName:  'hash'
      myRangeKeyName: 'range'

      OR: "hashKeyField"
      OR: "hashKeyField/rangeKeyField"
        NOTE: you can use any string format that matches /[_a-zA-Z0-9]+/g
  ###
  @translateKey: (params, target = {}) ->
    keySchema = params.key || params.keySchema || id: 'hash'

    target.KeySchema = if isPlainObject keySchema
      for k, v of keySchema
        AttributeName:  k
        KeyType:        createConstantsMap[v.toLowerCase()] || v
    else if isString keySchema
      [hashKeyField, rangeKeyField] = keySchema.match /[_a-zA-Z0-9]+/g
      compactFlatten [
        {AttributeName: hashKeyField, KeyType: 'HASH'}
        {AttributeName: rangeKeyField, KeyType: 'RANGE'} if rangeKeyField
      ]

    target

  ###
  IN:
    provisioning:
      read: 5
      write: 5
  ###
  @translateProvisioning: (params, target = {}) ->
    provisioning = params?.provisioning  || params?.provisionedThroughput || {}
    target.ProvisionedThroughput =
      ReadCapacityUnits:  provisioning.read  || provisioning.readCapacityUnits  || 1
      WriteCapacityUnits: provisioning.write || provisioning.writeCapacityUnits || 1

    target

  ###
  IN:
    globalIndexes:
      myIndexName:
        "hashKey"           # see translateKey
        "hashKey/rangeKey"  # see translateKey

        OR

        key:          # see translateKey
        projection:   # see translateProjection
        provisioning: # see translateProvisioning
  ###
  @translateGlobalIndexes: (params, target = {}) =>
    if globalIndexes = params?.globalIndexes
      target.GlobalSecondaryIndexes = if isPlainObject globalIndexes
        for indexName, indexProps of globalIndexes
          _target = IndexName: indexName
          if isString indexProps
            @translateKey key: indexProps, _target
          else
            @translateKey indexProps, _target
          @translateProjection indexProps, _target
          @translateProvisioning indexProps, _target
          _target
      else globalIndexes

    target

  ###
  IN:
    localIndexes:
      myIndexName:
        "hashKey"           # see translateKey
        "hashKey/rangeKey"  # see translateKey

        OR

        key:          # see translateKey
        projection:   # see translateProjection
  ###
  @translateLocalIndexes: (params, target = {}) =>
    if localIndexes = params?.localIndexes  || params?.localSecondaryIndexes
      target.LocalSecondaryIndexes = if isPlainObject localIndexes
        for indexName, indexProps of localIndexes
          _target = IndexName: indexName
          if isString indexProps
            @translateKey key: indexProps, _target
          else
            @translateKey indexProps, _target
            @translateProjection indexProps, _target
          _target
      else globalIndexes

    target

  @translateProjection: (params, target = {}) ->
    projection = params?.projection || type: 'all'
    target.Projection = out =
      ProjectionType: createConstantsMap[projection.type] || if projection.attributes then 'INCLUDE' else 'ALL'
    out.NonKeyAttributes = projection.attributes if projection.attributes
    out

  ###
  IN:
    attributes:     see translateAttributes
    globalIndexes:  see translateGlobalIndexes
    key:            see translateKey
    provisioning:   see translateProvisioning
    localIndexes:   see translateLocalIndexes

  NOTE:
    DynmoDb requires that attributes only list attributes used in the primary and index keys.
    BUT, translateCreateTableParams takes care of removing the extra fields from your list if present.

  ###
  @translateCreateTableParams: (params, target = {}) =>
    throw new Error "tableName required" unless params.tableName
    target.TableName = params.tableName
    @translateAttributes params, target, getKeySchemaAttributes [
      @translateGlobalIndexes params, target
      @translateLocalIndexes params, target
      @translateKey params, target
    ]
    @translateProvisioning params, target
    target
