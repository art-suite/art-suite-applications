module.exports = (require "art-foundation/configure_webpack")
  entries: "index test perf"
  dirname: __dirname
  package:
    dependencies:
      "quantize":       "^1.0.2"
      "art-foundation": "git://github.com/imikimi/art-foundation.git"
