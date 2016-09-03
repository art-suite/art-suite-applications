Foundation = require 'art-foundation'
Component = require './Component'

module.exports = class HotStyleProps extends Foundation.BaseObject
  @postCreate: ({hotLoaded}) -> hotLoaded && Component.rerenderAll(); super
