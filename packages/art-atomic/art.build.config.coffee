module.exports =
  target: node: true
  package:
    description: "atomic data-types such as Color, Point, Rectangle and Matrix"
    dependencies:
      "art-foundation": "git://github.com/imikimi/art-foundation.git"

  webpack:
    common: {}
    targets:
      index: {}
      test: target: "web"
      perf: target: "web"
