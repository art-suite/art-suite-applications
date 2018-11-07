{timeout, defineModule, log} = require 'art-standard-lib'
{point} = require 'art-atomic'
{isMobileBrowser} = (require 'art-foundation').Browser

defineModule module, ->
  (superClass) -> class PointerActionsMixin extends superClass

    constructor: ->
      super
      @_pointerDownAt = point()

    deadZone: 3

    @stateFields
      hover: false
      pointerIsDown:  false
      mouseIsIn:      false
      dragOffset:     point()
      dragging:       false

    setHover: (bool) ->
      @hover = bool
      try (@hoverAction || @props.hoverAction)? bool, @props

    @property "pointerDownAt"

    mouseIn:            -> @mouseIsIn     =        @hover = true
    mouseOut:           -> @mouseIsIn     = false; @hover = @pointerIsDown
    pointerDownHandler: -> @pointerIsDown =        @hover = true
    pointerUp:          -> @pointerIsDown = false; @hover = @mouseIsIn

    pointerUpInsideHandler: (event) =>
      event.target.capturePointerEvents()
      if !@props.disabled
        log.error "DEPRICATED: @doAction is no longer supported, use @action" if @doAction
        (customAction ? @action ? @props.action)? event, @props
      else
        (@disabledAction ? @props.disabledAction)? event, @props

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
        pointerUpInside:  @pointerUpInsideHandler

      pointerHandlers: -> @buttonHandlers

      hoverHandlers: -> {@mouseIn, @mouseOut}

      dragHandlers: ->
        mouseIn:        @mouseIn
        mouseOut:       @mouseOut
        pointerDown:    @dragPointerDownHandler
        pointerMove:    @dragPointerMoveHandler
        pointerUp:      @dragPointerUpHandler

        pointerUpInside: (event) =>
          unless @dragging
            @pointerUpInsideHandler event

        pointerCancel:  (event) =>
          @pointerUp()
          if @dragging then @dragCanceled event, @dragOffset
          @dragging = false

    dragPointerDownHandler: (event) =>
      @dragPrepare event
      @pointerDownHandler event
      @pointerDownAt = event.parentLocation
      @dragOffset = point()
      @_pointerDownKey = pdk = (@_pointerDownKey ? 0) + 1
      event = event.clone()
      timeout 1000, =>
        if !@dragging && @pointerIsDown && @_pointerDownKey == pdk
          @_drag event

    _drag: (event) =>
      @dragOffset = offset = event.parentLocation.sub @pointerDownAt

      unless @dragging
        @dragging = true
        event.target?.capturePointerEvents?()
        @dragStart event, offset

      @dragMove event, offset

    dragPointerMoveHandler: (event) =>
      offset = event.parentLocation.sub @pointerDownAt
      if @dragging || (!isMobileBrowser() && Math.max(Math.abs(offset.x), Math.abs(offset.y)) > @deadZone)
        @_drag event

    dragPointerUpHandler: (event) ->
      @pointerDownHandler event
      if @dragging then @dragEnd event, event.parentLocation.sub @pointerDownAt
      @dragOffset     = point()
      @dragging       = false
      @pointerIsDown  = false

    ###########
    # overrides
    ###########

    # touch/button just started, may become a drag action
    dragPrepare:  (event) ->

    dragMove:     (event, dragOffset) ->
    dragStart:    (event, dragOffset) ->
    dragEnd:      (event, dragOffset) ->
    dragCanceled: (event, dragOffset) ->
