{defineModule, log} = require '@art-suite/art-foundation'
{Pipeline, TimestampFilter, DataUpdatesFilter} = require 'art-ery'

defineModule module, class ClientFailures extends Pipeline

  @remoteServer "http://localhost:8085"

  @filter
    before: beforeFilterClientFailure: (request) -> request.require false, "beforeFilterClientFailure allways fails"
    after: afterFilterClientFailure:   (request) -> request.require false, "afterFilterClientFailure allways fails"

  @publicRequestTypes "handlerClientFailure afterFilterClientFailure beforeFilterClientFailure"

  @handlers
    handlerClientFailure:       (request) -> request.require false, "handlerClientFailure allways fails"
    afterFilterClientFailure:   -> true
    beforeFilterClientFailure:  -> true
