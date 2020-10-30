{CanvasElement, RectangleElement, TextElement, FullScreenApp} = require "art-engine"

FullScreenApp.init
  title: "ArtEngine Hello world"
.then ->
  new CanvasElement null,
    new RectangleElement color: "#ffe"
    new TextElement text: "Hello world!", padding: 10
