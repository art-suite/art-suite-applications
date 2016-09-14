module.exports = (require "art-foundation/configure_webpack")
  entries: "index web_worker test"
  dirname: __dirname
  package:
    dependencies:
      "art-foundation": "git://github.com/Imikimi-LLC/art-foundation.git"
      "art-react":      "git://github.com/Imikimi-LLC/art-react.git"
