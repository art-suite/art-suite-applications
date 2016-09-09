ArtSuite = require 'art-suite'
{createWithPostCreate, merge, HotStyleProps} = ArtSuite

module.exports = createWithPostCreate module, class StyleProps extends HotStyleProps

  @palette:
    primaryBackground:      "#00bcd4"
    lightPrimaryBackground: "#c7ebf0"
    grayBackground:         "#eee"
    text:
      white: primary: "#fffe"
      black: primary: "#000e", secondary: "#0007"

  @mediumText:
    color: @palette.text.black.primary
    fontFamily: "sans-serif"
    fontSize: 16

  @smallText:
    color: @palette.text.black.primary
    fontFamily: "sans-serif"
    fontSize: 12

  @titleText: merge @mediumText,
    color: @palette.text.white.primary
