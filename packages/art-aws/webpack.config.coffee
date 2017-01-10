module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    dependencies:
      "aws-sdk":        "^2.7.9"
      "dynamodb-local": "^0.0.12"
      "corsproxy":      "^1.5.0"