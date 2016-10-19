Foundation = require 'art-foundation'
Component = require './Component'

module.exports = class HotStyleProps extends Foundation.BaseObject
  @postCreate: ({hotReloaded}) ->
    Component.rerenderAll() if hotReloaded
    super
