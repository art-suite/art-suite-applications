{present, isPlainObject, object, merge, defineModule, formattedInspect, log, timeout} = Foundation = require 'art-foundation'
{point} = require 'art-atomic'
Bitmap = require './bitmap'

{Div, Link, Style} = Foundation.Browser.DomElementFactories

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
    timeoutRemaining = initialTimeoutRemaining = 1000
    new Promise (resolve, reject) ->
      testFonts = ->
        if initialTimeoutRemaining - timeoutRemaining >= 100
          # font taking more than 100ms to load
          log.warn formattedInspect FontLoader: allFontsLoaded: {fonts, waited: initialTimeoutRemaining - timeoutRemaining}

        if FontLoader.allFontsLoadedSync fonts
          resolve object fonts, -> true
        else if timeoutRemaining <= 0
          reject new Error "timeout loading fonts: #{formattedInspect fonts}"
        else
          # log "waiting for fonts: #{formattedInspect fonts}"
          timeoutRemaining -= 25
          timeout 25, testFonts

      testFonts()

  # IN: see 'fonts' above
  # OUT: immediatly returns T/F
  @allFontsLoadedSync: (fonts) ->
    for k, loaded of FontLoader.fontsLoadedSync fonts
      return false unless loaded
    true

  # IN: see 'fonts' above
  # OUT: promise.then (loadedMap) ->
  #   IN: ladedMap: object keys are from fonts, values are true/false if that font is loaded
  @fontsLoadedSync: (fonts) ->
    object fonts, FontLoader.fontLoaded

  # IN: see 'fonts' above
  @loadFonts: (fonts) ->
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

  @fontLoaded: (fontOptions, fontFamily) ->
    throw new Error "fontOption 'text' is DEPRICATED: use loadedTestText" if fontOptions.text
    {loadedTestText} = fontOptions
    loadedTestText = fontOptions.loadedTestText || "aA"
    fontOptions = merge
      fontFamily: fontFamily
      fontSize: 12
      fontOptions

    # log renderTest: {fontOptions}

    x = fontOptions.fontSize * 3
    tempBitmap = new Bitmap point x + fontOptions.fontSize * (loadedTestText.length - 1), x
    tempBitmap.clear backgroundColor = "#eee"
    tempBitmap.drawText point(x * 1/3, x * 2 / 3), loadedTestText, referenceOptions = merge fontOptions, fontFamily: "Sans Serif", color: "black"
    # log referenceBitmap: tempBitmap.clone(), referenceOptions: referenceOptions
    referenceData = tempBitmap.imageData.data

    tempBitmap.clear backgroundColor
    tempBitmap.drawText point(x * 1/3, x * 2 / 3), loadedTestText, testOptions = merge fontOptions, fontFamily: "#{fontOptions.fontFamily}, Sans Serif", color: "black"

    # log testBitmap: tempBitmap.clone(), testOptions: testOptions
    testData = tempBitmap.imageData.data

    # log {testData, referenceData}
    for v, i in referenceData
      return true if v != testData[i]
    false
