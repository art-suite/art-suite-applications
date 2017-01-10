### Simple Table Example

```coffeescript
{defineModule} = require 'art-foundation'
{DynamoDbPipeline} = require 'art-ery-aws'
{createDatabaseFilters} = require 'art-ery/Filters'

defineModule module, class Channel extends DynamoDbPipeline

  @filter createDatabaseFilters
    title: "trimmedString"
```

### Full Declaration & Many-to-Many Table Example

This uses all of the declaration features of DynamoDbPipeline. This is also a good example for how to do a many-to-many DynamoDb model.

```coffeescript
{defineModule} = require 'art-foundation'
{DynamoDbPipeline} = require 'art-ery-aws'
{createDatabaseFilters} = require 'art-ery/Filters'

defineModule module, class Participant extends DynamoDbPipeline
  @primaryKey "postId/userId"
  @globalIndexes participantsByUserId: "userId/createdAt"
  @localIndexes  participantsByPostId: "postId/createdAt"

  @filter createDatabaseFilters
    user: "link"
    post: "link"
```