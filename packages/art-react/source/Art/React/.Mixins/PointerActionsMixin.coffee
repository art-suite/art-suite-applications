{timeout, defineModule, log, merge} = require 'art-standard-lib'
{point} = require 'art-atomic'
mobileBrowser = (require 'art-foundation').Browser.isMobileBrowser()

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

    _settingHover: (hover, state = @state) ->
      if hover != state.hover
        @onNextReady =>
          (@hoverAction || @props.hoverAction)? hover, @props
      hover

    mouseIn: -> @setState (state) =>
      merge state,
        mouseIsIn:      true
        hover:          @_settingHover true, state

    mouseOut: -> @setState (state) =>
      merge state,
        mouseIsIn:      false
        hover:          @_settingHover state.pointerIsDown, state

    pointerDownHandler: -> @setState (state) =>
      merge state,
        pointerIsDown:  true
        hover:          @_settingHover true, state

    pointerUpHandler: -> @setState (state) =>
      merge state,
        pointerIsDown:  false
        hover:          @_settingHover state.mouseIsIn, state

    pointerUpInsideHandler: (event) =>
      event.target.capturePointerEvents()
      if !@props.disabled
        log.error "DEPRICATED: @doAction is no longer supported, use @action" if @doAction
        (customAction ? @action ? @props.action)? event, @props
      else
        (@disabledAction ? @props.disabledAction)? event, @props

    @getter
      touchDragTimeoutMs: -> 1000
      pointerDown: -> @pointerIsDown

      buttonHandlers: (customAction) ->
        element = @

        mouseIn:          @mouseIn
        mouseOut:         @mouseOut
        pointerDown:      @pointerDownHandler
        pointerIn:        @pointerDownHandler
        pointerUp:        @pointerUpHandler
        pointerCancel:    @pointerUpHandler
        pointerOut:       @pointerUpHandler
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
          @dragFinally event, @dragging, false
          unless @dragging
            @pointerUpInsideHandler event

        pointerCancel:  (event) =>
          @pointerUpHandler()

          if @dragging then @dragCanceled event, @dragOffset
          @dragFinally event, @dragging, true
          @dragging = false

    dragPointerDownHandler: (event) =>
      @dragPrepare event
      @pointerDownHandler event
      @pointerDownAt = event.parentLocation
      @dragOffset = point()
      @_pointerDownKey = pdk = (@_pointerDownKey ? 0) + 1
      event = event.clone()

      if mobileBrowser
        timeout @touchDragTimeoutMs, =>
          @_drag event if !@dragging && @pointerIsDown && @_pointerDownKey == pdk

    _drag: (event) =>
      @dragOffset = offset = event.parentLocation.sub @pointerDownAt

      unless @dragging
        @dragging = true
        event.target?.capturePointerEvents?()
        @dragStart event, offset

      @dragMove event, offset

    dragPointerMoveHandler: (event) =>
      offset = event.parentLocation.sub @pointerDownAt
      if @dragging || (!mobileBrowser && Math.max(Math.abs(offset.x), Math.abs(offset.y)) > @deadZone)
        @_drag event

    dragPointerUpHandler: (event) ->
      @pointerUpHandler event
      if @dragging then @dragEnd event, event.parentLocation.sub @pointerDownAt
      @dragFinally event, @dragging, false
      @dragOffset     = point()
      @dragging       = false

    ###########
    # overrides
    ###########

    # touch/button just started, may become a drag action
    dragPrepare:  (event) ->

    ###
    IN:
      dragStarted:  T/F: dragStart fired
      dragCanceled: T?F: dragCanceled fired

    EFFECT:
      called after dragEnd and dragCanceled
    ###
    dragFinally:  (event, dragStarted, dragCanceled) ->

    dragMove:     (event, dragOffset) ->
    dragStart:    (event, dragOffset) ->
    dragEnd:      (event, dragOffset) ->
    dragCanceled: (event, dragOffset) ->
