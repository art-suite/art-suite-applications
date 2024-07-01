# DataUpdatesFilter

The DataUpdatesFilter ensures that, for each pipeline request, all changes caused by that request trigger updates on the client.

The filter runs both server-side and client-side to facilitate this. It runs server-side to track all changes, even in sub-requests, and the updates as `{props: {dataUpdates, dataDeletes}}`.

Then, client-side, DataUpdatesFilter unpacks `{dataUpdates, dataDeletes}` and triggers the proper
`pipeline.dataUpdated` and `pipeline.dataDeleted` events.

# Use

To use, just add the filter to your pipelines. Typically you'll want it on all your pipelines, so you can add it to a base pipeline class as follows:

```coffeescript
# CaffeineScript
import &@ArtSuite/ArtPipelines, &@ArtSuite/DataUpdatesFilter

class BasePipeline extends Pipeline
  @abstractClass()
  @filter DataUpdatesFilter

class User extends BasePipeline # <-- automatically has DataUpdatesFilter
```

```javascript
// JavaScript
const { Pipeline } = require("@art-suite/art-pipelines");
const { DataUpdatesFilter } = require("@art-suite/data-updates-filter");

class BasePipeline extends Pipeline {}
BasePipeline.filter(DataUpdatesFilter);

class User extends BasePipeline {} // # <-- automatically has DataUpdatesFilter
```
