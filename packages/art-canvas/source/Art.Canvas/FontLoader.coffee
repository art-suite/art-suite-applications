{
  present, isPlainObject, object, merge, defineModule, formattedInspect, log, timeout, Promise
} = require 'art-standard-lib'
{point} = require 'art-atomic'
Bitmap = require './Bitmap'

{Div, Link, Style} = require("art-foundation").Browser.DomElementFactories

defaultLoadedTestText = "aA"
###
fonts:
  nameKey:
    loadedTestText: string of characters with different glyphs than Arial (actually rendered to validate they changed)
    css:            URL to the css file that will load the font
    url:            URL to the font-file to load
    fontFamily:     font-family name [default: nameKey]
###
defineModule module, class FontLoader
  ###
  IN: see 'fonts' above
  OUT: promise.then (object) -> all specified fonts have been loaded
    object lists all the input keys with 'true' for the values - because
    they have all been loaded

  TODO: there should probably be a timeout option, and then add:
    OUT: promise.catch (object) ->
      object is keys -> true or false for which fonts have and havenot been loaded
  ###
  @allFontsLoaded: (fonts) ->
    timeExpired = 0
    new Promise (resolve, reject) ->
      testFonts = ->
        try
          verbose = timeExpired >= 1000 && timeExpired % 1000 == 0

          if FontLoader.allFontsLoadedSync fonts, verbose
            if timeExpired >= 100
              log.warn formattedInspect FontLoader: success: milliseconds: timeExpired, fonts: Object.keys fonts
            resolve object fonts, -> true
          # else if timeoutRemaining <= 0
          #   reject new Error "timeout loading fonts: #{formattedInspect fonts}"
          else
            if verbose
              log.warn formattedInspect FontLoader: waiting: milliseconds: timeExpired, fonts: Object.keys fonts

            # log "waiting for fonts: #{formattedInspect fonts}"
            timeExpired += 25
            timeout 25, testFonts
        catch e
          log {e}

      testFonts()
    .then =>
      @_cleanup()

  # IN: see 'fonts' above
  # OUT: immediatly returns T/F
  @allFontsLoadedSync: (fonts, verbose) ->
    for k, loaded of FontLoader.fontsLoadedSync fonts, verbose
      return false unless loaded
    true

  # IN: see 'fonts' above
  # OUT: promise.then (loadedMap) ->
  #   IN: ladedMap: object keys are from fonts, values are true/false if that font is loaded
  @fontsLoadedSync: (fonts, verbose) ->
    object fonts, (fontName, fontFamily) -> FontLoader.fontLoaded fontName, fontFamily, verbose

  # IN: see 'fonts' above
  @loadFonts: (fonts) ->
    log formattedInspect loadFonts: fonts
    if !isPlainObject fonts
      throw new Error "ArtCanvas.FontLoader.loadFonts: fonts should be an object"

    log FontLoader: loading: fonts

    fontsLoaded = @fontsLoadedSync fonts
    for name, {fontFamily, loadedTestText, css, url} of fonts when !fontsLoaded[fontFamily]
      loadedTestText ||= defaultLoadedTestText
      fontFamily ||= name
      log loading: {fontFamily}
      if css
        document.head.appendChild Link
          rel: "stylesheet"
          href: css

      else if url
        document.head.appendChild Style "@font-face { font-family: #{fontFamily}; src: url('#{url}'); } "

      document.body.appendChild Div
        style:
          fontFamily: fontFamily
          position:   "absolute"
          fontSize:   "0"
        loadedTestText

    @allFontsLoaded fonts

  # getTestImageData = (options, text, bitmap) ->
  #   bitmap.clear backgroundColor = "#fee"
  #   bitmap.drawText point(5, bitmap.size.y * 2/3), text, merge options, color: "black"
  #   log getTestImageData: {options, text, bitmap: bitmap.clone()}
  #   bitmap.imageData.data

  loadedWidthBasedTest = (bitmap, fontFamily, loadedTestText, expectedTestWidth, verbose) ->
    {context} = bitmap
    context.font = "12px sans serif"
    referenceWidth = context.measureText(loadedTestText).width

    context.font = "12px #{fontFamily}, sans serif"
    testWidth = context.measureText(loadedTestText).width

    verbose && log "loading #{fontFamily}": {fontFamily, loadedTestText, expectedTestWidth, testWidth, referenceWidth}

    if expectedTestWidth?
      Math.abs(expectedTestWidth - testWidth) < .9 &&
      Math.abs(expectedTestWidth - referenceWidth) > .1
    else
      testWidth > 0 && testWidth != referenceWidth

  loadingTestBitmap = null
  # returns true if font is loaded
  @fontLoaded: (fontOptions, fontFamily, verbose) ->
    {loadedTestText, expectedTestWidth} = fontOptions
    throw new Error "loadedTestText required" unless loadedTestText?

    loadingTestBitmap ||= new Bitmap point 1
    loadedWidthBasedTest loadingTestBitmap, fontFamily, loadedTestText, expectedTestWidth, verbose

  @_cleanup: -> loadingTestBitmap = null