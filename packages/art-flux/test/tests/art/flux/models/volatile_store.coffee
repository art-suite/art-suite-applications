define [
  'art-foundation'
  'art-flux'
], (Foundation, Flux) ->
  {log, eq, merge, emailRegexp, Sequence} = Foundation

  {fluxStore} = Flux.Core.FluxStore
  {VolatileStore} = Flux.Models
  {volatileStore} = VolatileStore

  reset = ->
    fluxStore._reset()
    volatileStore._reset()

  onCompletion = (callback) ->
    (progress) ->
      if progress.status != "pending"
        callback progress

  testModelPrefix = "myModel"
  testId = "1"

  suite "Art.Flux.Models.VolatileStore", ->
    test "get missing record", (done)->
      reset()

      volatileStore.get testModelPrefix, testId, (statusRecord) ->
        if statusRecord.status != "pending"
          assert.eq statusRecord, status: 404
          done()

    test "put basic", (done)->
      reset()

      volatileStore.put testModelPrefix, testId, putFields = {foo: "bar"}, onCompletion (statusRecord)->
        storedFields = merge putFields, id: testId
        assert.eq statusRecord, status: 200, data: storedFields
        done()

    test "put twice merges", (done)->
      reset()

      volatileStore.put testModelPrefix, testId, foo: "bar",  onCompletion ->
        volatileStore.put testModelPrefix, testId, fooz: "baz", onCompletion (statusRecord)->
          assert.eq statusRecord, status: 200, data: id: testId, foo: "bar", fooz: "baz"
          done()

    test "post basic", (done)->
      reset()

      volatileStore.post testModelPrefix, postFields = {foo: "bar"}, onCompletion (statusRecord)->
        assert.eq statusRecord, status: 200, data: foo: "bar", id: "0"
        done()

    test "post twice", (done)->
      reset()

      volatileStore.post testModelPrefix, postFields = {foo: "bar"}, onCompletion (statusRecord)->
        assert.eq statusRecord, status: 200, data: foo: "bar", id: "0"
        volatileStore.post testModelPrefix, postFields = {fooz: "barz"}, onCompletion (statusRecord)->
          assert.eq statusRecord, status: 200, data: fooz: "barz", id: "1"
          done()
