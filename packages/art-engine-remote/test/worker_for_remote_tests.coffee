{log, WorkerRpc: {workerRpc}} = require "art-foundation"
{remote} = require "art-engine-remote/remote"

self.log = log
self.remote = remote
self.workerRpc = workerRpc

console.log "Foundation and Remote loaded in worker"

workerRpc.register
  worker:
    eval: (javaScript) ->
      console.log "worker#eval: #{javaScript}"
      eval javaScript

workerRpc.bind
  main: ["ready"]
  test: ["test"]

console.log "ThreadWithDelegates DUDE, send READY"

workerRpc.main.ready()
