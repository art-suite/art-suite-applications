{defineModule, log} = require 'art-standard-lib'

defineModule module, ->
  (superClass) -> class PointerActionsMixin extends superClass

    @stateFields
      hover: false
      pointerIsDown: false

    mouseIn:            -> @setState hover: true
    mouseOut:           -> @setState hover: false
    pointerDownHandler: -> @setState pointerIsDown: true

    pointerUp:          -> @setState pointerIsDown: false

    @getter
      hover: -> @state.hover
      pointerIsDown: -> @state.pointerIsDown
      pointerDown: -> @pointerIsDown

      buttonHandlers: (customAction) ->
        element = @
        ###
          CafScript could do: {}
            @mouseIn
            @mouseOut

            pointerDown:
            pointerIn:      @pointerDown

            pointerUp:
            pointerOut:
            pointerCancel:  @pointerUp
        ###
        # this might be needed when we go back to using the webworker
        # preprocess: pureMerge newProps.on?.preprocess,
        #   pointerUpInside: newProps.preprocessAction
        mouseIn:          @mouseIn
        mouseOut:         @mouseOut
        pointerDown:      @pointerDownHandler
        pointerIn:        @pointerDownHandler
        pointerUp:        @pointerUp
        pointerCancel:    @pointerUp
        pointerOut:       @pointerUp
        pointerUpInside:  (event) ->
          event.target.capturePointerEvents()
          (customAction || element.doAction || element.action || element.props.action)? event

      pointerHandlers: -> @buttonHandlers

      hoverHandlers: ->
        # CafScript could do: {} @mouseIn @mouseOut
        mouseIn:          @mouseIn
        mouseOut:         @mouseOut
