define [
  'art-foundation'
  'art-flux'
  'art-react'
  'art-engine'
], (Foundation, Flux, ReactArtEngine, Engine) ->
  {log, CommunicationStatus} = Foundation
  {missing} = CommunicationStatus

  {FluxStore, FluxModel, ModelRegistry} = Flux.Core
  {FluxComponentBase} = Flux.React
  {fluxStore} = FluxStore
  {createComponentFactory, Element} = ReactArtEngine

  reset = ->
    fluxStore._reset()
    ModelRegistry._reset()

  suite "Art.Flux.React.FluxComponentBase", ->

    test "FluxComponentBase auto _unsubscribe", (done)->
      reset()

      class MyModel extends FluxModel
        @register()
        load: (key) -> status: missing

      MyWrapper = createComponentFactory
        getInitialState: ->
          includeFluxComponentBase: true

        render: ->
          Element
            name: "wrapper"
            MyFluxComponentBase() if @state.includeFluxComponentBase

      MyFluxComponentBase = createComponentFactory class MyFluxComponentBase extends FluxComponentBase
        componentWillMount: ->
          log 'componentWillMount: @subscribe "myModel", "myKey", "myStateField"'
          @subscribe @models.myModel, "myKey", "myStateField"

        render: ->
          Element name: @state.fluxFoo?.name || "(no name)"

      mw = MyWrapper().instantiateAsTopComponent root = new Engine.Core.Element name: "root"

      fluxStore.onNextReady ->
        assert.eq true, fluxStore.getHasSubscribers "myModel", "myKey"
        mw.setState includeFluxComponentBase: false

        mw.onNextReady ->
          fluxStore.onNextReady ->
            assert.eq false, fluxStore.getHasSubscribers "myModel", "myKey"
            done()
