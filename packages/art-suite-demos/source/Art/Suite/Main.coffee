{
  initArtSuiteApp
  Component
  CanvasElement
} = require 'art-suite'

initArtSuiteApp MainComponent: class ArtSuiteDemos extends Component
  render: -> CanvasElement (require './Loader')()
