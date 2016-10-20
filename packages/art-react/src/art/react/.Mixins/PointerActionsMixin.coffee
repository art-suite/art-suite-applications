{defineModule} = require 'art-foundation'

defineModule module, ->
  (superClass) -> class PointerActionsMixin extends superClass

    @stateFields
      hover: false
      pointerIsDown: false

    mouseIn:     -> @setState hover: true
    mouseOut:    -> @setState hover: false
    pointerDown: -> @setState pointerIsDown: true
    pointerUp:   -> @setState pointerIsDown: false

    @getter

      buttonHandlers: ->
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
        pointerDown:      @pointerDown
        pointerIn:        @pointerDown
        pointerUp:        @pointerUp
        pointerCancel:    @pointerUp
        pointerOut:       @pointerUp
        pointerUpInside:  @doAction

      hoverHandlers: ->
        # CafScript could do: {} @mouseIn @mouseOut
        mouseIn:          @mouseIn
        mouseOut:         @mouseOut
