Foundation = require 'art-foundation'
Atomic = require 'art-atomic'
Engine = require 'art-engine'
Canvas = require 'art-canvas'

{point, color} = Atomic
{inspect, log, timeout, nextTick, merge} = Foundation
{Forms, Element, CanvasElement, TextElement, FillElement, RectangleElement} = Engine
{TextInputElement} = Forms

module.exports = ->

  bgColor = color "#777"
  textColor = color "white"
  normalOpacity = .3

  StyleProps =
    standardSpacing: 10
    mediumText:
      fontFamily: "sans-serif"
      fontSize: 16
      color: "#0009"

  newButton = ({text, click, size}) ->
    new Element
      size: size || ww:1, hch:1
      cursor: "pointer"
      margin: StyleProps.standardSpacing
      on: pointerClick: click
      new RectangleElement color: "#0001", radius: 3
      new TextElement merge StyleProps.mediumText,
        size: if size?.wcw
          cs:1
        else
          ww:1, hch:1
        padding: StyleProps.standardSpacing
        align: "center"
        text: text
        location: ps: .5
        axis: point .5


  showParseError = (c) ->
    if input.parent
      parent = input.removeFromParent()
      info.text = "invalid color"
      x = dialog.location.x

      #shake WRONG
      dialog.animate =
        to: location: dialog.currentLocation.withX x-5
        duration: 1/20
        then:
          to: location: dialog.currentLocation.withX x+5
          duration: 1/10
          then:
            to: location: dialog.currentLocation.withX x
            duration: 1/20

      timeout 1000, ->
        info.text = ""
        parent.addChild input
        log "adding input back in"
        timeout 1000, ->
          input.focus()

  setColorFromString = (colorString) ->
    c = color colorString
    if c.parseError
      showParseError c
    else
      #animate to new color and zoom in and out on dialog
      dialog.animate = log "animate",
        duration:.33
        f:"easeOutQuart"
        to: scale:point 1.2
        then: duration:.17, to: scale: point 1
      dialogBackground.animate = log "animate",
        duration:.33
        f:"easeOutQuart"
        to: color: c

  resetColor = ->
    setColorFromString input.value = "orange"
    input.focus()

  new CanvasElement
    canvasId: "artCanvas"
    new RectangleElement color: "white"
    # new TextElement axis: .5, text: "background", color: "#777", location: ps:.5

    dialog = new Element
      size: w:300, hch:1
      location: ps: .5
      axis: .5
      childrenLayout: "column"

      dialogBackground = new RectangleElement
        inFlow: false
        color: "orange"
        radius:5
        shadow: offsetY: 5, blur:5, color: "#0007"

      new Element
        size: hch:1, h: StyleProps.standardSpacing
        cursor: "move"
        on: pointerMove: (e) =>
          dialog.location = dialog.currentLocation.add e.parentParentDelta
        new RectangleElement color: "#0001"
        new TextElement merge StyleProps.mediumText,
          size: ww:1
          padding: 10
          align: "center"
          text: "Form Demo"
          location: ps: .5
          axis: .5

      new Element
        padding: StyleProps.standardSpacing
        size: hch: 1
        childrenLayout: "column"


        new TextElement merge StyleProps.mediumText,
          size: ww:1
          margin: StyleProps.standardSpacing
          text: "Instructions:\n  Type in an HTML color\n  Press Enter\nSome extra text to demo this text-area word-wraps."


        new Element
          margin: StyleProps.standardSpacing
          size: ww:1, h:30
          info = new TextElement merge StyleProps.mediumText,
            text: ""
            location: ps: .5
            color: "red"
            axis: point .5
          input = new TextInputElement
            size: ww:1, hh:1
            value: "orange"
            align: "center"
            on: enter: (e) -> setColorFromString e.target.value
            new RectangleElement color: color 1,1,1,.75

        new Element
          size: ww:1, hch:1
          childrenLayout: "row"
          newButton
            text: "submit"
            size: hch:1, ww:1
            click: -> setColorFromString input.value

          newButton
            text: "reset"
            size: hch:1, ww:1
            click: -> resetColor()

        new Element
          margin: StyleProps.standardSpacing
          size: ww:1, hch:1
          childrenLayout: "row"
          newButton
            text: "invisible"
            size: hch:1, ww:1
            click: ->
              dialog.visible = false
              timeout 1000, -> dialog.visible = true

          newButton
            text: "opacity=0"
            size: hch:1, ww:1
            click: ->
              dialog.animate =
                to:
                  opacity: 0
                on: done: -> timeout 500, -> dialog.opacity = 1

  timeout 100, -> input.focus()
