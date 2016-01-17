define [
  'art.foundation'
  'art.flux'
], (Foundation, Flux) ->
  {log, isString, Join, isArray, merge} = Foundation

  {FluxDbModelBase} = Flux.Db
  {ModelRegistry, FluxStore} = Flux.Core
  {FluxComponent} = Flux.React
  {VolatileModel, VolatileStore} = Flux.Models
  {fluxStore} = FluxStore

  FluxDbModelBase.localStoreCacheEnabled = false

  reset = ->
    fluxStore._reset()
    ModelRegistry._reset()
    VolatileStore.volatileStore._reset()

  suite "Art.Flux.Models.VolatileModel", ->
    test "create and register model", ->
      reset()
      class MyModel extends VolatileModel
        @register()

      assert.eq ModelRegistry.models.hasOwnProperty("myModel"), true
      assert.eq MyModel, ModelRegistry.models.myModel.class

    test "load missing record returns failure/404", (done) ->
      reset()
      class Bar extends VolatileModel
        @register()

      fluxStore.subscribe "bar", "foo", (fluxRecord) ->
        if fluxRecord.status != "pending"
          assert.eq fluxRecord, status: 404, key: "foo", modelName: "bar"
          done()

    test "load after put returns success/200", (done)->
      reset()
      class Bar extends VolatileModel
        @register()

      fluxStore.subscribe "bar", "foo", (fluxRecord) ->
        # NOTE: the initial subscription result is 404 since it doesn't exist yet...
        return unless fluxRecord.status != "pending" && fluxRecord.status != 404
        assert.eq fluxRecord,
          status: 200
          key: "foo"
          modelName: "bar"
          data:
            id: "foo"
            bar: "baz"
        done()

      ModelRegistry.models.bar.put "foo", bar:"baz"

    test "load after post returns success/200", (done)->
      reset()
      class Bar extends VolatileModel
        @register()

      ModelRegistry.models.bar.post bar:"baz", (statusRecord) ->
        return unless statusRecord.status != "pending"
        fluxStore.subscribe "bar", statusRecord.data.id, (fluxRecord) ->
          return unless fluxRecord.status != "pending"
          assert.eq fluxRecord,
            status: 200
            key: "0"
            modelName: "bar"
            data:
              id: "0"
              bar: "baz"
          done()

    test "post required field missing", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  required: true

      ModelRegistry.models.user.post bar:"baz", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: "failure"
          pendingData: bar: "baz"
          missingFields: ["name"]
          invalidFields: []
        done()

    test "post required field present", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  required: true

      ModelRegistry.models.user.post name:"baz", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: 200
          data: name: "baz", id: "0"
          key: "0"
          modelName: "user"
        done()

    test "post validated field - invalid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.post name:"baz", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: "failure"
          pendingData: name: "baz"
          missingFields: []
          invalidFields: ["name"]
        done()

    test "post preprocess field", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  preprocess: (v) -> v.trim()

      ModelRegistry.models.user.post name:" frank  ", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: 200
          data: name: "frank", id: "0"
          key: "0"
          modelName: "user"
        done()

    test "post validated field - valid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.post name:"frank", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          data: name: "frank", id: "0"
          status: 200
          key: "0"
          modelName: "user"
        done()

    test "post validated but not required field is null - valid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.post name:null, (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          data: name: null, id: "0"
          status: 200
          key: "0"
          modelName: "user"
        done()

    test "post validated but not required field is undefined - valid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.post name:undefined, (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          data: name: undefined, id: "0"
          status: 200
          key: "0"
          modelName: "user"
        done()

    test "post string-validated but not required field is 0 - invalid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.post name:0, (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          pendingData: name: 0
          status: "failure"
          missingFields: []
          invalidFields: ["name"]
        done()

    test "put validated field - invalid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.put "myId", name:"baz", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: "failure"
          id: "myId"
          model: "user"
          pendingData: name: "baz"
          invalidFields: ["name"]
        done()

    test "put validated field - valid", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  validate: (v) -> isString(v) && v.length > 3

      ModelRegistry.models.user.put "myId", name:"frank", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: 200
          data: name: "frank", id: "myId"
        done()

    test "put preprocess field", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  preprocess: (v) -> v.trim()

      ModelRegistry.models.user.put "myId", name:" frank  ", (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: 200
          data: name: "frank", id: "myId"
        done()

    test "put preprocessed field is null - not preprocessed", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  preprocess: (v) -> v.trim()

      ModelRegistry.models.user.put "myId", name:null, (statusRecord) ->
        return unless statusRecord.status != "pending"
        assert.eq statusRecord,
          status: 200
          data: name: null, id: "myId"
        done()

    test "field type - email invalid", (done)->
      reset()
      class User extends VolatileModel
        @fields email: @fieldTypes.email

      ModelRegistry.models.user.post email:"frank", (statusRecord) ->
        if statusRecord.status != "pending"
          assert.eq statusRecord, status: "failure", pendingData: {email: "frank"}, missingFields: [], invalidFields: ["email"]
          done()

    test "field type - 'required email' is actually required", (done)->
      reset()
      class User extends VolatileModel
        @fields email: @fieldTypes.requiredEmail

      ModelRegistry.models.user.post {}, (statusRecord) ->
        if statusRecord.status != "pending"
          assert.eq statusRecord, status: "failure", pendingData: {}, missingFields: ["email"], invalidFields: []
          done()

    test "field type - email valid", (done)->
      reset()
      class User extends VolatileModel
        @fields email: @fieldTypes.email

      ModelRegistry.models.user.post email:"  frank@GMail.com  ", (statusRecord) ->
        if statusRecord.status != "pending"
          assert.eq statusRecord, status: 200, data: {email: "frank@gmail.com", id: "0"}, key: "0", modelName: "user"
          done()

    test "list", (done)->
      reset()
      class User extends VolatileModel
        @fields name: @fieldTypes.trimmedString

      joiner = new Join
      for name in ["fred", "garry", "frank"]
        do (name) -> joiner.do (done) -> ModelRegistry.models.user.post name:name, (statusRecord) ->
          done name if statusRecord.status != "pending"

      joiner.join (results) ->
        fluxStore.subscribe "user", "", (statusRecord) ->
          return unless statusRecord.status != "pending" && Object.keys(statusRecord.data).length == 3
          assert.eq statusRecord.data,
            0: id: "0", name: "fred"
            1: id: "1", name: "garry"
            2: id: "2", name: "frank"
          done()

    test "query", (done)->
      reset()
      class User extends VolatileModel
        @fields
          name:  @fieldTypes.trimmedString
          email: @fieldTypes.email
        @query "email"

      joiner = new Join
      for k, user of {
        a: name:"fred", email:"fred@gmail.com"
        b: name:"garry", email:"garry@yahoo.com"
        c: name:"frank", email:"frank@msn.com"
      }
        do (user) -> joiner.do (done) -> ModelRegistry.models.user.post user, (statusRecord) ->
          done() if statusRecord.status != "pending"

      joiner.join (results) ->
        fluxStore.subscribe "usersByEmail", "garry@yahoo.com", (statusRecord) ->
          return unless statusRecord.status != "pending"
          assert.eq statusRecord.data, [name:"garry", email:"garry@yahoo.com", id: "1"]
          done()

