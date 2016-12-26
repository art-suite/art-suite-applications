Foundation = require 'art-foundation'
Flux = require 'art-flux'

{log, createWithPostCreate, shallowClone} = Foundation
{ApplicationState} = Flux

scoreMap =
  0:0
  1:1
  2:3
  3:6
  4:10
  5:15
  6:21
  7:28
  8:36
  9:45
  10:55
  11:66
  12:78

scoreMaps =
  red:    scoreMap
  green:  scoreMap
  blue:   scoreMap
  yellow: scoreMap
  grey: 0: 0, 1: -5, 2:-10, 3:-15, 4:-20

createWithPostCreate class Quixx extends ApplicationState

  @stateFields
    score: 0
    subScores:
      red: 0
      yellow: 0
      green: 0
      blue: 0
      grey: 0

    board:
      red:    (false for i in [1..12])
      green:  (false for i in [1..12])
      blue:   (false for i in [1..12])
      yellow: (false for i in [1..12])
      grey:   (false for i in [1..4])

  toggleCheckbox: (color, index) ->
    newBoard = shallowClone @state.board
    row = newBoard[color] = shallowClone newBoard[color]
    if index >= 10  # game rules - when you get the last number, you get the lock too
      row[11] = row[10] = !row[index]
    else
      row[index] = !row[index]
    @updateState newBoard

  reset: -> @resetState()

  updateState: (newBoard)->
    newScore = 0
    newSubScores = {}
    for clr, row of newBoard
      count = 0
      count++ for checked in row when checked
      subScore = scoreMaps[clr][count]
      newScore += subScore
      newSubScores[clr] = subScore

    @setState
      board:      newBoard
      score:      newScore
      subScores:  newSubScores
