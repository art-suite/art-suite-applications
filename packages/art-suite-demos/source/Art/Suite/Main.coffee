{
  initArtSuiteApp
  Component
  CanvasElement
} = require 'art-suite'

require("art-suite").initArtSuiteApp
  title:          "Art-Suite-Demos"
  MainComponent: class ArtSuiteDemos extends Component
    render: -> CanvasElement (require './Loader')()
