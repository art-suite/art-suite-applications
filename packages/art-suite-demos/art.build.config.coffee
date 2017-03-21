module.exports =
  webpack:
    common: {}
    targets:
      Demos: {}
      HelloWorld: {}

  package:
    description: "See what ArtSuite can do."
    dependencies:
      "art-suite":            "git://github.com/imikimi/art-suite"
      "art-color-extractor":  "git://github.com/imikimi/art-color-extractor"

