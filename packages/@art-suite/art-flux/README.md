# Art-Flux

Art.Flux is a simple, elegant solution to the following design constraints:

- Components can subscribe to remote or shared data
- Subscribing Components' states are automatically updated:
  - if the status of the initial request changes
  - as the initial request makes progress
  - whenever the data changes
- if the data is available immediately upon component instantiation, the component’s first render will reflect that data
- data is addressed by model-name and key-string
  - non-string keys are supported via custom `toFluxKey` methods
- model and subscription definitions are simple and lean

If you are familiar with the Flux design pattern, see: [[Art.Flux-vs-Other-Fluxes]]

## See

* [Subscription Declarations](#subscription-declarations)
* [FluxComponent Subscriptions](#FluxComponent-Subscriptions)
* [Flux Conventions](#flux-conventions)

## How It Works

There are three main parts to Art.Flux: FluxModels, FluxComponents and the FluxStore:

![](/Imikimi-LLC/art-flux/wiki/images/art-flux-nodes.png)

Using Art.Flux consists of registering one or more FluxModels and creating FluxComponents that subscribe to data provided by those models.

Behind the scenes, the FluxStore, a singleton class, manages all component subscriptions and provides epoch state updates. Epoch state updates queue all state changes in Flux turing a time unit, usually one animation frame, and  applies them atomically to the FluxStore's internal state. Immediately after the internal state update, FluxStore notifies all subscribers of changes.

New subscriptions to data not currently in the FluxStore indirectly cause loads to be invoked on the appropriate models. FluxModels are responsible for updating the FluxStore on the progress of those loads and the final result. FluxModels can later update the FluxStore if that data is updated locally or remotely.

When all subscribers to a particular piece of data go away, the FluxStore releases the data. In this way the FluxStore only keeps in memory what is actually being used by active FluxComponents.

![](/Imikimi-LLC/art-flux/wiki/images/art-flux-lines.png)

The diagram above shows typical method invocations that cause data to flow around the Flux loop. Only the `myModel.myMutator` needs to be invoked in your application code. FluxComponent state is automatically updated, and standard FluxModels take care of updating the FluxStore for you.

# Example

To use Art.Flux, create your a custom model and custom FluxComponent with a subscription to the model:

```coffeescript
# models/nav_state.coffee
{ApplicationState} = require 'art-flux'

module.exports = class NavState extends ApplicationState
  @stateFields currentTab: "home"

  nextTab: ->
    @currentTab = switch @currentTab
      when "home" then "search"
      else "home"

  @register()
```

```coffeescript
# components/my_component.coffee
{TextElement} = require 'art-react'
{createFluxComponentFactory} = require 'art-flux'

module.exports = createFluxComponentFactory
  @subscriptions ”navState.currentTab”

  nextTab: -> @models.navState.nextTab()

  render: ->
    TextElement
      text: @state.currentTab
      on: pointerClick: @nextTab
```

# Subscription Declarations

@subscriptions takes an object as input with each entry describing one subscription.

A subscription consists of 3 parts:

* stateField:   the field in @state which will be set with the subscribed-to data
* model:        the subscribed-to model (from the ModelRegistry)
* key:          key for the specific, subscribed-to data in the model

There are many different ways to define the subscription, shown below.

### Subscription Declarations, Object Forms

### Fully Explicit

```coffeescript
  @subscriptions
    stateField:
      model: "modelName", model-instance or (props) -> "modelName"
      key:   "key",       key-object     or (props) -> "key" or key-object
```

### Model-name == StateField-name with Explicit, Constant Key

```coffeescript
@subscriptions
  stateField: constantKey
```

is equivalent to:

```coffeescript
@subscriptions
  stateField:
    model:  'stateField'
    key:    constantKey
```

### Model-name == StateField-name with Key-Function

```coffeescript
@subscriptions
  stateField: (props) -> # return key
```

is equivalent to:

```coffeescript
@subscriptions
  stateField:
    model:  'stateField'
    key:    (props) -> # return key
```

Example:

```coffeescript
@subscriptions
  user: (props) -> props.userId

# Or, using coffeescript shorthand:
@subscriptions
  user: ({userId}) -> userId
```

### Subscription Declarations, String Forms

In addition to declaring subscriptions with object-notation, you can also use a simple string for common subscription-types. A subscription-string can contain one or more subscription declarations separated by spaces or commas.

### Model Form

This form is useful for subscribing to a single record from a table. This pattern works best if you follow the [[Flux Conventions]].

```coffeescript
@subscriptions "myField"
```

is equivalent to:

```coffeescript
@subscriptions
  myField:
    model:  'myField'
    key:    ({myField, myFieldId}) -> myField?.id || myFieldId
```

Example:

```coffeescript
@subscriptions "post"

#is short for:
@subscriptions
  post:
    model:  "post"
    key:    ({post, postId}) -> post?.id || postId
```

### Model.Key form

This form is useful for subscribing to a specific, known key. In particularly, this works well with ApplicationState models.

```coffeescript
@subscriptions "modelName.fieldName"
```

is equivalent to:

```coffeescript
@subscriptions
  fieldName:
    key: fieldName
    model: modelName
```

### Model-By form

### Key functions

If the key or model is a function, the function:

* is executed without @ set
* inputs: (props) - the component
* outputs: key or modelName respectively

```coffeescript
###
IN: props is the component instance's @props
@/THIS: not set
OUT: key
###
(props) -> key
```

Key-functions are called initially during getInitialState to set up initial
subscriptions.

If the key-function returns null, all dependent state fields will be set to
null. No other action will be taken.

Whenever @props changes (e.g. when componentWillReceiveProps is called), these
key-functions are re-evaluated. If the return value changes, subscriptions are
updated and new data is requested where needed.

# FluxComponent Subscriptions

Declaring a subscription on a FluxComponent has a few important effects. For a given subscription with a state-field name 'myStatefield':

* defines the getter: `@myStatefield`
* sets multiple fields on @state:
  * @state.myStateField - the current value from the subscription or null if no value has been fetched
  * @state.myStateFieldStatus - (string) the current status of fetching the value for the subscription (see Art.Founcation.ConnectionStatus)
  * @state.myStateFieldProgress - (number between 0 and 1) the current progress fetching the value for the subscription

Example
```coffeescript
class UserView extends FluxComponent
  @subscriptions "user"

  render: ->
    TextElement
      text: @user?.name || @state.userStatus

```

# Flux Conventions

* model-names which represent tables of records should be singular. Examples:
  - user
  - post
  - comment
* Keys for records are called "ids." When passing an id as a prop to a component, name it the model-name plus 'Id'. Examples:
  - userId
  - postId
  - commentId

If you follow these patterns, your subscription declarations are nice and concise. Example:

```coffeescript
class UserView extends FluxComponent
  @subscriptions "user post"
```

Equivalant to

```coffeescript
class UserView extends FluxComponent
 @subscriptions
   user: ({user, userId}) -> user?.id || userId
   post: ({post, postId}) -> post?.id || postId
```