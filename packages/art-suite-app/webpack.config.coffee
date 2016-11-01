module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    description: "Art App/Lib Boilerplate"
    dependencies:
      "art-suite":    "git://github.com/imikimi/art-suite"
      "art-aws":      "git://github.com/imikimi/art-aws"
      "art-ery-aws":  "git://github.com/imikimi/art-ery-aws"
