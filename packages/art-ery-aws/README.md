# ArtEryAws - DynamoDb support for ArtEry

# Examples

### Simple Table Example

```coffeescript
import &ArtEryAws

class Channel extends DynamoDbPipeline

  @addDatabaseFilters
    title: "trimmedString"
```

### Full Declaration & Many-to-Many Table Example

This uses all of the declaration features of DynamoDbPipeline. This is also a good example for how to do a many-to-many DynamoDb model.

```coffeescript
import &ArtEryAws

class Participant extends DynamoDbPipeline
  @primaryKey "postId/userId"
  @globalIndexes participantsByUserId: "userId/createdAt"
  @localIndexes  participantsByPostId: "postId/createdAt"

  @addDatabaseFilters
    user: "link"
    post: "link"
```

# Test

- Install [Docker](https://docs.docker.com/get-docker/)

```bash
# in one shell
npm run dynamodb

# in another shell
npm test
```
