module.exports = (require "art-foundation/configure_webpack")
  entries: "index"
  package:
    description: 'ArtEry for AWS Lambda + DynamoDB'
    dependencies:
      "art-foundation":     "git://github.com/imikimi/art-foundation.git"
      "art-ery":            "git://github.com/imikimi/art-ery.git"
      "art-aws":            "git://github.com/imikimi/art-aws.git"
      "neptune-namespaces": "git://github.com/imikimi/neptune-namespaces.git"
      "uuid": "^2.0.3"
