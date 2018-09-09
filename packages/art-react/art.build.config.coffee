module.exports =
  webpack:
    common:
      mode: "development"
    targets:
      index: {}
      test: {}
      web_worker: {}
      dom: {}

  package:
    description: "Art.React is inspired by Facebook's React. In fact, it is much the same. However, ArtReact is designed from the ground up to run with the Art.Engine."
    dependencies:
      "art-engine":        "git://github.com/imikimi/art-engine.git"
      "art-engine-remote": "git://github.com/imikimi/art-engine-remote.git"
