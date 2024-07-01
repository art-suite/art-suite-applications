# ArtSuite/ArtModelComponents

`ModelComponent` is a Components with support for subscribing to `ArtModel` data.

### ArtModel Basic Example

```coffeescript
# models/Compass.caf
import &ArtFlux
class Compass extends ApplicationState
  @stateFields
    cardinalDirection: "North"

# components/MyComponent.caf
import &ArtModelComponents

class MyComponent extends ModelComponent
  @subscribe "compass.cardinalDirection"

  render: ->
    TextElement
      text: "You are facing #{@cardinalDirection}."
```

> TODO 2023-09-19 This is currently correct, but ApplicationState will be refactored into its own NPM soon.

### ArtPipeline with auto-generated ArtModel Example

```coffeescript
# pipelines/Compass.caf
import &@ArtSuite/ArtPipelines
class Compass extends Pipeline

  constructor: ->
    @_compassByUserId = {}

  @publicHandlers
    get: -> @_compassByUserId[userId] ?= 0
    turn: ({data, session: {userId}}) ->
      @_compassByUserId[userId] =
        @_compassByUserId[userId] ? 0
        + data
        %% 360

# components/MyComponent.caf
import &ArtModelComponents

class Compass extends ModelComponent
  @subscribe "compass"

  render: ->
    Element
      "column"
      TextElement text: "You are facing #{@compass}."
      Button
        text: "Turn 90 degrees left"
        action: -> @models.compass.turn -90
```
