
### Full Declaration Example

This uses all of the declaration features of DynamoDbPipeline. This is also a good example for how to do a many-to-many DynamoDb model.

```coffeescript
{defineModule} = require 'art-foundation'
{DynamoDbPipeline} = require 'art-ery-aws'
{createDatabaseFilters} = require 'art-ery/Filters'

defineModule module, class Participant extends DynamoDbPipeline
  @primaryKey "postId/userId"
  @globalIndexes participantsByUserId: "userId/lastActivityAt"
  @localIndexes  participantsByPostId: "postId/lastSeenActivityAt"

  @filter createDatabaseFilters
    userOwned:          true
    post:               "include link"
    lastActiveUser:     link: include: "user"
    lastActivityAt:     "timestamp"

    lastSeenActivityCount: "number"
    lastSeenActivityAt: "timestamp"

  ###
  This filter replaces the "key" property in every request
  with the HASH+RANGE compound-key for DynamoDb.
  ###
  @filter
    name: "compoundKey"
    before: all: (request) ->
      return request unless request.data
      {userId, postId} = request.data
      request.withKey {postId, userId}

```