# ArtSuiteApp

Build cross-platform, full-screen apps with [ArtSuite](https://github.com/imikimi/art-suite/wiki).

### Init

```coffeescript
Config:
  Enviroments:
    Development

      # configure ArtAws (config for all Amazon AWS access)
      artAws:

        region:             'us-east-1'

        credentials:
          accessKeyId:      'blah'
          secretAccessKey:  'blahblah'

        s3Buckets:
          tempBucket:       'oz-dev-expiring-uploads'

        dynamoDb:
          endpoint:         'http://localhost:8081'

      # config for ArtEry
      artEry: tableNamePrefix: "oz-dev."

      # config for Pusher.com
      pusher: key: "blahblah"

      # config for Imgix.com
      imgix:  domain: "https://oz-dev-media.imgix.net"

# Client only

Component:
  # React component to instantiate as the top component

title:
  # the title of this app. Sets the browser tab's title, also effects logging

*:
  # all options are passed to ArtEngine.FullScreenApp.init
  # see that doc for more valid options (such as styleSheets and fontFamilies)

```