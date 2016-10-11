module.exports = (require "art-foundation/configure_webpack")
  entries: "index test"
  dirname: __dirname
  package:
    dependencies:
      "art-foundation": "git://github.com/Imikimi-LLC/art-foundation.git"
      "art-atomic":     "git://github.com/Imikimi-LLC/art-atomic.git"
      "webfontloader":  "^1.6.26"
