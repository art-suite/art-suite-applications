Foundation = require 'art-foundation'
Component = require './component'

module.exports = class HotStyleProps extends Foundation.BaseObject
  @postCreate: (hotLoaded) -> hotLoaded && Component.rerenderAll(); super
