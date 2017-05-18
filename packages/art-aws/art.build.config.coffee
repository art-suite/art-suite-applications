module.exports =
  target: node: true
  webpack:
    common: {}
    targets:
      index: {}
      test: {}

  package:
    description: "Streamlined APIs for AWS SDK with Promises and Art.Foundation"
    dependencies:
      "aws-sdk":        "^2.9.0"
      "dynamodb-local": "^0.0.13"
      "corsproxy":      "^1.5.0"
