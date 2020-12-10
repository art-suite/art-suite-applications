module.exports = (require "art-foundation/configure_webpack")
  entries: "remote receiver test worker_for_remote_tests"
  dirname: __dirname
  package:
    dependencies:
      "art-engine":        "git://github.com/imikimi/art-engine.git"
