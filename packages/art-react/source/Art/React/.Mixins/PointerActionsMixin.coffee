{defineModule, log} = require 'art-standard-lib'
{point} = require 'art-atomic'

defineModule module, ->
  (superClass) -> class PointerActionsMixin extends superClass

    constructor: ->
      super
      @_pointerDownAt = point()

    @stateFields
      hover: false
      pointerIsDown:  false
      dragOffset:     point()

    @property "pointerDownAt"

    mouseIn:            -> @setState hover: true
    mouseOut:           -> @setState hover: false
    pointerDownHandler: -> @setState pointerIsDown: true

    pointerUp:          -> @setState pointerIsDown: false

    @getter
      pointerDown: -> @pointerIsDown

      buttonHandlers: (customAction) ->
        element = @

        mouseIn:          @mouseIn
        mouseOut:         @mouseOut
        pointerDown:      @pointerDownHandler
        pointerIn:        @pointerDownHandler
        pointerUp:        @pointerUp
        pointerCancel:    @pointerUp
        pointerOut:       @pointerUp
        pointerUpInside:  (event) =>
          event.target.capturePointerEvents()
          (customAction || @doAction || @action || @props.action)? event, @props

      pointerHandlers: -> @buttonHandlers

      hoverHandlers: -> {@mouseIn, @mouseOut}

      dragHandlers: ->
        mouseIn:      @mouseIn
        mouseOut:     @mouseOut
        pointerDown:  @dragPointerDownHandler
        pointerMove:  @dragPointerMoveHandler
        pointerUp:    @dragPointerUpHandler

    dragMove:   (event, dragDelta) ->
    dragStart:  (event) ->
    dragEnd:    (event, dragDelta) ->

    dragPointerDownHandler: (event) =>
      @pointerDownAt = event.parentLocation
      @dragStart event
      @pointerIsDown = true
      @dragMove event, @dragOffset = point()

    dragPointerMoveHandler: (event) =>
      @dragMove event, @dragOffset = event.parentLocation.sub @pointerDownAt

    dragPointerUpHandler: (event) ->
      @dragEnd event, event.parentLocation.sub @pointerDownAt
      @dragOffset = point()
      @pointerIsDown = false
