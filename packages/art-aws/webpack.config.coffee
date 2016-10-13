module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    dependencies:
      "aws-sdk": "^2.6.7"
      "dynamodb-local": "^0.0.12"