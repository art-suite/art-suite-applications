path = require "path"
module.exports =
  # entry:
  #   index: "./index.coffee"
    # tests: "./test/tests"
    # tests must be an array due to bug in webpack:
    # https://github.com/webpack/webpack/issues/300

  resolve:
    extensions: ["", ".webpack.js", ".web.js", ".js", ".coffee"]

  output:
    path: path.join __dirname, "dist"
    filename: "[name].js"

  module:
    loaders: [
      { test: /\.coffee$/, loader: "coffee-loader" }
      { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" }
    ]

  devtool: "#source-map"
