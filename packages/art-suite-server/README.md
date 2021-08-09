# Art.Suite.Server

ArtSuite Server is backed by NodeJS Express. By default, it provides:

* public webpage hosting at `/public`
* `art-ery` REST-API hosting at `/api`
* `art-suite-app` hosting at `/`

### Install

```shell
npm install art-suite-server
```

### Usage

```coffeescript
# your-package/Server.caf
&ArtSuiteServer.start
  app: &source
```