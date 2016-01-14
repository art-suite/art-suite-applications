path = require "path"
module.exports =
  entry:
    test_bundle: "./test/index.coffee"

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
      { test: /\.css$/, loader: "style-loader!css-loader" }
      { test: /\.png$/, loader: "url-loader?limit=100000" }
      { test: /\.jpg$/, loader: "file-loader" }
    ]

  # devtool: "#source-map"
