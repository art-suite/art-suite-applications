{
  present, isPlainObject, object, merge, defineModule, formattedInspect, log, timeout, Promise
  each
  find
  objectWithout
} = require 'art-standard-lib'
{point} = require 'art-atomic'
Bitmap = require './Bitmap'

{Div, Link, Style} = require("art-foundation").Browser.DomElementFactories

defaultTimeout = 30000
defaultLoadedTestText = "aA"
###
fonts:
  nameKey:
    loadedTestText: string of characters with different glyphs than Arial (actually rendered to validate they changed)
    css:            URL to the css file that will load the font
    url:            URL to the font-file to load
    fontFamily:     font-family name [default: nameKey]
###
global.fontLoaderLog = []
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
  @allFontsLoaded: (fonts, verbose) ->
    timeExpired = 0
    new Promise (resolve, reject) =>
      testFonts = =>
        try
          timeoutTriggeredVerbose = timeExpired >= 1000 && timeExpired % 1000 == 0

          fontsLoaded = FontLoader.fontsLoadedSync fonts, timeoutTriggeredVerbose, verbose
          haveUnloadedFonts = find fontsLoaded, (loaded) -> !loaded

          unless haveUnloadedFonts
            if timeExpired >= 100 || verbose
              logFontLoaderStatus success: milliseconds: timeExpired, fonts: Object.keys fonts
            resolve fontsLoaded
          # else if timeoutRemaining <= 0
          #   reject new Error "timeout loading fonts: #{formattedInspect fonts}"
          else
            if timeoutTriggeredVerbose
              logFontLoaderStatus waiting: milliseconds: timeExpired, fonts: Object.keys fonts

            if @allFontLoadsExpired fontsLoaded, fonts, timeoutTriggeredVerbose, timeExpired
              resolve fontsLoaded
            else
              timeExpired += 25
              timeout 25, testFonts
        catch error
          logFontLoaderStatus allFontsLoaded: {error}

      testFonts()
    .then =>
      @_cleanup()

  @allFontLoadsExpired: (fontsLoaded, fonts, verbose, timeExpired) ->
    allExpired = true
    each fonts,
      when: (fontOptions, fontFamily) ->  !fontsLoaded[fontFamily]
      with: (fontOptions, fontFamily) ->
        {timeout: timeoutMs = defaultTimeout, onTimeout, previouslyExpired} = fontOptions
        if timeExpired > timeoutMs
          unless previouslyExpired
            onTimeout? {fontFamily, fontOptions, timeExpired, timeoutMs}
            fontOptions.previouslyExpired = true

        else
          allExpired = false

    allExpired




  # IN: see 'fonts' above
  # OUT: immediatly returns T/F
  @allFontsLoadedSync: (fonts, verbose) ->
    for k, loaded of FontLoader.fontsLoadedSync fonts, verbose
      return false unless loaded
    true

  # IN: see 'fonts' above
  # OUT: promise.then (loadedMap) ->
  #   IN: ladedMap: object keys are from fonts, values are true/false if that font is loaded
  @fontsLoadedSync: (fonts, verbose, verboseOnSuccess) ->
    object fonts, (fontOptions, fontFamily) -> FontLoader.fontLoaded fontOptions, fontFamily, verbose, verboseOnSuccess

  # IN: see 'fonts' above
  @loadFonts: (fonts) ->
    if !isPlainObject fonts
      throw new Error "ArtCanvas.FontLoader.loadFonts: fonts should be an object"

    # logFontLoaderStatus "ArtCanvas.FontLoader.loadFonts": {fonts, verbose} if verbose

    fontsLoaded = @fontsLoadedSync fonts, verbose
    for name, {fontFamily, loadedTestText, css, url, verbose} of fonts when !fontsLoaded[fontFamily]
      loadedTestText ||= defaultLoadedTestText
      fontFamily ||= name

      logFontLoaderStatus loading: merge {fontFamily, css, url} if verbose

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

    @allFontsLoaded fonts, verbose

  # getTestImageData = (options, text, bitmap) ->
  #   bitmap.clear backgroundColor = "#fee"
  #   bitmap.drawText point(5, bitmap.size.y * 2/3), text, merge options, color: "black"
  #   log getTestImageData: {options, text, bitmap: bitmap.clone()}
  #   bitmap.imageData.data

  logFontLoaderStatus = (toLog) ->
    fontLoaderLog.push toLog
    log formattedInspect ArtCanvasFontLoader: toLog

  loadedWidthBasedTest = (bitmap, fontFamily, loadedTestText, expectedTestWidth, verbose, verboseOnSuccess) ->
    {context} = bitmap
    context.font = "12px sans serif"
    referenceWidth = context.measureText(loadedTestText).width

    context.font = "12px #{fontFamily}, sans serif"
    testWidth = context.measureText(loadedTestText).width

    if expectedTestWidth?
      upperBoundTest = Math.abs(expectedTestWidth - testWidth) < .9
      lowerBoundTest = Math.abs(expectedTestWidth - referenceWidth) > .1
      notEqual = testWidth != referenceWidth
      loaded = upperBoundTest && lowerBoundTest && notEqual
      (verbose || loaded && verboseOnSuccess) && logFontLoaderStatus loadedWidthBasedTest_with_expectedTestWidth: {
        fontFamily
        loadedTestText
        expectedTestWidth
        testWidth
        referenceWidth
        upperBoundTest
        lowerBoundTest
        notEqual
        loaded
      }
      loaded
    else
      loaded = testWidth > 0 && testWidth != referenceWidth
      (verbose || loaded && verboseOnSuccess) && logFontLoaderStatus loadedWidthBasedTest: {
        fontFamily
        loadedTestText
        testWidth
        referenceWidth
        loaded
      }
      loaded


  loadingTestBitmap = null
  # returns true if font is loaded
  @fontLoaded: (fontOptions, fontFamily, verbose, verboseOnSuccess) ->
    {loadedTestText, expectedTestWidth} = fontOptions
    throw new Error "loadedTestText required" unless loadedTestText?

    loadingTestBitmap ||= new Bitmap point 1
    loadedWidthBasedTest loadingTestBitmap, fontFamily, loadedTestText, expectedTestWidth, verbose, verboseOnSuccess

  @_cleanup: -> loadingTestBitmap = null