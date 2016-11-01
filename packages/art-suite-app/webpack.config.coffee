module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    description: "Art App/Lib Boilerplate"
    dependencies:
      "art-foundation": "git://github.com/imikimi/art-foundation.git"
