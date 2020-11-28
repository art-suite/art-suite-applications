# http://www.google.com/fonts/
# https://github.com/typekit/webfontloader
Foundation = require 'art-foundation'
WebFont = require 'webfontloader' unless Neptune.isNode
{array, isArray, inspect, log, BatchLoader} = Foundation

module.exports = class GoogleFontLoader extends BatchLoader
  @singletonClass()

  constructor: (options = {})->

    super (src) => @_webFontLoadWithWaiting [src]


  @load: (fontFamilies) =>
    unless isArray fontFamilies
      fontFamilies = [fontFamilies]

    Promise.resolve @_serializeLoadsPromise
    .then =>
      @_serializeLoadsPromise = new Promise (resolve, reject) =>
        WebFont.load
          google:       families: @_googleFamilies fontFamilies
          fontactive:   (font) => if fontFamilies.length == 1 then resolve()
          fontinactive: (font) => if fontFamilies.length == 1 then reject()
          inactive:     (all)  => reject()
          active:       (all)  => resolve()

  #############
  # private
  #############

  # convert the "common" font names to ones friendly for webFontLoad
  #   no spaces
  #   some fonts require a specific weight be specified
  @_googleFamilies: (fontFamilies) ->
    array fontFamilies, (font) ->
      if /:/.test font
        [font, weight] = font.split ":"
      "#{font.split(" ").join("+")}:#{weight ? ""}:latin,latin-ext"

  # the basic google webFont loader
  # done() is called when all requested fonts are loaded
  _webFontLoad: (fontFamilies, done) ->
    WebFont.load
      google:       families: GoogleFontLoader._googleFamilies fontFamilies
      fontactive:   (font) => @addAsset font, font
      fontinactive: (font) => @addAsset font, "FAILED TO LOAD" #succeed anyway
      inactive:     done
      active:       done
  # google webfontLoader can't have more than one request-set at a time
  # This queues up all requests if one request is pending, then it fires off all queued requests as one request-set
  _webFontLoadWithWaiting: (fontFamilies) ->
    if window.WebFontConfig
      wfw = window.WebFontWaiting ||= {}
      wfw[font] = true for font in fontFamilies
      return

    @_webFontLoad fontFamilies, =>
      waitingList = window.WebFontWaiting && Object.keys window.WebFontWaiting
      window.WebFontWaiting = null
      window.WebFontConfig = null
      @_webFontLoad waitingList if waitingList
