{lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten, isString} = require 'art-foundation'
{deepDecapitalizeAllKeys, deepCapitalizeAllKeys} = require './Tools'

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

  ###
  IN:
    attributes:
      myHashKeyName:    'string'
      myRangeKeyName:   'string'
      myNumberAttrName: 'number'
      myBinaryAttrName: 'binary'
  ###
  @translateAttributes: (params, target = {}) ->
    defs = params.attributes || params.attributeDefinitions || id: 'string'
    target.attributeDefinitions = if isPlainObject defs
      for k, v of defs
        attributeName:  k
        attributeType:  createConstantsMap[v.toLowerCase()] || v
    else defs

    target

  ###
  IN:
    key:
      myHashKeyName:  'hash'
      myRangeKeyName: 'range'

    OR:

    key "hashKeyField"

    OR:

    key "hashKeyField/rangeKeyField"
    NOTE:
      you can use any format that matches /[_a-zA-Z0-9]+/g
  ###
  @translateKey: (params, target = {}) ->
    keySchema = params.key || params.keySchema || id: 'hash'

    target.keySchema = if isPlainObject keySchema
      for k, v of keySchema
        attributeName:  k
        keyType:        createConstantsMap[v.toLowerCase()] || v
    else if isString keySchema
      [hashKeyField, rangeKeyField] = keySchema.match /[_a-zA-Z0-9]+/g
      compactFlatten [
        {attributeName: hashKeyField, keyType: 'HASH'}
        {attributeName: rangeKeyField, keyType: 'RANGE'} if rangeKeyField
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
    target.provisionedThroughput =
      readCapacityUnits:  provisioning.read  || provisioning.readCapacityUnits  || 1
      writeCapacityUnits: provisioning.write || provisioning.writeCapacityUnits || 1

    target

  ###
  IN:
    globalIndexes:
      myIndexName:
        key:
          myHashKeyName:  'hash'
          myRangeKeyName: 'range'

        projection:
          attributes: ["myNumberAttrName", "myBinaryAttrName"]
          type: 'all' || 'keysOnly' || 'include'

        provisioning:
          read: 5
          write: 5
  ###
  @translateGlobalIndexes: (params, target = {}) =>
    if globalIndexes = params?.globalIndexes  || params?.globalSecondaryIndexes
      target.globalSecondaryIndexes = if isPlainObject globalIndexes
        for indexName, indexProps of globalIndexes
          _target = indexName: indexName
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
        key:
          myHashKeyName:  'hash'  # localIndexes must have the same hash-key as the table
          myRangeKeyName: 'range'

        projection:
          attributes: ["myNumberAttrName", "myBinaryAttrName"]
          type: 'all' || 'keysOnly' || 'include'

  ###
  @translateLocalIndexes: (params, target = {}) =>
    if localIndexes = params?.localIndexes  || params?.localSecondaryIndexes
      target.localSecondaryIndexes = if isPlainObject localIndexes
        for indexName, indexProps of localIndexes
          _target = indexName: indexName
          @translateKey indexProps, _target
          @translateProjection indexProps, _target
          _target
      else globalIndexes

    target

  @translateProjection: (params, target = {}) ->
    projection = params?.projection || type: 'all'
    target.projection =
      type: createConstantsMap[projection.type] || if projection.attributes then 'include' else 'all'
      attributes: projection.attributes || []

  ###
  IN:
    attributes:     see translateAttributes
    globalIndexes:  see translateGlobalIndexes
    key:            see translateKey
    provisioning:   see translateProvisioning
    localIndexes:   see translateLocalIndexes

  ###
  @translateCreateTableParams: (params, target = {}) =>
    params = deepDecapitalizeAllKeys params
    throw new Error "tableName required" unless params.tableName
    target.tableName = params.tableName
    @translateGlobalIndexes params, target
    @translateLocalIndexes params, target
    @translateAttributes params, target
    @translateKey params, target
    @translateProvisioning params, target
    target
