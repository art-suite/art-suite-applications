# Art.Components

> Initialized by Art.Build.Configurator

### Install

```coffeescript
npm install art-components
```

## ArtComponents vs ArtReact vs React.js

Generally, ArtComponents is designed to work just like React.js. There is
some evolution, though, which I try to note below.

## Component API

### `preprocessState`

Often you want to apply a transformation to `@state` whenever it is initialized
OR it changes.

An example of this is FluxComponents. They alter state implicitly as the subscription data comes in
as well as at component instantiation. preprocessState makes it easy to transform any data written via FluxComponents
into a standard form.

## Capabilities

- You can now change the root virtual element in a render function - as long as it isn't the root element of the entire application. You can also change the `key` of the root-virtual-element with the same restrictions since changing a key creates an entirely new virtual-element.

## NOT Supported, Though I Wants it

- You still cannot return arrays from render functions even though this would be highly useful.