ArtSuite = require 'art-suite'
{createWithPostCreate, merge, HotStyleProps} = ArtSuite

module.exports = createWithPostCreate module, class StyleProps extends HotStyleProps

  @palette:
    primaryBackground:      "white"
    lightPrimaryBackground: "#c7ebf0"
    grayBackground:         "#eee"
    text:
      white: primary: "#fffe"
      black: primary: "#000e", secondary: "#0007"

  @mediumText:
    color: @palette.text.black.primary
    fontFamily: "sans-serif"
    fontSize: 16

  @largeText:
    color: @palette.text.black.primary
    fontFamily: "sans-serif"
    fontSize: 24

  @buttonBackground: (buttonDown) ->
    color: if buttonDown then "#e4f6f8" else "#c7ebf0"
    animators:
      shadow: duration: .1
      color: duration: .1
    shadow: if buttonDown
      blur: 1, offset: y: 1
    else
      blur: 2, offset: y: 2

  @smallText:
    color: @palette.text.black.primary
    fontFamily: "sans-serif"
    fontSize: 12

  @titleText: merge @mediumText,
    color: @palette.text.white.primary
