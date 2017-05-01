module.exports =
  target:
    node: true

  package:
    scripts:
      testServer: "coffee ./TestServer.coffee"

    description: "
      Extensible, Promise-based HTTP Server based on Express
      "

    dependencies:
      express:              "^4.14.0"
      compress:             "^0.99.0"
      throng:               "^4.0.0"
      jsonwebtoken:         "^7.2.1"

  webpack:
    # common properties are merged into each target's properties
    common: {}

    # each target's individual properties
    targets: index: {}
