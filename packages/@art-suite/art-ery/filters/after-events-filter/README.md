# AfterEventsFilter

# Use

To use, just add the filter to your pipelines. Typically you'll want it on all your pipelines, so you can add it to a base pipeline class as follows:

```coffeescript
# CaffeineScript
import &@ArtSuite/ArtPipelines, &@ArtSuite/AfterEventsFilter

class BasePipeline extends Pipeline
  @abstractClass()
  @filter AfterEventsFilter

class User extends BasePipeline # <-- automatically has AfterEventsFilter
```

```javascript
// JavaScript
const { Pipeline } = require("@art-suite/art-pipelines");
const { AfterEventsFilter } = require("@art-suite/after-events-filter");

class BasePipeline extends Pipeline {}
BasePipeline.filter(AfterEventsFilter);

class User extends BasePipeline {} // # <-- automatically has AfterEventsFilter
```
