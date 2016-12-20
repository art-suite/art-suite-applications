###
 * Gradify (https://github.com/fraser-hemp/gradify), modified as such:
 *   - Added pixelData argument
 *   - Added raw gradient and color results
 *   - Removed css generation stuff
###

{log, defineModule} = require 'art-foundation'
{max, floor, round, sqrt, abs} = Math

defineModule module, class Gradify
  constructor: (pixelData, imageSize) ->
    @pixelData = pixelData

    # Colors which do not catch the eye
    @ignoredColors = [[0,0,0], [255,255,255]]

    # Sensitivity to ignored colors
    @BWSensitivity = 4

    # Overall sensitivity to closeness of colors.
    @sensitivity = 7

    # Max sensitivity of black/white in the gradient (0 is pure BW, 5 is none).
    @maxBW = 2

    {@width, @height} = imageSize

    @computeGradients()

  getColorDiff: (first, second) ->
    # *Very* rough approximation of a better color space than RGB.
    sqrt(
      abs(
        1.4 * sqrt(abs(first[0] - second[0])) +
        0.8 * sqrt(abs(first[1] - second[1])) +
        0.8 * sqrt(abs(first[2] - second[2]))
      )
    )

  generateOutput: (colors) ->
    s = []
    rawGradients = []
    for color, i in colors
      rawGradients.push [
        (90 + color[3] + 180) % 360
        [color[0], color[1], color[2], 0]
        [color[0], color[1], color[2], 1]
      ]

    @rawGradients = rawGradients
    @rawColor = colors[3].slice(0,3)

  getQuads: (colors) ->
    # Second iteration of pix data is necessary because
    # now we have the base dominant colors, we have to check the
    # Surrounding color space for the average location.
    # This can/will be optimized a lot

    # Resultant array
    quadCombo = [0,0,0,0]
    takenPos = [0,0,0,0]

    # Keep track of most dominated quads for each col.
    quad = [
      [[0, 0], [0, 0]]
      [[0, 0], [0, 0]]
      [[0, 0], [0, 0]]
      [[0, 0], [0, 0]]
    ]

    # Iterate over each pixel, checking it's closeness to our colors.
    for r, j in @pixelData by 4
      g = @pixelData[j + 1]
      b = @pixelData[j + 2]

      # If close enough, increment color's quad score.
      for color, i in colors when 4.3 > @getColorDiff color, [r,g,b]
        xq = floor ((j / 4) % @width) / (@height / 2)
        yq = round  (j / 4) / (@width * @height)

        quad[i][yq][xq] += 1

    # For each col, try and find the best avail quad.
    for color, i in colors
      quadArr = []
      quadArr[0] = quad[i][0][0]
      quadArr[1] = quad[i][1][0]
      quadArr[2] = quad[i][1][1]
      quadArr[3] = quad[i][0][1]
      found = false

      j = 0
      while !found
        best_choice = quadArr.indexOf max quadArr...
        if 0 == max quadArr...
          colors[i][3] = 90 * quadCombo.indexOf(0)
          quadCombo[quadCombo.indexOf(0)] = colors[i]
          found = true

        if takenPos[best_choice] == 0
          colors[i][3] = 90 * best_choice
          quadCombo[i] = colors[i]
          takenPos[best_choice] = 1
          found = true
          break
        else
          quadArr[best_choice] = 0

        j++
    @generateOutput quadCombo

  # Select for dominant but different colors.
  getColors: (colors) ->
    selectedColors = []
    flag = false
    found = false
    old = []
    sensitivity = @sensitivity
    bws = @BWSensitivity

    while selectedColors.length < 4 && !found
      selectedColors = []
      for color in colors
        acceptableColor = false
        # Check curr color isn't too black/white.
        for ignoredColor in @ignoredColors
          if bws > @getColorDiff ignoredColor, color[0]
            acceptableColor = true
            break

        # Check curr color is not close to previous colors
        for selectedColor in selectedColors
          if sensitivity > @getColorDiff selectedColor, color[0]
            acceptableColor = true
            break

        continue if acceptableColor

        # IF a good color, add to our selected colors!
        selectedColors.push(color[0])
        if selectedColors.length > 3
          found = true
          break

      # Decrement both sensitivities.
      if bws > 2
        bws -= 1
      else
        sensitivity--
        found = 1 if sensitivity < 0

        # Reset BW sensitivity for new iteration of lower overall sensitivity.
        bws = @BWSensitivity

    @getQuads selectedColors

  getColorsByFrequency: ->
    r = b = g = 0
    colorMap = {}
    sortedColors = []

    for r, i in @pixelData by 4
      g = @pixelData[i + 1]
      b = @pixelData[i + 2]

      newCol = encodeColor r, g, b
      colorMap[newCol] = (colorMap[newCol] || 0) + 1

    colors = for key, value of colorMap
      [
        decodeColor key
        value
      ]

    colors.sort (a, b) -> b[1] - a[1]

  # Count all colors and sort high to low.
  computeGradients: ->

    @getColors @getColorsByFrequency()

  #########################
  # PRIVATE
  #########################

  # Pad the rgb values with 0's to make parsing easier later.
  @_encodeColor: encodeColor = (r, g, b) ->
    ("0" + r.toString(16)).slice(-2) +
    ("0" + g.toString(16)).slice(-2) +
    ("0" + b.toString(16)).slice(-2)

  @_decodeColor: decodeColor = (encodedColor) ->
    [
      parseInt encodedColor.slice(0, 2), 16
      parseInt encodedColor.slice(2, 4), 16
      parseInt encodedColor.slice(4, 6), 16
    ]
