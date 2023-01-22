# ArtEryPusher

An ArtEry Filter for using Pusher.com to trigger updates in all clients when after all creates and updates.

## Usage

Other than init and config (see below), the only thing you have to do is add PusherPipelineMixin to every ArtEry.Pipeline you want to participate in ArtEryPusher notifications for created, updated or deleted records:

```coffeescript
# CaffeineScript
import &ArtEry, &ArtEryPusher

class MyPusherPipeline extends PusherPipelineMixin Pipeline
  ...
```

Typically you'll want to enable this for Pipelines which are database-backed. It adds the PusherFilter to the pipeline, and, if you are using ArtFlux in your client, it ensures the PusherFluxModelMixin is used when creating the FluxModels.

## Init

Because Pusher has different libraries for client and server, you need to require a different file depending on your context. This can be done right at the beginning of either your client or server code. These only load the correct libraries. The Pusher libraries are initialized automatically after ArtSuite configuration.

Client:

```coffeescript
# CaffeineScript
&ArtEryPusher/Client
```

Server:

```coffeescript
# CaffeineScript
&ArtEryPusher/Server
```

## Config

ArtEryPusher uses the standard ArtSuite config system (currently declared in Art.Foundation). The config path is "Art.Ery.Pusher." You can see all configurable options in: source/Art.EryExtensions.Pusher/Config.coffee.

The ArtSuite config system allows you to set your config in whatever place is most convenient.

Recommendations:

- Production: Use shell environment variables set on the server. Never check in production keys into your source control.
- Development: Use whichever one is convenient.

#### Shell Environment Variables

```shell
# shell environment
> artConfig='{"Art.Ery.Pusher": {"apiId":"abc", "key": "def", "secret", "ghi"}}' npm start
```

#### Query-String

```
/myPage?artConfig={"Art.Ery.Pusher": {"apiId":"abc", "key": "def", "secret", "ghi"}}
```

#### Config File

```coffeescript
# CaffeineScript
import &ArtConfig

class Development extends Config
  Art: Ery: Pusher:
    apiId:    'abc'
    key:      'def'
    secret:   'ghi'
    cluster:  'foo'
```

#### Javascript Global

```coffeescript
# TODO: look up how to do this - or actually write some doc for Art.Foundation.Config!
```

# Testing

Create a Pusher.com channel and put the credentials here:

```coffeescript
# .TestPusherAppCredentials.caf
appId:    "xxx"
key:      "xxx"
cluster:  "xxx"
secret:   "xxx"
```

```bash
npm test
```
