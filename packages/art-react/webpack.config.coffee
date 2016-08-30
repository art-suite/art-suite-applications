module.exports = (require "art-foundation/configure_webpack")
  entries: "index test web_worker dom"
  package:
    description: "Art.React is inspired by Facebook's React. In fact, it is much the same. However, ArtReact is designed from the ground up to run with the Art.Engine."
    dependencies:
      "art-engine":        "git://github.com/Imikimi-LLC/art-engine.git"
      "art-engine-remote": "git://github.com/Imikimi-LLC/art-engine-remote.git"
