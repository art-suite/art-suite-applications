ArtSuite = require 'art-suite'
{createHotWithPostCreate, arrayWith, log, ApplicationState, models} = ArtSuite

createHotWithPostCreate module, class Chat extends ApplicationState
  @stateFields
    history: []

  postMessage: (user, message) ->
    @history = arrayWith @history, user:user, message:message
