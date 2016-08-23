Foundation = require 'art-foundation'
{
  log
  lowerCamelCase, wordsArray
  isString
  isPlainArray
  isPlainObject
  isNumber
  isBoolean
} = Foundation

module.exports = class Common

  # all dynamoDbConstants in lowerCamelCase, plus some aliases
  @apiConstantsMap:

    # aliases
    string: 'S'
    number: 'N'
    binary: 'B'
    bothImages: 'NEW_AND_OLD_IMAGES'

  for dynamoDbConstant in wordsArray """
      ALL
      ALL_ATTRIBUTES
      ALL_PROJECTED_ATTRIBUTES
      COUNT
      HASH
      INCLUDE
      INDEXES
      KEYS_ONLY
      NEW_AND_OLD_IMAGES
      NEW_IMAGE
      NONE
      OLD_IMAGE
      RANGE
      S N B
      SPECIFIC_ATTRIBUTES
      TOTAL

      """
    @apiConstantsMap[lowerCamelCase dynamoDbConstant] = dynamoDbConstant

