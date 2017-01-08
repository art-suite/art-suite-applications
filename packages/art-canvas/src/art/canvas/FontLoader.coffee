{object, merge, defineModule, formattedInspect, log, timeout} = require 'art-foundation'
{point} = require 'art-atomic'
Bitmap = require './bitmap'

defineModule module, class FontLoader
  ###
  IN: object:
    keys are ignored except for the return value
    values are fontOptions passed to bitmap.drawText
    With one addition: set text: "string" for custom test-text
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
        log formattedInspect FontLoader: allFontsLoaded: {fonts, waited: initialTimeoutRemaining - timeoutRemaining}
        if FontLoader.allFontsLoadedSync fonts
          resolve object fonts, -> true
        else if timeoutRemaining <= 0
          reject new Error "timeout loading fonts: #{formattedInspect fonts}"
        else
          # log "waiting for fonts: #{formattedInspect fonts}"
          timeoutRemaining -= 25
          timeout 25, testFonts

      testFonts()

  # immediatly returns T/F
  @allFontsLoadedSync: (fonts) ->
    for k, loaded of FontLoader.fontsLoadedSync fonts
      return false unless loaded
    true

  # OUT: object keys are from fonts, values are true/false if that font is loaded
  @fontsLoadedSync: (fonts) ->
    object fonts, FontLoader.fontLoaded

  @fontLoaded: (fontOptions, fontFamily) ->
    text = fontOptions.text || "aA"
    fontOptions = merge
      fontFamily: fontFamily
      text: "aA"
      fontSize: 12
      fontOptions

    # log renderTest: {fontOptions}

    x = fontOptions.fontSize * 3
    tempBitmap = new Bitmap point x + fontOptions.fontSize * (fontOptions.text.length - 1), x
    tempBitmap.clear backgroundColor = "#eee"
    tempBitmap.drawText point(x * 1/3, x * 2 / 3), fontOptions.text, referenceOptions = merge fontOptions, fontFamily: "Sans Serif", color: "black"
    # log referenceBitmap: tempBitmap.clone(), referenceOptions: referenceOptions
    referenceData = tempBitmap.imageData.data

    tempBitmap.clear backgroundColor
    tempBitmap.drawText point(x * 1/3, x * 2 / 3), fontOptions.text, testOptions = merge fontOptions, fontFamily: "#{fontOptions.fontFamily}, Sans Serif", color: "black"

    # log testBitmap: tempBitmap.clone(), testOptions: testOptions
    testData = tempBitmap.imageData.data

    # log {testData, referenceData}
    for v, i in referenceData
      return true if v != testData[i]
    false
