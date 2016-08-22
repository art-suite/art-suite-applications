Foundation = require 'art-foundation'
{
  lowerCamelCase, wordsArray, isPlainObject, log, compactFlatten
  isString, compactFlatten, deepEachAll, uniqueValues
} = Foundation

module.exports = class Common

  # all dynamoDbConstants in lowerCamelCase, plus some aliases
  @createConstantsMap:

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
    @createConstantsMap[lowerCamelCase dynamoDbConstant] = dynamoDbConstant

