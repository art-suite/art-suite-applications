# ArtExpressServer

Extensible, Promise-based HTTP Server based on Express

### Usage

```coffeescript
&ArtExpressServer.start
  port:         number       (default: 8085)
  handlers:     array        (required)

  static:                    (default: null)
    root:       string
    headers:    object       (default: {})

  numWorkers:   number       (default: 1)
  allowAllCors: bool
    # only save to set to true if you aren't using cookies
```

### Environment Vars

These are designed to be compatible with Heroku.

```
WEB_CONCURRENCY=number # set the default numWorkers
PORT=number            # set the default port

ART_EXPRESS_SERVER_MAX_AGE_SECONDS=number  # if set, will restart workers after that many seconds
ART_EXPRESS_SERVER_MAX_SIZE_MB=number      # if set, will restart workers which use more than the specified number of megabytes
```

NOTE - in order for WEB_CONCURRENCY>1 to work, starting your server with "caf YourServer.caf" won't work due to a bug in CaffeineScript and forking. You should either:

* RECOMENDED: compile your server into pure javascript with webpack
* Start your server with "node" and a simple .js file: `require('art-express-server/register');require('./YourServer.caf');`