module.exports = (require "art-foundation/configure_webpack")
  entries: "index, test, perf"
  dirname: __dirname
  package:
    description: "atomic data-types such as Color, Point, Rectangle and Matrix"
    dependencies:
      "art-foundation": "git://github.com/Imikimi-LLC/art-foundation.git"
