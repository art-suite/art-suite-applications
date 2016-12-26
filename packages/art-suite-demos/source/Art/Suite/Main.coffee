{
  InitArtSuiteApp
  Component
  CanvasElement
} = require 'art-suite'

InitArtSuiteApp
  title: "Art.React.Demos"
  class Main extends Component
    render: -> CanvasElement (require './Loader')()
