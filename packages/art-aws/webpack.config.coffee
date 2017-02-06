module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    dependencies:
      "aws-sdk":        "^2.9.0"
      "dynamodb-local": "^0.0.13"
      "corsproxy":      "^1.5.0"