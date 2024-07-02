# UserOwnedFilter

# Use

To use, just add the filter to your pipelines. Typically you'll want it on all your pipelines, so you can add it to a base pipeline class as follows:

```coffeescript
# CaffeineScript
import &@ArtSuite/ArtPipelines, &@ArtSuite/UserOwnedFilter

class BasePipeline extends Pipeline
  @abstractClass()
  @filter UserOwnedFilter

class User extends BasePipeline # <-- automatically has UserOwnedFilter
```

```javascript
// JavaScript
const { Pipeline } = require("@art-suite/art-ery-pipelines");
const { UserOwnedFilter } = require("@art-suite/user-owned-filter");

class BasePipeline extends Pipeline {}
BasePipeline.filter(UserOwnedFilter);

class User extends BasePipeline {} // # <-- automatically has UserOwnedFilter
```
