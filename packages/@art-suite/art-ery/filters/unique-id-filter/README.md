# UniqueIdFilter

# Use

To use, just add the filter to your pipelines. Typically you'll want it on all your pipelines, so you can add it to a base pipeline class as follows:

```coffeescript
# CaffeineScript
import &@ArtSuite/ArtPipelines, &@ArtSuite/UniqueIdFilter

class BasePipeline extends Pipeline
  @abstractClass()
  @filter UniqueIdFilter

class User extends BasePipeline # <-- automatically has UniqueIdFilter
```

```javascript
// JavaScript
const { Pipeline } = require("@art-suite/art-ery-pipelines");
const { UniqueIdFilter } = require("@art-suite/unique-id-filter");

class BasePipeline extends Pipeline {}
BasePipeline.filter(UniqueIdFilter);

class User extends BasePipeline {} // # <-- automatically has UniqueIdFilter
```
