{ log, pluralize, defineModule
  Bitmap
  Component
  CanvasElement
  Element
  RectangleElement
  TextElement
  arrayWithout
  BitmapElement
  Color
  array
  FillElement
  OutlineElement
} = require "art-suite"
{PointerActionsMixin} = require 'art-react/mixins'
{extractColors, generatePreviewBitmap} = require 'art-color-extractor'

shadowProps =
  color:    "#0007"
  blur:     20
  offset:   y: 5

layoutWeight = 15

defineModule module, class MyComponent extends PointerActionsMixin Component

  @stateFields bitmap: null, colorInfo: null, previewBitmap: null, selectedColor: null

  requestImage: ->
    Bitmap.requestImage()
    .then ({bitmap}) =>

      @previewBitmap = generatePreviewBitmap @colorInfo = ci = extractColors @bitmap = bitmap
      {darkMuted, muted, lightMuted, darkVibrant, vibrant, lightVibrant} = ci.colors
      @selectedColor = darkMuted || muted || lightMuted || darkVibrant || vibrant || lightVibrant

  doAction: -> @requestImage()

  render: ->
    {bitmap, colorInfo, previewBitmap, hover, selectedColor} = @state

    Element
      childrenLayout: "column"
      padding: layoutWeight
      RectangleElement
        padding: -layoutWeight
        inFlow: false
        animators: "color"
        on: pointerClick: @requestImage
        if colorInfo
          color: selectedColor
        else
          color: "white"

      if bitmap
        # Element
        #   childrenLayout: "row"
        #   childrenAlignment: "center"
          Element
            size: ps: 1
          #   size: hh: 1, wcw: 1
            Element
              size: hh: 1, wph: bitmap.aspectRatio, max: ww:1, hpw: 1 / bitmap.aspectRatio
              cursor: "pointer"
              on: @buttonHandlers
              location: "centerCenter"
              axis: "centerCenter"

              BitmapElement
                bitmap: bitmap
                shadow: shadowProps
              hover && BitmapElement
                bitmap: previewBitmap
                animators: opacity: toFrom: 0
              # RectangleElement color: "#fff7"
      else
        TextElement
          text: "pick photo"
          location: ps: .5
          axis: .5
          fontFamily: "AvenirNext-Regular"
          color:    "gray"

      colorInfo && Element
        size: ww:1, hch:1
        margin: layoutWeight
        childrenAlignment: "center"
        childrenLayout: "row"
        array colorInfo.colors, (v, k) =>
          Element
            cursor: "pointer"
            padding: layoutWeight
            margin: layoutWeight
            size: cs: 1
            on: pointerClick: =>
              log v
              @selectedColor = v

            RectangleElement
              color: v
              padding: -layoutWeight
              if v.eq @selectedColor
                FillElement()
              else
                shadow: shadowProps

            TextElement
              size: cs: 1
              color: if v.perceptualLightness < .75 then "white" else "black"
              text: k
              fontFamily: "AvenirNext-Regular"
