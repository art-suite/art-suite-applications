# ValidationFilter

# Use

To use, just add the filter to your pipelines. Typically you'll want it on all your pipelines, so you can add it to a base pipeline class as follows:

```coffeescript
# CaffeineScript
import &@ArtSuite/ArtPipelines, &@ArtSuite/ValidationFilter

class BasePipeline extends Pipeline
  @abstractClass()
  @filter ValidationFilter

class User extends BasePipeline # <-- automatically has ValidationFilter
```

```javascript
// JavaScript
const { Pipeline } = require("@art-suite/art-ery-pipelines");
const { ValidationFilter } = require("@art-suite/validation-filter");

class BasePipeline extends Pipeline {}
BasePipeline.filter(ValidationFilter);

class User extends BasePipeline {} // # <-- automatically has ValidationFilter
```
