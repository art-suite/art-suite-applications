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
      mouseIsIn:      false
      dragOffset:     point()

    setHover: (bool) ->
      @setState "hover", bool
      try (@hoverAction || @props.hoverAction)? bool, @props

    @property "pointerDownAt"

    mouseIn:            -> @setState(mouseIsIn: true);      @setHover true
    mouseOut:           -> @setState(mouseIsIn: false);     @setHover @pointerIsDown
    pointerDownHandler: -> @setState(pointerIsDown: true);  @setHover true
    pointerUp:          -> @setState(pointerIsDown: false); @setHover @mouseIsIn

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
          if !@props.disabled
            log.error "DEPRICATED: @doAction is no longer supported, use @action" if @doAction
            (customAction ? @action ? @props.action)? event, @props
          else
            (@disabledAction ? @props.disabledAction)? event, @props

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
