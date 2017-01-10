
### Full Declaration Example

This uses all of the declaration features of DynamoDbPipeline.

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

```