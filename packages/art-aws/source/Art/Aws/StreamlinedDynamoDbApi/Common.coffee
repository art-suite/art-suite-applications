{
  log
  lowerCamelCase, wordsArray
  isString
  isPlainArray
  isPlainObject
  isNumber
  isBoolean
} = require 'art-standard-lib'

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
      ALL_NEW
      ALL_OLD
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
      UPDATED_NEW
      UPDATED_OLD

      """
    @apiConstantsMap[lowerCamelCase dynamoDbConstant] = dynamoDbConstant

