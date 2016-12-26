ArtSuite = require 'art-suite'
{defineModule, arrayWith, log, ApplicationState, models} = ArtSuite

defineModule module, class Chat extends ApplicationState
  @stateFields
    history: []

  postMessage: (user, message) ->
    @history = arrayWith @history, user:user, message:message
