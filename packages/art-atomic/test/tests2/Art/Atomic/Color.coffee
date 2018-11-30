{rgbColor, hslColor, Color} = Atomic = Neptune.Art.Atomic
{log, formattedInspect} = require 'art-standard-lib'

module.exports = suite:
    rgbColor: ->
      test "red", ->
        red = new Color 1,0,0,1
        assert.equal red.toString(), "#ff0000"

      test "inspectedObjects ()", ->
        assert.match "#{formattedInspect rgbColor()}", "rgbColor('#000000')"

      test "inspectedObjects #f00", ->
        assert.match "#{formattedInspect rgbColor('#f00')}", "rgbColor('#ff0000')"

      test "red transparent", ->
        red = new Color 1,0,0,0.5
        assert.equal red.toString(), "rgba(255, 0, 0, 0.5)"

      test "small numbers", ->
        assert.eq rgbColor(1/255, 2/255, 3/255, 4/255).rgbaString, "rgbColor(1/255, 2/255, 3/255, 4/255)"

      test "toString on unclamped", ->
        assert.eq rgbColor(1, 3, 4, 5).toString(), "rgba(255, 255, 255, 1)"
        assert.eq rgbColor(-1, -3, -4, -5).toString(), "rgba(0, 0, 0, 0)"

      test "withAlpha", ->
        assert.eq rgbColor(1, .5, 0, 1).withAlpha(.5), rgbColor(1, .5, 0, .5)

      test "clamped", ->
        assert.eq rgbColor(1000, 256, 255, 1).clamped, rgbColor(1,1,1)
        assert.eq rgbColor(-1, -3, -4, -5).clamped, rgbColor(0,0,0,0)

      test "parse #X rgbColors", ->
        assert.eq rgbColor("#0").rgbaHexString, "#000000ff"
        assert.eq rgbColor("#7").rgbaHexString, "#777777ff"

      test "parse #XX rgbColors", ->
        assert.eq rgbColor("#00").rgbaHexString, "#000000ff"
        assert.eq rgbColor("#7f").rgbaHexString, "#7f7f7fff"

      test "parse #XXX rgbColors", ->
        assert.eq rgbColor("#f70").rgbaHexString, "#ff7700ff"
        assert.eq rgbColor("#ABC").rgbaHexString, "#aabbccff"

      test "parse #XXXX rgbColors", ->
        assert.eq rgbColor("#f70a").rgbaHexString, "#ff7700aa"
        assert.eq rgbColor("#DEFa").rgbaHexString, "#ddeeffaa"

      test "parse #XXXXXX rgbColors", ->
        assert.eq rgbColor("#ff7700").rgbaHexString, "#ff7700ff"
        assert.eq rgbColor("#ff7f05").rgbaHexString, "#ff7f05ff"
        assert.eq rgbColor("#fFeD05").rgbaHexString, "#ffed05ff"

      test "parse #XXXXXXXX rgbColors", ->
        assert.eq rgbColor("#ff7700ab").rgbaHexString, "#ff7700ab"
        assert.eq rgbColor("#ff7f05CD").rgbaHexString, "#ff7f05cd"
        assert.eq rgbColor("#fFeD0512").rgbaHexString, "#ffed0512"

      test "parse named rgbColors", ->
        assert.eq rgbColor("orange").rgbaHexString, "#ffa500ff"

      test "parse rgb rgbColors", ->
        assert.eq rgbColor("rgb(5,6,7)").rgbaHexString, "#050607ff"
        assert.eq rgbColor("rgb( 5 ,  6 ,  7 )").rgbaHexString, "#050607ff"
        assert.eq rgbColor("rgb(255,255,255)").rgbaHexString, "#ffffffff"
        assert.eq rgbColor("rgb(100%, 50%, 25%)").rgbaHexString, "#ff8040ff"
        assert.eq rgbColor("rgb(0,0,0)").rgbaHexString, "#000000ff"

      test "parse rgba rgbColors", ->
        assert.eq rgbColor("rgba(5,6,7,0.5)").rgbaHexString, "#05060780"
        assert.eq rgbColor("rgba(5,6,7, .5)").rgbaHexString, "#05060780"
        assert.eq rgbColor("rgba(100%, 50%, 25%, .25)").rgbaHexString, "#ff804040"
        assert.eq rgbColor("rgba(0,0,0,0)").rgbaHexString, "#00000000"

      test "hue", ->
        c = rgbColor 1, 0, 0, 1
        assert.eq c.h, 0

        c = rgbColor .1, .5, .8, 1
        assert.eq c.h, c.hue
        assert.eq c.hue, 0.5714285714285714

      test "sat", ->
        c = rgbColor 1, 0, 0, 1
        assert.eq c.s, 1

        c = rgbColor .1, .5, .8, 1
        assert.eq c.s, c.sat, c.saturation
        assert.eq c.saturation, .875

      test "lightness", ->
        c = rgbColor 1, 0, 0, 1
        assert.eq c.l, 1

        c = rgbColor .1, .5, .8, 1
        assert.eq c.l, c.lit
        assert.eq c.l, c.lightness
        assert.eq c.lightness, .8

    hslColor: ->
      test "hslColor", ->
        assert.eq hslColor(1, 1, 1),      rgbColor(1, 0, 0)
        assert.eq hslColor(0, 1, 1),      rgbColor(1, 0, 0)
        assert.eq hslColor(1/3, 1, 1),    rgbColor(0, 1, 0)
        assert.eq hslColor(2/3, 1, 1),    rgbColor(0, 0, 1)
        assert.eq hslColor(2/3, 0, 1),    rgbColor(1, 1, 1)
        assert.eq hslColor(2/3, .5, 1),   rgbColor(.5, .5, 1)
        assert.eq hslColor(2/3, .5, .25), rgbColor(.125, .125, .25)

      test "hslColor - preserves differences in degenerate colors", ->
        assert.eq   hslColor(1,  0, 1),      rgbColor 1, 1, 1
        assert.eq   hslColor(.5, 0, 1),      rgbColor 1, 1, 1
        assert.neq  hslColor(.5, 0, 1),      hslColor 1, 0, 1

      test "hslColor with alpha", ->
        assert.eq hslColor(1, 1, 1), rgbColor 1, 0, 0, 1
        assert.eq hslColor(1, 1, 1, 1), rgbColor 1, 0, 0, 1
        assert.eq hslColor(1, 1, 1, 0), rgbColor 1, 0, 0, 0
        assert.eq hslColor(1, 1, 1, .25), rgbColor 1, 0, 0, .25

      test "full constructor", ->
        c = new Atomic.Color .1, .2, .3, .4, .5, .6, .7
        assert.eq c.r, .1
        assert.eq c.g, .2
        assert.eq c.b, .3
        assert.eq c.a, .4
        assert.eq c.h, .5
        assert.eq c.s, .6
        assert.eq c.l, .7

      test "hslColor preserves lost info - hue == 1", ->
        assert.eq hslColor(0, 1, 1).h, 0
        assert.eq hslColor(1, 1, 1).h, 0
        assert.eq hslColor(.99, 1, 1).h, .99

      test "hslColor preserves lost info - lightness == 0", ->
        assert.eq hslColor(0, 1, 0).h, 0
        assert.eq hslColor(1, 1, 0).h, 0
        assert.eq hslColor(.99, 1, 0).h, .99
        assert.eq hslColor(.5, .25, 0).s, .25
        assert.eq hslColor(.5, .75, 0).s, .75

      test "hslColor preserves lost info - saturation == 0", ->
        assert.eq hslColor(0, 0, 1).h, 0
        assert.eq hslColor(.5, 0, 1).h, .5
        assert.eq hslColor(1, 0, 1).h, 0
        assert.eq hslColor(.99, 0, 1).h, .99

      test "interpolate 0, .5 and 1", ->
        c1 = new Color 1, 2, 3, 4
        c2 = new Color 3, 6, 9, 12
        assert.eq c1.interpolate(c2, 0), c1
        assert.eq c1.interpolate(c2, 1), c2
        assert.eq c1.interpolate(c2, .5), new Color 2, 4, 6, 8

    regressions: ->
      test "hslColor", ->
        assert.eq hslColor(1/6, 1, 1).hue, 1/6
