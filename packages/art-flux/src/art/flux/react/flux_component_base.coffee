{log, BaseObject, nextTick, mergeInfo, capitalize, globalCount, time} = require 'art-foundation'
{fluxStore} = require '../core/flux_store'
{ModelRegistry, FluxSubscriptionsMixin} = require '../core'

{Component} = Neptune.Art.React

###
FluxComponentBase

Basic Flux Subscription support:
 - manual subscribe and unsubscribe
 - automatic unsubscribeAll on component unmount
 - setStateFromFluxRecord method
 - access to @models

###
module.exports = class FluxComponentBase extends FluxSubscriptionsMixin Component

  ##########################
  # Lifecycle
  ##########################

  componentWillUnmount: ->
    super
    @unsubscribeAll()
