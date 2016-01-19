# http://www.google.com/fonts/
# https://github.com/typekit/webfontloader
define [
  'art-foundation'
  '../extlib/webfont'
], (Foundation) ->
  {inspect, log, BatchLoader} = Foundation

  class GoogleFontLoader extends BatchLoader
    @singletonClass()

    constructor: (options = {})->
      @defaultWeight =
        UnifrakturCook: 700

      super (src) => @webFontLoadWithWaiting [src]

    #############
    # private
    #############

    # convert the "common" font names to ones friendly for webFontLoad
    #   no spaces
    #   some fonts require a specific weight be specified
    googleFamilies: (fontFamilies) ->
      for font in fontFamilies
        weight = @defaultWeight[font] || ""
        "#{font.split(" ").join("+")}:#{weight}:latin,latin-ext"

    # the basic google webFont loader
    # done() is called when all requested fonts are loaded
    webFontLoad: (fontFamilies, done) ->
      WebFont.load
        google:       families: @googleFamilies fontFamilies
        fontactive:   (font) => @addAsset font, font
        fontinactive: (font) => @addAsset font, "FAILED TO LOAD" #succeed anyway
        inactive:     done
        active:       done

    # google webfontLoader can't have more than one request-set at a time
    # This queues up all requests if one request is pending, then it fires off all queued requests as one request-set
    webFontLoadWithWaiting: (fontFamilies) ->
      @log "loading external fonts: #{inspect fontFamilies}"
      if window.WebFontConfig
        wfw = window.WebFontWaiting ||= {}
        wfw[font] = true for font in fontFamilies
        return

      @webFontLoad fontFamilies, =>
        waitingList = window.WebFontWaiting && Object.keys window.WebFontWaiting
        window.WebFontWaiting = null
        window.WebFontConfig = null
        @webFontLoad waitingList if waitingList
